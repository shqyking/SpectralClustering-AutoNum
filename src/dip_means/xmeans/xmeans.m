%% xmeans.m
% function [centroids clusters] = xmeans(dataset)
%
% The function xmeans is an accelerated version of k-means clustering that
% provides enhancements in three ways:
% - good computational scaling for large datasets
% - determines the statistically optimal number of clusters
% - finds better than local minima (though does not necessarily converge
% to global minimum
%
% xmeans is statistically identical to kmeans and does not perform any sort
% of data compression.
% xmeans was developed by Dan Pelleg and Andrew Moore from Carnegie Mellon
% University, 2000
% Inputs
% - dataset the dataset to cluster
% - reasonable_k a reasonable range of values over which k is expected
% to lie. This is recommended for speed, though is not
% required
% Outputs
% - mu the locations of the final centroids
function [mu] = xmeans(dataset, reasonable_k)
% get the dimensionality of the dataset. This is crucial for spatial
% awareness
[N, dim] = size(dataset);
% determine the lower and upper bounds on k, as supplied by the user
lk = reasonable_k(1);
uk = reasonable_k(2);
k = lk;

% get some initial estimates of good centroids
random = randperm(N);
sub_dataset = dataset(random(1:10*k),:);
[~, mu] = kmeans(sub_dataset, k);

% build a kdtree for comparison
tree_depth = min(ceil(sqrt((N/10))),10);
kdtree = Kdtree(dataset, tree_depth);
% adjust the recursion limit
set(0, 'RecursionLimit',tree_depth^2);

% ---- perform the xmeans algorithm
while k < uk
    % 1. Improve parameters
    [kdtree dataset idx mu variance] = kMeansClustering(kdtree, k, mu);
    clf; hold all;
    for i = 1:k
        plot(dataset(idx==i, 1), dataset(idx==i, 2), '.', mu(i,1), mu(i,2), 'ko');
    end
    kdtree.plotOwnedNodes(1);
    
    % 2. Improve structure
    % 2.1 Child competition
    % split each centroid into 2 children, with starting points along a
    % random vector of length relative to the spread of points in the
    % parent cluster
    index = 1;
    for i = 1:k
        children = dataset(idx == i,:);
        tree_depth = min(ceil(sqrt((length(children(:,1))/10))),10);
        child_tree = Kdtree(children, tree_depth);
        no_successful_split = true;
        % calculate the variance of the data for the current centroid,
        % in order to throw the initial means sufficiently far from the centroid

        v = rand(1,dim);
        v = v / norm(v) * 4 * variance(i);
        start_vector = [mu(i,:)+v; mu(i,:)-v];
        plot(start_vector(:,1), start_vector(:,2),'r+');
        [child_tree children idx_c mu_c] = kMeansClustering(child_tree, 2, start_vector);
        plot(mu_c(:,1), mu_c(:,2), 'r*');
        
        % 2.2 BIC
        % Apply Bayesian Information Criterion to determine whether the
        % generated child clusters are more representative of the real distribution
        idx_p = ones(length(children), 1);
        parent_score = bic(children, idx_p, mu(i,:));
        child_score = bic(children, idx_c, mu_c);
        %dbg: 
        disp(['parent: ' num2str(parent_score) ' child: ' num2str(child_score)]);
        if child_score > parent_score
            mu_swap(index:index+1,:) = mu_c;
            index = index + 2;
        else
            mu_swap(index,:) = mu(i,:);
            index = index+1;
        end
    end
    % 2.3 update the number of clusters
    % If k is greater than the maximum reasonable guess, or the clusters
    % have not rearranged their structure, exit
    if isequal(mu, mu_swap), break; end
    mu = mu_swap;
    mu_swap = [];
    k = length(mu(:,1));
end
