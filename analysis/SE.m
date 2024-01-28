function B = SE(A)
% A: input matrix (repetition x j)
% B: a vector containing the SE of each column of A

B = nanstd(A,[],1) ./ sqrt(sum(~isnan(A)));