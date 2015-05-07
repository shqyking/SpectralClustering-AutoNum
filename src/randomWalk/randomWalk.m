function K = randomWalk(data, k_max, m, mutual)

% Code by Qiuyang Shen
% This function implements two automatic dermination: eigengap heuristic and
% M-step eigengap
% data is an N x k matrix
% m is the parameter for the m-nearest neighbors similarity graph


W = getKnnGraph(data, m, mutual);
%degree matrix D
D = getDegree(W);
%Construct graph Laplacians
L = getLaplacian('rw', W, D);
L(isnan(L)) = 0;
%get the eigenvalue and eigenvector and sort
[eiVec, eiVal] = eig(L);
[eiVal, eiIdx] = sort(diag(eiVal),'descend');
eiVal = real(eiVal);

%Compute M-step eigengap
M_max = 50000;
deltaM = zeros(M_max, 1);
KM = zeros(M_max, 1);
for M=1:M_max
   for k=1:k_max
      gap = abs(eiVal(k)^M - eiVal(k+1)^M);
      if(gap > deltaM(M))
         deltaM(M) = gap; 
         KM(M) = k;
      end
   end
end

%Find local maxima of deltaM
[pks,locs] = findpeaks(deltaM);
if length(locs) == 0
    K = heuristic(data, k_max, m);
else 
    K = KM(locs(length(locs)));
end


%end