% utest v1.0
% 29.10.2020
% Mohammad Shams
% m.shamsahmar@gmail.com
%
% returns the Mann-Whitney test statistic (U)
% and in case of an approximation the corresponding z value
function utest(a,b)

[~,~,stats1] = ranksum(a,b);
[~,~,stats2] = ranksum(b,a);

na = length(a);
nb = length(b);

if stats1.ranksum < stats2.ranksum
    U = stats1.ranksum - na*(na+1)/2
    if isfield(stats1,'zval')
        z = stats1.zval
    end
else
    U = stats2.ranksum - nb*(nb+1)/2
    if isfield(stats2,'zval')
        z = stats2.zval
    end
end