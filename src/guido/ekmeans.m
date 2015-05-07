function [clusters] = ekmeans(points, pre_clusters)
% Code by Qiuyang Shen
% points are N x q matrix, they are eigenvectors as columns
% pre_clusters contains the cluster indices for each point
% the length of pre_clusters is N
[N, q] = size(points);
centers = zeros(q+1, q);
cur_clusters = pre_clusters;
% Initialize q centers as the points identified at the previous step
% Plus last center which is origin
for i=1:q
    index = find(pre_clusters == i);
    centers(i,:) = mean(points(index,:)',2)';
end

% pre-computer the M
sharpness = 0.1;
M = cell(q, 1);
for i=1:q
    ci = centers(i,:);
    tmp = ci' * ci / (ci * ci');
    M{i} = 1/sharpness * (eye(q) - tmp) + sharpness * tmp;
end

%Do Elongated K-Means cluster
epsilon = 0.001;
while(true)
    pre_clusters = cur_clusters;
    for i=1:N 
        point = points(i,:);
        % for each point, caculate the distance from each center
        % assign the point to the closest center
        distance = zeros(q+1, 1); % store the distance from q+1 center
        for j=1:q % for each center
            cj = centers(j,:);
            if(cj * cj' > epsilon)
                distance(j) = (point - cj) * M{j} * (point - cj)';
            else
                distance(j) = norm(point - cj);
            end
        end
        distance(q+1) = norm(point);
        %assign the point to the closest cluster
        [junk, idx] = min(distance);
        if(length(idx) > 1) 
            % just in case there are more than one center closest
            idx = idx(1);
        end
        cur_clusters(i) = idx;       
    end
    % if the center does not move, then stop
    % equivalent to cur_clusters == pre_clusters
    if(cur_clusters == pre_clusters)
        break;
    end
    % if center moved, re-compute the q+1 centers
    for i=1:(q+1)
        index = find(pre_clusters == i);
        centers(i,:) = mean(points(index,:)',2)';
    end
end


clusters = cur_clusters;
end