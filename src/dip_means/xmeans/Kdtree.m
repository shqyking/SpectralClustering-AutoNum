% Kd-Tree
% A kd-tree implementation that holds sufficient statistics in each node to
% avoid recalculation of cluster centroids, if all points in the node
% belong to the centroid
classdef Kdtree
    properties
        % children
        left_child = NaN;
        right_child = NaN;
        % leaf node data
        is_leaf = false;
        is_root = false;
        leaf_data;
        idx;
        % node properties
        dimension;
        dim;
        depth;
        tree_depth;
        is_owned = false;
        centroid;
        % node hyper rectangle statistics
        vector_sum;
        norm;
        N;
        bounds;
    end
    
    methods
        %% Kdtree
        % The default tree constructor. This method creates a new kdtree
        % node and populates the statistics
        % Inputs
        % - data the data to be constructed. This can be
        % n-dimensional with datapoints columnwise
        % - tree_depth the maximum allowable depth of the tree
        % - depth the current depth of the tree. This does not
        % need to be passed to the default constructor
        % and is used for internal purposes only
        % - dimension the dimension through which to split the data.
        % Internal purposes only
        % Outputs
        % - kdtree a new kdtree instance
        function kdtree = Kdtree(data, tree_depth, depth, dimension)
            if nargin == 2
                % we are in the top level constructor of the tree. Set some
                % of the global tree properties
                depth = 1; dimension = 1;
                kdtree.is_root = true;
                kdtree.tree_depth = tree_depth;
            end
            % calculate the dimension to slice
            if dimension > length(data(1,:))
                dimension = 1;
            end
            % generate the kmeans hyper-rectangle statistics
            kdtree.N = length(data(:,1));
            kdtree.norm = sum(sum(data.^2, 2));
            kdtree.vector_sum = sum(data);
            kdtree.bounds(1,:) = min(data);
            kdtree.bounds(2,:) = max(data);
            % store the current tree properties
            kdtree.dimension = dimension;
            kdtree.dim = length(data(1,:));
            kdtree.depth = depth;
            kdtree.tree_depth = tree_depth;
            kdtree.leaf_data = data;
            kdtree.is_leaf = true;
        end


        %% increaseDepth
        % Given a kdtree leaf node, this function build two new child nodes
        % and extends the leaf node into the children.
        % Inputs
        % - kdtree the node instance
        % Outpus
        % - kdtree the extended tree
        function kdtree = increaseDepth(kdtree)
            dimension = kdtree.dim;
            tree_depth = kdtree.tree_depth;
            depth = kdtree.depth;
            data = kdtree.leaf_data;
            % calculate the statistics of the new node
            divider = median(data(:,dimension));
            kdtree.left_child = Kdtree(data(find(data(:,dimension) < divider),:), tree_depth, depth+1, dimension+1);
            kdtree.right_child = Kdtree(data(find(data(:,dimension) >= divider),:), tree_depth, depth+1, dimension+1);
            % delete this node's leaf properties
            kdtree.is_leaf = false;
            kdtree.leaf_data = [];
        end
                
        %% update
        % This function updates the ownership of the datapoints in the tree
        % given the location of the centroids
        % Inputs
        % - kdtree the tree instance
        % - k the number of clusters
        % - centroids the centroid locations, columnwise
        % - indices for internal recursion purposes only. Used in
        % blacklisting
        % Outputs
        % - kdtree the modified tree structure
        % - mu the vector sum of each centroid data
        % - n the number of datapoints owned by each centroid
        % - variance the sum norm square of the centroid data
        function [kdtree mu n variance] = update(kdtree, k, centroids, indices)
            % if we are in the root node, set up some variables for
            % recursion
            if kdtree.is_root
                indices = 1:length(centroids(:,1));
            end
            
            % if we are in a leaf node, update the centroid statistics for
            % each of the individual points
            C = length(centroids(:,1));
            dim = kdtree.dim;
            n = zeros(k, 1);
            mu = zeros(k, dim);
            variance = zeros(k, 1);
            all = 1:C;
            if kdtree.depth == kdtree.tree_depth
                % preallocate the output arrays for speed
                data = kdtree.leaf_data;
                idx = zeros(length(data(:,1)), 1);
                for i = 1:length(kdtree.leaf_data(:,1))
                    point = repmat(kdtree.leaf_data(i,:), C, 1);
                    [euclidean c] = min(sum(((centroids - point).^2), 2));
                    n(indices(c)) = n(indices(c)) + 1;
                    mu(indices(c),:) = mu(indices(c),:) + point(1,:);
                    idx(i) = indices(c);
                    variance(indices(c)) = variance(indices(c)) + norm(point(1,:))^2;
                end
                kdtree.idx = idx;
                return;
            end
            % determine whether the tree is entirely owned by one centroid
            vertices = Kdtree.verticesFromLimits(kdtree.bounds);
            V = length(vertices(:,1));
            centroid_min_max = NaN(C, 2);
            
            % calculate the min max pathlength from each centroid to the
            % hyperrectangle vertices
            for c = 1:C
                centroid = repmat(centroids(c,:), V, 1);
                try
                    centroid_min_max(c, 1) = min(sqrt(sum(((centroid - vertices).^2), 2)));
                    centroid_min_max(c, 2) = max(sqrt(sum(((centroid - vertices).^2), 2)));
                catch
                    blah
                end
            end
            % check to see if a single centroid owns the entire
            % hyperrectangle. If the minimum maximum distance is greater
            % than the maximum minimum distance then there is a unique
            % owner
            for c = 1:C
                if length(indices) == 1 || centroid_min_max(c,2) < min(centroid_min_max(all ~= c, 1))
                    % we have a unique owner. Update the centroid statistics
                    n(indices(c),:) = n(indices(c),:) + kdtree.N;
                    mu(indices(c),:) = mu(indices(c),:) + kdtree.vector_sum;
                    variance(indices(c),:) = variance(indices(c),:) + kdtree.norm;
                    kdtree.centroid = indices(c);
                    kdtree.is_owned = true;
                    return;
                end
            end
            % we don't have a unique owner. Blacklist all centroids that
            % can't possibly own the hyperrectangle, and step down into
            % the children.
            % blacklisting occurs if the minimum distance from the
            % centroid is greater than the maximum distance from any
            % other centroids
            for c = 1:C
                if centroid_min_max(c,1) > centroid_min_max(all ~= c,2)
                    centroids(c,:) = NaN;
                    indices(c) = NaN;
                end
            end
            centroids(any(isnan(centroids),2),:) = [];
            indices(isnan(indices)) = [];
            kdtree.is_owned = false;
            % check to see if the children are valid, otherwise increase
            % the tree depth
            if kdtree.is_leaf, kdtree = kdtree.increaseDepth(); end
            [kdtree.left_child mu_l n_l variance_l] = update(kdtree.left_child, k, centroids, indices);
            [kdtree.right_child mu_r n_r variance_r] = update(kdtree.right_child, k, centroids, indices);
            
            n = n_l + n_r;
            mu = mu_l + mu_r;
            variance = variance_l + variance_r;
        end
              
        % retrive the data and the associated clusters from the kdtree
        % structure
        % Inputs
        % - kdtree the kdtree instance
        % Outputs
        % - data the data, columnwise
        % - idx the centroid index associated with each datapoint
        function [data idx] = retrieveClusters(kdtree)
            if kdtree.depth == kdtree.tree_depth
                % if we are in a leaf node, simply return the statistics
                data = kdtree.leaf_data;
                idx = kdtree.idx;
            elseif kdtree.is_owned
                % if the node is completely owned, return the sub data
                data = kdtree.getLeafData();
                idx = ones(length(data(:,1)), 1) * kdtree.centroid;
            else
                [data_l idx_l] = retrieveClusters(kdtree.left_child);
                [data_r idx_r] = retrieveClusters(kdtree.right_child);
                data = [data_l; data_r];
                idx = [idx_l; idx_r];
            end
        end
        
        %% getLeafData
        % recursively grabs the data from the leaves, thus returning all
        % datapoints owned by a node
        % Inputs
        % - kdtree the kdtree instance
        % Outputs
        % - data the data, columnwise
        function data = getLeafData(kdtree)
            if kdtree.is_leaf
                data = kdtree.leaf_data;
            else
                data = [getLeafData(kdtree.left_child); getLeafData(kdtree.right_child)];
            end
        end
        
        %% plotNodes
        % plots representations of the nodes on a figure, by drawing
        % rectangles indicative of the region bound by the node
        % Inputs
        % - kdtree the kdtree instance
        % - depth the depth at which to plot the nodes
        % - figure_handle the handle of the figure on which to
        % overlay the rectangles
        function plotNodes(kdtree, depth, figure_handle)
            % make sure the kdtree is storing 2 or 3 dimensional data
            if kdtree.dim ~= 2 && kdtree.dim ~= 3
                return;
            end

            % make sure the tree extends to the desired plotting depth
            if depth > kdtree.tree_depth, return; end
            
            % plot the boundaries at a particular depth in the tree
            if kdtree.depth == depth
                % we are at the required depth in the tree. Plot the
                % boundaries
                figure(figure_handle);
                hold on;
                if kdtree.dim == 2, plotRectangle(kdtree.bounds);
                elseif kdtree.dim == 3, plotCube(kdtree.bounds);
                end
                return;
            else
                plotNodes(kdtree.left_child, depth, figure_handle);
                plotNodes(kdtree.right_child, depth, figure_handle);
            end
        end
        
        %% plotOwnedNodes
        % plots only the nodes that are completely owned by a single
        % centroid. This helps to evaluate the effectiveness of the kdtree
        % on different data inputs.
        % Inputs
        % - kdtree the kdtree instance
        % - figure_handle the handle of the figure on which to
        % overlay the rectangles
        function plotOwnedNodes(kdtree, figure_handle)
            % make sure the kdtree is storing 2 or 3 dimensional data
            if kdtree.dim ~= 2 && kdtree.dim ~= 3
                return;
            end
            
            % if we have recursed to the depth of the tree, exit
            if kdtree.is_leaf, return; end
            
            % plot boundaries only if they are ownend
            if kdtree.is_owned
                figure(figure_handle);
                hold on;
                if kdtree.dim == 2, Kdtree.plotRectangle(kdtree.bounds);
                elseif kdtree.dim == 3, Kdtree.plotCube(kdtree.bounds);
                end
                return;
            else
                plotOwnedNodes(kdtree.left_child, figure_handle);
                plotOwnedNodes(kdtree.right_child, figure_handle);
            end
        end
        
    end
    
    methods(Static)
        %% verticesFromLimits
        % Determine the vertices of an n-dimensional hyper-rectangle
        % Inputs
        % - limits the limit points (opposing vertices)
        % Outputs
        % - vertices the exhaustive list of vertices
        function vertices = verticesFromLimits(limits)
            D = length(limits(1,:));
            vertices = NaN(2^D, D);
            for d = 1:D
                vertices(:,d) = repmat(kron(limits(:,d), ones(2^(d-1),1)), 2^(D-d), 1);
            end
        end
        
        %% plotRectangle
        % plot a rectangle in 2D space
        % Inputs
        % - limits the limit points (opposing vertices)
        function plotRectangle(limits)
            x = limits(:,1);
            y = limits(:,2);
            plot([x(1) x(2)], [y(1) y(1)], 'k', [x(1) x(2)], [y(2) y(2)], 'k', [x(1) x(1)], [y(1) y(2)], 'k', [x(2) x(2)], [y(1) y(2)], 'k');
        end
        
        %% plotCube
        % plot a cube in 3D space
        % Inputs
        % - limits the limit points (opposing vertices)
        function plotCube(limits)
            x = limits(:,1);
            y = limits(:,2);
            z = limits(:,3);
            plot3([x(1) x(2)], [y(1) y(1)], [z(1) z(1)], 'k', [x(1) x(2)], [y(2) y(2)], [z(1) z(1)], 'k',...
            [x(1) x(1)], [y(1) y(2)], [z(1) z(1)], 'k', [x(2) x(2)], [y(1) y(2)], [z(1) z(1)], 'k',...
            [x(1) x(2)], [y(1) y(1)], [z(2) z(2)], 'k', [x(1) x(2)], [y(2) y(2)], [z(2) z(2)], 'k',...
            [x(1) x(1)], [y(1) y(2)], [z(2) z(2)], 'k', [x(2) x(2)], [y(1) y(2)], [z(2) z(2)], 'k',...
            [x(1) x(1)], [y(1) y(1)], [z(1) z(2)], 'k', [x(1) x(1)], [y(2) y(2)], [z(1) z(2)], 'k',...
            [x(2) x(2)], [y(1) y(1)], [z(1) z(2)], 'k', [x(2) x(2)], [y(2) y(2)], [z(1) z(2)], 'k');
        end
    end
end