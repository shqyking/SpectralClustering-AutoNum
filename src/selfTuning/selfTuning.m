function K = selfTuning(data, k_max, m)

% This function implements the self-tuning paper to automatically determine
% the number of clusters
% 
%   K = selfTuning(data, k_max, m)
%  
%  Input:
%        data - the input dataset
%        k_max - the largest possible number of the clusters
%        m - the parameter to build the m-nearest neighbors similarity graph
%               
%  Output:
%        K - the best number of clusters predicted by self-tuning algorithm
%
%  Code by Yun Sun
%


% Construct similarity matrix
W = getKnnGraph(data, m, false);
    
% Zero out diagonal
ZERO_DIAG = ~eye(size(data,1));
W = W.*ZERO_DIAG;
    
% do rotation
CLUSTER_NUM_CHOICES = [2:k_max];
[K, clusts_RLS, rlsBestGroupIndex, qualityRLS] = cluster_rotate(W,CLUSTER_NUM_CHOICES,0,1);
    
%end