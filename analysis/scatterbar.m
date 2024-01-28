% scatterbar 1.0
% 01/04/2019
% Mohammad Shams
% m.shamsahmar@gmail.com

function scatterbar(A,marksz)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .07; % standard deviation of scatters in each category
linelm  = .4; % line length for median
if nargin < 2
    marksz  = 50; % marker size
end

c = [lines(7); lines(7)];

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    
    scatter(x,A{icat},marksz,c(icat,:),'.');
    line([icat-linelm icat+linelm],[nanmedian(A{icat}) nanmedian(A{icat})],...
        'color',c(icat,:),'linewidth',1);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)