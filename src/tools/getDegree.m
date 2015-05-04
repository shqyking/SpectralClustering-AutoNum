function D = getDegree(W)
% Return the degree matrix D of weight matrix W
% D is a N x N diagonal matrix
N = size(W,1);
D = zeros(N);
for i=1:N
   D(i,i) = sum(W(i,:)); 
end
end