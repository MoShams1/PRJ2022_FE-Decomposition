% cleanplot
% Mohammad Shams
% m.shamsahmar@gmail.com

function cleanplot
set(gca,'tickdir','out','color','none')
box off
ax = gca;

if ~isempty(ax.Legend)
    legend boxoff
end