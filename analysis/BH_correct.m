% BH_correct
% Mohammad Shams <m.shamsahmar@gmail.com>
% May 2021
% Apr 2024
%
% Corrects pvalues for multiple comparisons using Benjamini-Hochberg method
%
% ===== INPUTS =====
% pval: originally calculated pvalues
% alpha: alpha level
% side:  [DEFAULT] two-sided(2) | one-sided(1)
%
% ===== OUTPUT =====
% sig: a logical vector indicating significant pvalues after correction

function [sig, alpha_hat] = BH_correct(pval,alpha,side)

n = nargin;

if n<3
    side = 2;
end

n = length(pval);

[~, ind] = sort(pval);
rank = 1:n;

alpha_hat_sort = (alpha./n)*rank;
alpha_hat(ind) = alpha_hat_sort;

switch side
    case 1
        sig = pval<alpha_hat;
    case 2
        sig = pval<(alpha_hat/2);
end
end