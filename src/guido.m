function K = guido(data, max_q, m)
% this method is from Sanguinetti, Guido, Jonathan Laidler, and Neil D. Lawrence. 
% "Automatic determination of the number of clusters using spectral algorithms." 
% Machine Learning for Signal Processing, 2005 IEEE Workshop on. IEEE, 2005.
% data is an N x k matrix
% m is the parameter for the m-nearest neighbors similarity graph 
K=2;
N = size(data, 1);
W = getKnnGraph(data, m, false);
D = getDegree(W);
L = getLaplacian('rw', W, D);
[eigVec, eigVal] = eig(L);
[eigVal, eigIdx] = sort(diag(eigVal),'descend');

% initialize the eigen space
eigenSpace = zeros(N, 2);
eigenSpace(:,1) = eigVec(:,eigIdx(1));
eigenSpace(:,2) = eigVec(:,eigIdx(2));
% initialize the clusters
cluster = zeros(N,1);
% carefully initilize the two centers
% the first center c1 is the furthest from the origin
max_dist = 0;
idx = 0;
for i=1:N
   if(norm(eigenSpace(i,:)) > max_dist)
      max_dist =  norm(eigenSpace(i,:));
      idx = i;
   end
end
%assign the fartest point as the first center
cluster(idx) = 1;
c1 = eigenSpace(idx,:);
% c2 maximises its norm meanwhile minimising dot product with c1
% what I do is set the cosine value from 0.1 to 1.0
% iteratively find the c2
max_dist = 0;
idx = 0;
for cosThres = 0.05:0.05:1
   for i=1:N
       cosVal = dot(c1, eigenSpace(i,:)) / (norm(c1) * norm(eigenSpace(i,:)));
       if((abs(cosVal) < cosThres) && (norm(eigenSpace(i,:)) > max_dist))
           max_dist = norm(eigenSpace(i,:));
           idx = i;
       end
   end
   if(idx ~= 0)
      cluster(idx) = 2;
      break;
   end
end

%start to iterate
for q=2:max_q
    cluster = ekmeans(eigenSpace, cluster);
    if(max(cluster) > q) % there are points assigned to the new cluster
        new_eigenSpace = zeros(N,q+1);
        new_eigenSpace(:,1:q) = eigenSpace;
        new_eigenSpace(:,q+1) = eigVec(:,eigIdx(q+1));
        eigenSpace = new_eigenSpace;
    else
        K = q;
        break;
    end
end

end