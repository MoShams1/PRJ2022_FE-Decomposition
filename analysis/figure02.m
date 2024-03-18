clc
clear
close all

% Specify the path to the JSON files

file_dir = dir('../data/*Exp01*');
nsub = numel(file_dir);


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
    click1_x = cell2mat(struct2cell(jsonData.click1_xloc));
    click2_x = struct2cell(jsonData.click2_xloc);
    click2_x(cellfun(@isempty, click2_x)) = {NaN};
    click2_x = cell2mat(click2_x);
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
%%%%% Figure 2A

figure('units','inches','outerposition',[7, 4, 3, 5])

hold on
cmap = lines(7);
csingle = 'k';
cdouble = cmap(7,:);
lw = 1.5;
xtick_vec = 1:3;
ytick_vec = 0:1.5;
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
    marker_sz*1.5, cdouble, 's', 'filled', 'markerfacealpha', alpha);

errorbar(...
    x, nanmean(one_probe_err_mat), SE(one_probe_err_mat),...
    'color',csingle,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',csingle,...
    'markeredgecolor',csingle)
errorbar(...
    x, nanmean(two_probe_err_mat), SE(two_probe_err_mat),...
    'color',cdouble,...
    'linewidth',lw,...
    'marker','s',...
    'markerfacecolor',cdouble,...
    'markeredgecolor',cdouble)

xlabel 'Number of motion cycles'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel 'Perceived offset (dva)'
yticks(ytick_vec)
ylim([ytick_vec(1)-.5 ytick_vec(end)+.5])

yline(0, 'linestyle','--')

text(1, 1.4, 'One-probe', 'color', csingle, 'horizontalalignment','center')
text(1, 1.3, 'Two-probe', 'color', cdouble, 'horizontalalignment','center')
text(3, -.25, ['N = ', num2str(nsub)])

cleanplot

saveas(gcf, '../results/fig02A.pdf')

%%% ---------------------------------
%%% Stat fig 2A

% display(['Fig02A, Two-probe (anova-like test): p = ', num2str(p_boot)])

% display(['Fig02A, One-probe (anova-like test): p = ', num2str(p_boot)])


