function L = getLaplacian(type, W, D)
% return the graph Laplacian according to the type
% maximum eigenvalue of thie laplacian is 1
if(strcmp(type, 'unnormal'))
    L = W;
else
if(strcmp(type, 'sym'))
    L = D^(-1/2) * W * D^(-1/2);
else
    L = D^(-1) * W;
end
end