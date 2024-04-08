clc
clear
close all

% Specify the path to the JSON files

file_dir = dir('../data/*Exp01*');
nsub = numel(file_dir);

click_coeff = 4;

for isub = 1:nsub

    % Specify the path to the JSON file
    jsonFilePath = fullfile(file_dir(isub).folder,file_dir(isub).name);

    % Open the JSON file and read its content
    fileID = fopen(jsonFilePath);
    jsonContent = fread(fileID, '*char')';
    fclose(fileID);
    
    % Parse the JSON content
    jsonData = jsondecode(jsonContent);

    
    %%% convert structure to arrays
    cnd_proben = struct2cell(jsonData.cnd);
    cnd_double = strcmp(cnd_proben,'double');
    click1_x = cell2mat(struct2cell(jsonData.click1_xloc)) * click_coeff;
    click2_x = struct2cell(jsonData.click2_xloc);
    click2_x(cellfun(@isempty, click2_x)) = {NaN};
    click2_x = cell2mat(click2_x) * click_coeff;
    probe_x = cell2mat(struct2cell(jsonData.probe_xloc));
    cnd_cycn = cell2mat(struct2cell(jsonData.frame_ncycles));

    
    %%% calculate absolute click offsets/errors
    click1_err = abs(click1_x - probe_x);
    click2_err = abs(click2_x - probe_x);
    
    one_probe_err = nan(length(probe_x), 1);
    one_probe_err(~cnd_double) = click1_err(~cnd_double);
    
    two_probe_err = nan(length(probe_x), 1);
    two_probe_err(cnd_double) = mean([...
        click1_err(cnd_double), ...
        click2_err(cnd_double)], 2);

    for ncyc = 1:3
        one_probe_err_mat(isub, ncyc) = nanmean(one_probe_err(cnd_cycn==ncyc));
        two_probe_err_mat(isub, ncyc) = nanmean(two_probe_err(cnd_cycn==ncyc));
    end

end

%%% =====================================================================================
%%%%% Figure 2B

figure('units','inches','outerposition',[7, 4, 5, 5])
subplot(1,2,1)
hold on

cmap = lines(7);
csingle = [0 0 0];
cdouble = cmap(5,:) * .85;
lw = 1.5;
xtick_vec = 1:3;
ytick_vec = 0:4;
marker_sz = 50;
marker_a = .2;
alpha = .2;

x = 1:3;
xmat = repmat([1 2 3], nsub, 1);

scatter( ...
    xmat, one_probe_err_mat, ...
    marker_sz, csingle, 'o', 'filled', 'markerfacealpha', alpha);
scatter( ...
    xmat, two_probe_err_mat, ...
    marker_sz, cdouble, 'o', 'filled', 'markerfacealpha', alpha);

errorbar(...
    x, nanmedian(one_probe_err_mat), SE(one_probe_err_mat),...
    'color',csingle,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',csingle,...
    'markeredgecolor',csingle)
errorbar(...
    x, nanmedian(two_probe_err_mat), SE(two_probe_err_mat),...
    'color',cdouble,...
    'linewidth',lw,...
    'marker','s',...
    'markerfacecolor',cdouble,...
    'markeredgecolor',cdouble)

xlabel 'Number of motion cycles'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel 'Click offset (dva)'
yticks(ytick_vec)
ylim([ytick_vec(1)-.5 ytick_vec(end)])

yline(0, 'linestyle','--')

text(1, .5, 'One-probe', 'color', csingle, 'horizontalalignment','left')
text(1, 0.25, 'Two-probe', 'color', cdouble, 'horizontalalignment','left')
text(3, -.25, ['N = ', num2str(nsub)])

cleanplot

%%% ---------------------------------
%%% Stat fig 2B

disp('----- Fig 2B -----')
disp(' ')

[p1, stats1] = friedman(one_probe_err_mat,1,'off');
[p2, stats2] = friedman(two_probe_err_mat,1,'off');

fprintf('<One-probe> Chi-sq(%d, %d)=%6.3f, p=%5.3f \n', stats1{2,3}, nsub, stats1{2,5}, stats1{2,6})
fprintf('<Two-probe> Chi-sq(%d, %d)=%6.3f, p=%5.3f \n', stats2{2,3}, nsub, stats2{2,5}, stats2{2,6})

d31 = median(two_probe_err_mat(:,3)-two_probe_err_mat(:,1));
d32 = median(two_probe_err_mat(:,3)-two_probe_err_mat(:,2));
d21 = median(two_probe_err_mat(:,2)-two_probe_err_mat(:,1));

p31 = signrank(two_probe_err_mat(:,3), two_probe_err_mat(:,1));
p32 = signrank(two_probe_err_mat(:,3), two_probe_err_mat(:,2));
p21 = signrank(two_probe_err_mat(:,2), two_probe_err_mat(:,1));

[med, p, W, z, r] = signrank_full(two_probe_err_mat(:,3), two_probe_err_mat(:,1));
fprintf('<3 vs 1> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

[med, p, W, z, r] = signrank_full(two_probe_err_mat(:,3), two_probe_err_mat(:,2));
fprintf('<3 vs 2> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

[med, p, W, z, r] = signrank_full(two_probe_err_mat(:,2), two_probe_err_mat(:,1));
fprintf('<2 vs 1> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n\n', ...
med,W,z,p,r)


line([1 2], [3.25 3.25], 'color', cdouble, 'linewidth', 2)
text(1.5, 3.45, '\it n.s.', 'color', cdouble, 'horizontalalignment','center')
line([2 3], [3.4 3.4], 'color', cdouble, 'linewidth', 2)
text(2.5, 3.5, '***', 'fontsize', 18, 'color', cdouble, 'horizontalalignment','center')
line([1 3], [3.75 3.75], 'color', cdouble, 'linewidth', 2)
text(2, 3.85, '*', 'fontsize', 18, 'color', cdouble, 'horizontalalignment','center')

%%% =====================================================================================
%%%%% Figure 2C

one_probe_err_pooled = mean(one_probe_err_mat,2);
two_probe_err_pooled = mean(two_probe_err_mat,2);

subplot(1,2,2)
hold on

y = {one_probe_err_pooled, two_probe_err_pooled};

xs = scatterbar(y, 50, [csingle; cdouble]);
plot(xs', [one_probe_err_pooled, two_probe_err_pooled]','color',[.5 .5 .5])
scatterbar(y, 50, [csingle; cdouble]);

yline(0, 'linestyle','--')

xticks([1 2])
xticklabels({'One-probe', 'Two-probe'})
xlim([.5 2.5])

ylabel 'Click offset (dva)'
yticks(ytick_vec)
ylim([ytick_vec(1)-.5 ytick_vec(end)])

cleanplot

%%% ---------------------------------
%%% Stat fig 2B

disp('----- Fig 2C -----')

[med, p, W, z, r] = signrank_full(two_probe_err_pooled, one_probe_err_pooled);
fprintf('\n<One-probe vs Two-probe> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

perc = median((two_probe_err_pooled-one_probe_err_pooled) ./ two_probe_err_pooled * 100);

fprintf('delta in percentage: %3d%% \n', round(perc))

line([1 2], [3.5 3.5], 'color', 'k', 'linewidth', 2)
text(1.5, 3.6, '***', 'fontsize', 18, 'horizontalalignment','center')

%%% =====================================================================================
saveas(gcf, '../results/fig02BC.pdf')

%%% =====================================================================================
% scatterbar 1.0
% Mohammad Shams <m.shamsahmar@gmail.com>
% Created: Apr 1, 2019
% Modified: Mar 20, 2024

function xs = scatterbar(A,marksz,c)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .07; % standard deviation of scatters in each category
linelm  = .4; % line length for median

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    xs(:,icat) = x;
    
    scatter(x,A{icat}, ...
        marksz, c(icat,:), 'o', 'filled', 'markerfacealpha', .4);
    line([icat-linelm icat+linelm],[nanmedian(A{icat}) nanmedian(A{icat})],...
        'color',c(icat,:),'linewidth',1);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)
end