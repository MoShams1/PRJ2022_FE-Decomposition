% signrank_full
% March 2024
% Mohammad Shams <m.shamsahmar@gmail.com>
%
% returns the Wilcoxon signed rank test statistic (W)
% and in case of an approximation the corresponding z value
%
% [p, W, z] = signrank_full(a)
% [p, W, z] = signrank_full(a,b)
%

function [delta, p, W, z, r] = signrank_full(a,b)

ninput = nargin;
p = nan;
W = nan;
z = nan;
delta = nan;

switch ninput
    case 1
        [~,~,stats1] = signrank(a);
        [p,~,stats2] = signrank(-a);
        delta = median(a);

    case 2
        [~,~,stats1] = signrank(a,b);
        [p,~,stats2] = signrank(b,a);
        delta = median(a-b);
end

if stats1.signedrank < stats2.signedrank
    W = stats1.signedrank;
    if isfield(stats1,'zval')
        z = stats1.zval;
    end
else
    W = stats2.signedrank;
    if isfield(stats2,'zval')
        z = stats2.zval;
    end
end

% calculate effect size
% ref: https://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test
w1 = stats1.signedrank;
w2 = stats2.signedrank;
T = abs(w1 - w2);
S = w1 + w2;
r = T/S;
