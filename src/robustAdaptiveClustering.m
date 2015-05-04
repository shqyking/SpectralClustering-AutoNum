function K = robustAdaptiveClustering(data, k_max)
%ROBUSTADAPTIVECLUSTERING Summary of this function goes here
%   Detailed explanation goes here

% initiate adjustment matrix
N = size(data, 1);
J = zeros(N, N); % adjustment matrix
max_iter = 1000;

% construct adjustment matrix by using fcm algorithm
for i = 2 : k_max
    n_clusters = i;
    [center, U, obj_fcn] = fcm(data, n_clusters); % U is the membership matrics
    [M,I] = max(U); % I can be considered as Lc
    % update the adjustment matrix
    for j = 1 : N - 1
        for k = j + 1 : N
            if I(j) == I(k)
                J(j, k) = J(j, k) + 1;
                J(k, j) = J(k, j) + 1;
            end
        end
    end
end

% interarively partition by using BFS
iter = 0;
clusterNum = zeros(1, max_iter); % clusterNum(i) - the number of subsets at the ith iteration 

while checkZeroMatrix(J) == 0
    visited = zeros(1, N); % Initiate: all the nodes are not visited
    iter = iter + 1;

    % do BFS to find the number of subsets of the graph
    for i = 1 : N
        if visited(i) == 0
            clusterNum(iter) = clusterNum(iter) + 1;
            if clusterNum(iter) > k_max
                break;
            end
            for j = 1 : N
                if J(i, j) > 0
                    visited(j) = 1;
                end
            end
        end
    end
    % iter
    % clusterNum(iter)

    % update J by decreasing all the non-zero elements
    for i = 1 : N
        for j = 1 : N
            if J(i, j) > 0
                J(i, j) = J(i, j) - 1;
            end
        end
    end           
end

count     = 1;
max_count = 1;
pre       = clusterNum(1);
max_clusterNum = clusterNum(1);


for i = 2 : max_iter
    if clusterNum(i) == 0
        break;
    end
    if clusterNum(i) == pre
        count = count + 1;
    else
        if count > max_count
            max_count = count;
            max_clusterNum = clusterNum(i-1);
        end
        pre = clusterNum(i);
        count = 1;
    end 
end

K = max_clusterNum;

end


