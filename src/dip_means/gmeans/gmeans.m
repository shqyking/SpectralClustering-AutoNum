function [R, centers, ad] = gmeans(X, ad_threshold, iterations)

%%
% Performs the k-means method with increasing k's until for all the
% clusters the points within the cluster have a close to normal
% distribution (using the g-means algorithm)
%
% Input
% X             : the data, dimensioned : (N,P)
% ad_threshold  : the maximum ad-value that is allowed
% iterations    : [optional] number of times to repeat k-means, if not set (or 0)
%                 deterministic initialization of k-means is used
%
% Output
% groups    : the clusters output by k-means
% centers   : the center for every cluster
% ad        : the anderson-darling statistic for every cluster
%
% Copyright 2005-2006 Laboratori d'Aplicacions Bioacustiques
% For more information, errors, comments please contact codas@lab.upc.edu
%
% Changes to original release:
%  smallest_cluster has been defined as a parameter insted of an internal
%  variable. Other minor changes might have done. 
%  Argyris Kalogeratos 2012-2013.

% settings
initial_normality_check = 0;  % boolean var, when true the data is checked on normal distribution prior to running it through k-means
plot_nice_figures       = 1;  % boolean var, when true intermediate plots of the clustering of the data are drawn
smallest_cluster        = 6;  % number of object that a cluster may have so that it doesnt split further

if ( nargin < 2 )
    error('Syntax : [groups, centers, ad] = gmeans(data, ad_threshold[, iterations])');
    return;
end

% check for iterations
if ( nargin < 3 ),  iterations = 0;  end

[n,d]    = size(X);
k        = 2;
tX_ids   = 1:n; 
ad       = 0;
ready    = 0;
ngroups  = 0;
tgroups  = {};
dgroups  = {};
groups   = {1:n};
centers  = [];


% early abort if the data is already normal, bit slow on large data sets
[pc, latent, ~] = pcacov(cov(X));
projected = pc(:,1)'*X';
[pad, tad] = anderson_darling( projected, ad_threshold, smallest_cluster );
if ( pad == 1 || tad < 0 )
    centers(1,:)  = sum(X,1) / n;
    ad(1)         = max(0, tad); % ignore possible error messages
    R             = ones(n,1);
    return;
end

% initialize two centers - only with deterministic initialization
ncenters = sum(X,1) / n; %mean(X);   % making this variable available because i dont want to mess up the code too much
if ( iterations == 0 )
    ncenters(2,:) = find_furthest_point( X,  ncenters );
end

while (ready == 0)
    ready    = 1;
    pad      = [];  % temp variable to store the result from ad-test
    tad      = [];  % temp variable to store the ad-statistic
    accepted = 0;   % used to keep track if the entire data set needs to be rerun with an increased k, or split off part of the data
    nX_ids   = [];  % temp variable used to store the data that was not normally distributed around its center
    rgroups  = 0;   % the number of groups that has to be reclassified

    maxad           = 0;    % variables to keep track of the maximum ad over the classified clusters
    maxad_index     = 0;
    maxad_gindex    = 0;
    maxad_pc        = [];
    maxad_ev        = 0;

    % initial check to see if the data is already normally distributed -
    % only if a group was removed in the previous round
    if ( initial_normality_check == 1 )
        % calculate the anderson-darling statistic
        [pc, latent, ~] = pcacov(cov(X(tX_ids,:))); % first get the principal component of the group
        projected = pc(:,1)'*X(tX_ids,:)';          % project the points to the principal component
        [pad, tad] = anderson_darling( projected, ad_threshold, smallest_cluster ); % calculate the statistic along the component

        if ( pad == 1 )
            accepted = accepted + 1;
            ngroups  = ngroups  + 1;
            groups{ngroups}     = tX_ids; %tX;
            centers(ngroups,:)  = sum(X(tX_ids,:),1) / length(tX_ids); 
            ad(ngroups)         = tad;
            continue;  % this actually returns, ready is set to 1 above
        end
    end

    % perform k means
    if ( iterations == 0 ), [R, tcenters] = kmeans( X(tX_ids,:), k, 'Start', ncenters, 'EmptyAction', 'singleton', 'Display', 'off' );
    else                    [R, tcenters] = kmeans( X(tX_ids,:), k, 'Replicates', iterations, 'EmptyAction', 'singleton', 'Display', 'off' );
    end
    ncenters = [];
    
    % check if nice figures should be plotted
    if ( plot_nice_figures == 1 ),  figure, hold on;  end

    % store the clusters separately
    for i=1:k
        tgroups{i} = tX_ids(R == i);
        
        % plot figures if necessary
        if ( plot_nice_figures == 1 )
            mcolor = i/k*4/10 + 0.4;
            plot(X(tgroups{i}, 1), X(tgroups{i}, 2), '.', 'Color', [mcolor mcolor mcolor] );
            plot(tcenters(i,1), tcenters(i,2), '*black' );
        end
        
        % calculate the anderson-darling statistic
        if ( length(tgroups{i}) < smallest_cluster )
            pad(i) = 1; tad(i) = 0;
        else
            % first get the principal component of the group
            tcov = cov(X(tgroups{i},:));
            if ( sum(sum(tcov ~= 0)) == 0 ) % deal with zero covariance matrix, consider this a group
                pad(i) = 1; tad(i) = -1;
            else
                [pc, latent, ~] = pcacov(tcov);
                projected = pc(:,1)'*X(tgroups{i},:)'; % project the points on the principal component
                [pad(i), tad(i)] = anderson_darling( projected, ad_threshold, smallest_cluster ); % calculate the statistic along the component
            end
        end

        % check if this cluster is accepted and do some accounting
        % except if the ad-test returned 1, or if the data had 0 std,
        % no point in trying to split up the data any further in that case
        if ( pad(i) == 1 || (pad(i) == 0 && tad(i) == -1) )
            accepted = accepted + 1;
            ngroups  = ngroups  + 1;
            groups{ngroups}     = tgroups{i};
            centers(ngroups,:)  = tcenters(i,:);
            ad(ngroups)         = max(0, tad(i)); % ignore possible error messages
        else
            ready               = 0;
            rgroups             = rgroups + 1;
            dgroups{rgroups}    = tgroups{i};
            nX_ids              = [nX_ids tgroups{i}];
            ncenters(rgroups,:) = tcenters(i,:);

            % when tad is -2 it means that the distribution was far from
            % normal (log(0) error in anderson_darling.m)
            if ( tad(i) > maxad || maxad == 0 || tad(i) == -2 )
                maxad           = abs(tad(i));
                maxad_index     = rgroups;
                maxad_gindex    = i;
                maxad_pc        = pc(:,1);
                maxad_ev        = latent(1);
            end
        end
    end

    if ( ready == 0 )
        k  = k + 1 - accepted; % increase the k, take out the accepted clusters from the data
        tX_ids = nX_ids;

        % split up the least-normally-distributed center
        if ( iterations == 0 )
            ncenters(k,:) = find_furthest_point( X(tgroups{maxad_gindex},:), tcenters(maxad_gindex,:) );
        end
    end
end

% create the Idx matrix for the resulting partition
R = zeros(n,1);
for i=1:length(groups),
    R(groups{i}) = i;
end



