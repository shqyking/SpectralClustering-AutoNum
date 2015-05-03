function k = heuristic(data,k_min,k_max, m, a)

% data is an r x k matrix that includes r, k-dimensional instances we want
% to cluster
% k_min/k_max is the minimum/maximum number of clusters we want 
% m is the parameter for the m-nearest neighbors similarity graph that is
% constructed from the data
% a is a small constant for avoiding degenerate data from having no
% connections and leading to completely disconnected graph with many
% singletons (e.g., a=0.1)

A = zeros(length(data(:,1)));

% here we cosntruct the m-nearest neighbors similarity graph
% rule of thumb sets m = log(n)+1
% here m is a user input (e.g., 10)

for i=1:1:length(data(:,1))
        idx=knnsearch(data,data(i,:),'K',m,'Distance','cosine');
        for j=1:1:m
            A(i,idx(j))=dot(data(i,:),data(idx(j),:))/(norm(data(i,:),2)*norm(data(idx(j),:),2));
            if((A(i,idx(j)) == 0) || (isnan(A(i,idx(j)))))
                A(i,idx(j)) = a;
            end
            A(idx(j),i)=A(i,idx(j));
        end
end


D=zeros(length(data(:,1)));

for i=1:1:length(data(:,1))
    D(i,i)=sum(A(i,:));
end

L= D-A;
L=D^(-1/2)*L*D^(-1/2);

[U,V]= eig(L);

v=diag(V);

[vs, is] = sort(v,'ascend');

% here we implement the eigengap heuristic

eigengaps = zeros(length(vs)-1,1);

for i=1:1:length(eigengaps)
    if ((i<k_min) || (i> k_max))
        eigengaps(i)=-1;
    else
        eigengaps(i)=vs(i+1)-vs(i);
    end
end

[junk k] = max(eigengaps); 