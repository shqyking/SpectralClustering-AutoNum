function W = getKnnGraph(points, k, mutual)
% Code by Qiuyang Shen
% get K nearest neighbors from points, return the Weight Matrix W
% point is an N x d matrix
% k is the number of neighbors
% mutual is a bool variable indicate if knn is mutual knn.
% distance is Euclidean distance
% the similarity function is Gaussian function
% the parameter sigma in Gaussian is the mean of k-th distance

N = size(points, 1);
W = zeros(N);
if(N == k)
   error('k == number of Points. Please use fully connected graph.'); 
end

sigmas = zeros(N,1);
for i=1:N
    [idx, d] = knnsearch(points, points(i,:),'K', k, 'Distance', 'euclidean');
    % fill similarity into W. similarity function is Gaussian Function
    sigmas(i) = d(k);
    for j=1:k
        if(idx(j) == i) %If the neighbor is i itself, then continue
            continue;
        end
        W(i, idx(j)) = d(j);
    end
end

sigma = mean(sigmas); % get the sigma parameter

for i=1:N
    for j=(i+1):N
        if(mutual)
            tmp = min(W(i,j), W(j,i));
        else
            tmp = max(W(i,j), W(j,i));
        end
        if(tmp ~= 0) % avoid non-neighbor element
            W(i,j) = exp(-tmp^2/(2 * sigma^2));
            W(j,i) = W(i,j);
        end
    end
end

end