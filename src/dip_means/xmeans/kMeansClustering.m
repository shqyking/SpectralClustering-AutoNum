%% kMeansClustering
% performs kmeans clustering using a kdtree
% Inputs
% - kdtree the kdtree holding the data
% - k the number of clusters
% - mu an initial guess for the centroid locations
% Outputs
% - kdtree the updated kdtree structure
% - data the data contained within the kdtree structure
% - idx the centroid ID associated with each datapoint. Used in BIC
% - mu the new locations of the centroids
% - variance the variance of the data around each centroid
% - n the number of points associated with each centroid
function [kdtree data idx mu variance] = kMeansClustering(kdtree, k, mu)

% iterate until convergence
centroids = mu;

while true
    % record the position of the centroids to determine convergence
    old_centroids = centroids;
    % find the cluster centers
    [kdtree centroids n v] = kdtree.update(k, centroids);
    centroids = centroids ./ repmat(n, 1, kdtree.dim);
    
    if centroids == old_centroids, break; end
end

mu = centroids;
% calculate the proper variance
variance = (v - n .* sum(centroids.^2, 2)) ./ (n-1);
% get the points and associated idx
[data idx] = kdtree.retrieveClusters();
