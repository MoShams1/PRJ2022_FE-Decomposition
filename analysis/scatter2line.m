% 
% Jan 2024
% Mohammad Shams
% m.shams.ahmar@gmail.com
%
% NOTE: THIS FUNCTION WAS WRITTEN SPECIFICALLY FOR A CERTAIN ANALYSIS.
% USE IT WITH CAUTION ELSEWHERE.

% Converts a scatter plot into line based on equally spaced bins.
%
% scatter2line(m,nbins)
%       m: items x coordinates
%       nbins: number of bins

function [x_avg, y_avg] = scatter2line(m,nbins)

[~, bins] = histcounts(m(:,1),linspace(-10,10,nbins+1));

for ibin = 1:length(bins)-1
    x_avg(1,ibin) = mean([bins(ibin), bins(ibin+1)]);
    ind_ys = m(:,1)>=bins(ibin) & m(:,1)<=bins(ibin+1);
    y_avg(1,ibin) = mean(m(ind_ys,2));   
    
end

end