function flag = checkZeroMatrix(J)
%   The function is to check whether all the elements of the matrix are
%   zeros
%
%   flag = checkZeroMatrix(J)
%
%   Input:
%       J - adjustment matrix, a N*N matrix 
%
%   Output:
%       flag - a bool variable to indicate whether the input matrix is a
%       zero-matrix
%

flag = 1;
[n_row, n_col] = size(J);

for i = 1 : n_row
    for j = 1 : n_col
        if(J(i, j) ~= 0)
            flag = 0;
            break;
        end
    end
end

end

