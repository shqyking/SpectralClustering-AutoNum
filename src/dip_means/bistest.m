%------------
% Dip-means package demonstration.
%------------
% Copyright (C) 2012-2013, Argyris Kalogeratos.
%------------

% clear the matrices from the data of possible previous runs
clear ('X','C'); 

% define the RNG seed
rseed = sum(100*clock);    
rand('state', rseed);  randn('state', rseed);

tic; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create or load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % IRIS DATASET
    %-------------------
    %   load('iris.mat'); % X and C are loaded
    
    % COMBO 2d DATASET
    %-------------------
      load('combo_setting.mat'); % X and C are loaded    

clear C;
if (exist('C', 'var'))
     k = length(unique(C));
     real_k = k;
else real_k = -1; % the ground truth labels are not available
end

[N,d] = size(X);  DATASIZE = N;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run algorithms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select which methods to test (the names for each id are indicated in the next line)
methods = [3,4,5];


num_methods = length(methods);
method_names = {'', '', 'dip-means', 'x-means', 'g-means', '',}; % the last one is kernel k-means or k-means guided by the dip-test criterion (dip-means^*)
method_name = method_names(methods);

split_struct = cell(num_methods,1);
split_struct{3} = struct;
    split_struct{3}.pval_threshold    = 0.00; % the probability <= to which the cluster must split
    split_struct{3}.exhaustive_search = 1;    % whether Hardigan test must be done for all cluster objects or to stop when first prob=0 is found
    split_struct{3}.voting            = 0.01; % the spliting criterion is based on a voting (0<voting<=1), or on the worst indication from the objects of the cluster (voting=0)
    split_struct{3}.nboot             = 1000; % number of normal distribution samples to test each object with Hardigan test
    split_struct{3}.overall_distr     = 0;    % if 1, Hardigan test is applied one time on the overall distribution of distances
split_struct{5} = struct;
    split_struct{5}.pval_threshold    = 0.999; % the a value (alpha value)
split_struct{6} = split_struct{3}; 

split_trials = 10;                            % times to try a split

% choose whether to solve problem in kernel space (it is enabled if a non-negative kernel is provided)
    kernelSpace = 0.0;    
    if (kernelSpace > 0), Kernel = RBFkernel (X, kernelSpace);
                          method_names{6} = 'kernel dip-means';
    else                  Kernel = [];
                          method_names{6} = 'dip-means^*';
    end

result = zeros(max(methods), 6);
j = 1;
for m=methods,
    if (m == 4),   [R, sumer, R_ref, sumer_ref] = bisect_kmeans(X, 'split_struct', split_struct{m}, 'split_trials', split_trials, 'splitSELECT', m, 'splitMODE', 0, 'refineMODE', 2, 'attempts', 1, 'rndseed', 0+rseed);
    else           [R, sumer, R_ref, sumer_ref] = bisect_kmeans(X, 'split_struct', split_struct{m}, 'split_trials', split_trials, 'splitSELECT', m, 'splitMODE', 0, 'refineMODE', 2, 'attempts', 1, 'rndseed', 0+rseed);
    end   
    k = length(unique(R_ref));
    result(m, 1:3) = [k, sumer, sumer_ref];
    
    if (real_k > 0)
        [pq, RI, ARI, conf_matrix, conf_matrix_probC, conf_matrix_probR] =  partition_quality(C,R_ref);
        VI = varinfo(C,R_ref);
        result(m, 4:6) = [RI, ARI, VI];
    end
        
    j = j+1;
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n----------------------------------------\nClustering results for real_k = %g\n----------------------------------------\n', real_k);
if (real_k > 0)
    for m=methods,
        fprintf('%g. %10s -- k: %3g, RI: %1.5f, ARI: %1.5f, VI: %1.5f, error: %5.5f\n', m, method_names{m}, result(m,1), result(m,4), result(m,5), result(m,6), result(m,3));
    end
else % real_k == -1: the ground truth labels are not available
    for m=methods,
        fprintf('%g. %10s -- k: %3g, error: %5.5f, (supervised measures N/A)\n', m, method_names{m}, result(m,1), result(m,3));
    end
end
toc;

fprintf('RNG seed used: %f\n', rseed);