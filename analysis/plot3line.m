% plot3line v1.0
% 03-Jan-2021
% Mohammad Shams
% m.shamsahmar@gmail.com

function h = plot3line(x,A,color,crop,std,marker)

switch nargin
    case 2
        color = lines(1);
        crop = 0;
    case 3
        crop = 0;
end

if crop
    A(:,1:3*std) = nan;
    A(:,end-(3*std)+1:end) = nan;
end

m = nanmean(A,1);
err = SE(A);

hold on
h = plot(x,m,'marker',marker,'color',color,'linewidth',1);
plot(x,m-err,'color',color)
plot(x,m+err,'color',color)

% xlim([0 length(m)+1])