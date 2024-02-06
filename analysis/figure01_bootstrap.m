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

    
    %%% prepare data for figures

    % calculate the distance between the two clicks in the double condition
    two_click_dist = abs(click1_x - click2_x);

    % calculate the ditance between the click and the probe in the single
    % condition
    one_click_offset = abs(click1_x - probe_x);
    one_click_offset(cnd_double) = nan;

    for ncyc = 1:3
        two_click_dist_mat(isub, ncyc) = nanmean(two_click_dist(cnd_cycn==ncyc));
        one_click_offset_mat(isub, ncyc) = nanmean(one_click_offset(cnd_cycn==ncyc));
    end

end

%%% =====================================================================================
%%%%% Figure 01
figure('units','inches','outerposition',[7, 4, 5, 4])

%%% =====================================================================================
%%% Figure 01-A
% The stimulus scheme

%%% =====================================================================================
%%% Figure 01-B
subplot(1,2,1)
hold on

csingle = .6 * ones(1,3);
cdouble = 'k';
lw = 1.5;
xtick_vec = 1:3;
ytick_vec = 0:5;
marker_sz = 50;
marker_a = .2;

nboot = 10000;

x = 1:3;

mean_boot_single = bootstrp(nboot, @mean, one_click_offset_mat);
y1 = mean(one_click_offset_mat);
neg1 = prctile(mean_boot_single, 25) - y1;
pos1 = prctile(mean_boot_single, 75) - y1;

mean_boot_double = bootstrp(nboot, @mean, two_click_dist_mat);
y2 = mean(two_click_dist_mat);
neg2 = prctile(mean_boot_double, 25) - y2;
pos2 = prctile(mean_boot_double, 75) - y2;

xmat = repmat([1 2 3], 5, 1);
scatter( ...
    xmat, one_click_offset_mat, ...
    marker_sz, csingle, 'v');
scatter( ...
    xmat, two_click_dist_mat, ...
    marker_sz, cdouble, '^');

errorbar(...
    x, y1, neg1, pos1,...
    'color',csingle,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',csingle,...
    'markeredgecolor',csingle)
errorbar(...
    x, y2, neg2, pos2,...
    'color',cdouble,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',cdouble,...
    'markeredgecolor',cdouble)

xlabel 'Number of cycles'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel 'Absolute perceived offset (dva)'
yticks(ytick_vec)
ylim([ytick_vec(1)-.5 ytick_vec(end)])

text(2, .2, 'One-probe', 'color', csingle, 'horizontalalignment','center')
text(2, 4.5, 'Two-probe', 'color', cdouble, 'horizontalalignment','center')

cleanplot

%%% ---------------------------------
%%% Stat fig 01-B

rng('default')
nboot = 10000;
reference = 0;

measured_diff = cal_mean_diff(two_click_dist_mat);
boot_dist = bootstrp(nboot, @cal_mean_diff, two_click_dist_mat) - (measured_diff - reference);
sum_above = sum(boot_dist >= measured_diff);
sum_below = sum(boot_dist <= -measured_diff);
p_boot = (sum_above + sum_below) / nboot;
display(['Fig01A, Two-probe (anova-like test): p = ', num2str(p_boot)])

measured_diff = cal_mean_diff(one_click_offset_mat);
boot_dist = bootstrp(nboot, @cal_mean_diff, one_click_offset_mat) - (measured_diff - reference);
sum_above = sum(boot_dist >= measured_diff);
sum_below = sum(boot_dist <= -measured_diff);
p_boot = (sum_above + sum_below) / nboot;
display(['Fig01A, One-probe (anova-like test): p = ', num2str(p_boot)])

%%% =====================================================================================
%%% Figure 01-C

subplot(1,2,2)
hold on

c = 'k';
lw = 1.5;
xtick_vec = 1:3;
ytick_vec = 1:4;
marker_sz = 50;

x = 1:3;

ratio_mat = two_click_dist_mat ./ one_click_offset_mat;

mean_boot_ratio = bootstrp(nboot, @mean, ratio_mat);
y = mean(mean_boot_ratio);
neg = prctile(mean_boot_ratio, 25) - y;
pos = prctile(mean_boot_ratio, 75) - y;

xmat = repmat([1 2 3], 5, 1);
scatter( ...
    xmat, ratio_mat, ...
    marker_sz, c, 'o');
errorbar(...
    x, y, neg, pos,...
    'color',c,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',c, ...
    'markeredgecolor',c)

yline(2, 'linestyle','--')

xlabel 'Number of cycles'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Relative perceived offset'; '(Two-probe / One-probe)'});
yticks(ytick_vec)
ylim([ytick_vec(1)-.2 ytick_vec(end)])

cleanplot

%%% ---------------------------------
%%% Stat fig 01-C

rng('default')
nboot = 10000;
nmultiple = 3;
reference = 0;

measured_diff = cal_mean_diff(ratio_mat);
boot_dist = bootstrp(nboot, @cal_mean_diff, ratio_mat) - (measured_diff - reference);
sum_above = sum(boot_dist >= measured_diff);
sum_below = sum(boot_dist <= -measured_diff);
p_boot_ratio = (sum_above + sum_below) / nboot;
display(['Fig01C (anova-like test) p = ', num2str(p_boot_ratio)])

reference = 2;
measured_means = mean(ratio_mat);
for icol = 1:3
    vec = ratio_mat(:,icol);
    med_vec = bootstrp(nboot, @mean, vec) - (measured_means(icol) - reference);
    sum_above = sum(med_vec >= measured_means(icol));
    sum_below = sum(med_vec <= -measured_means(icol));
    p_boot_cyc(icol) = (sum_above + sum_below) / nboot;
end
display(['Fig01C (comparison to baseline) p = ',num2str(p_boot_cyc)])

reference = 2;
ratio_vec = mean(ratio_mat,2);
measured_mean = mean(ratio_vec);

med_vec = bootstrp(nboot, @mean, ratio_vec) - (measured_mean - reference);
sum_above = sum(med_vec >= measured_mean);
sum_below = sum(med_vec <= -measured_mean);
p_boot_cyc_pool = (sum_above + sum_below) / nboot;

display(['Fig01C (comparison to baseline; pooled) p = ',num2str(p_boot_cyc_pool)])

%%% =====================================================================================
function diff_vec = cal_mean_diff(x)
mean_vec = mean(x);
diff_vec = mean_vec(1)-(mean_vec(2)-mean_vec(3));
end

