function B = MAD(A)
% A: input matrix (repetition x j)
% B: a vector containing the MAD of each column of A

for icol = 1:size(A,2)
    col = A(:,icol);
    med = nanmedian(col,1);
    col_diff = abs(col - med);
    B(1,icol) = nanmedian(col_diff);
end