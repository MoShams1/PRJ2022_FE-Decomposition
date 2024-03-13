clc
clear
close all

% Specify the path to the JSON filesß

file_dir = dir('../data/*Exp02*');
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
    cnd_single1 = strcmp(cnd_proben,'single1');
    cnd_single2 = strcmp(cnd_proben,'single2');
    click1_x = cell2mat(struct2cell(jsonData.click1_xloc));
    click2_x = struct2cell(jsonData.click2_xloc);
    click2_x(cellfun(@isempty, click2_x)) = {NaN};
    click2_x = cell2mat(click2_x);
    probe_x = cell2mat(struct2cell(jsonData.probe_xloc));
    frame_dir = struct2cell(jsonData.frame_dir);
    dir_left = strcmp(frame_dir,'left');
    

    %%% prepare data for figures

    % calculate the offset of the leading and trailing probes in the double
    % conditions
    click1_err_vec = click1_x - probe_x;
    click1_err_vec(dir_left) = -click1_err_vec(dir_left);
    click2_err_vec = click2_x - probe_x;
    click2_err_vec(dir_left) = -click2_err_vec(dir_left);

    lead2_vec = max([click1_err_vec, click2_err_vec], [], 2);
    lead2_vec(~cnd_double) = nan;
    lead2(isub,1) = nanmean(lead2_vec);

    trail2_vec = min([click1_err_vec, click2_err_vec], [], 2);
    trail2_vec(~cnd_double) = nan;
    trail2(isub,1) = nanmean(trail2_vec);

    % calculate the offset of the leading and trailing probes in the single
    % conditions
    click_err = click1_x - probe_x;
    click_err(dir_left) = -click_err(dir_left);
    click_err(~cnd_single1) = nan;
    lead1(isub,1) = nanmean(click_err);
    
    click_err = click1_x - probe_x;
    click_err(dir_left) = -click_err(dir_left);
    click_err(~cnd_single2) = nan;
    trail1(isub,1) = nanmean(click_err);

end

%%% =====================================================================================
%%%%% Figure 02
figure('units','inches','outerposition',[7, 4, 4, 3.5])

%%% =====================================================================================
%%% Figure 02-A
% The stimulus scheme

%%% =====================================================================================
%%% Figure 02-B

nboot = 10000;
rng('default')

mean_boot_trail = bootstrp(nboot, @mean, [trail1 trail2]);
xtrail = mean([trail1, trail2]);
negtrail = prctile(mean_boot_trail, 25) - xtrail;
postrail = prctile(mean_boot_trail, 75) - xtrail;

mean_boot_lead = bootstrp(nboot, @mean, [lead1 lead2]);
xlead = mean([lead1, lead2]);
neglead = prctile(mean_boot_lead, 25) - xlead;
poslead = prctile(mean_boot_lead, 75) - xlead;

set(gca,'ydir','reverse')
hold on

% clead = .4 * ones(1,3);
clead = [59 128 238] / 256;
% ctrail = .7 * ones(1,3);
ctrail = [237 28 36] / 256;
cerr = 'k';
lw = 1.5;
xtick_vec = -3:4;
ytick_vec = 1:2;
marker_sz = 20;
barw = .4;

% plot the leading mislocalizations
x = [1, 2]+.25;
ymat = repmat(x, nsub, 1);
barh(x,xlead, barw, ...
    'facecolor',clead, ...
    'edgecolor','none')
scatter( ...
    [lead1 lead2], ymat, ...
    marker_sz, 'k', 'o');
errorbar(...
    xlead, x, neglead, poslead,...
    'o', ...
    'horizontal', ...
    'marker','none', ...    
    'color',cerr, ...
    'linewidth',lw)


% plot the trailing mislocalizations
x = [1, 2]-.25;
ymat = repmat(x, nsub, 1);
barh(x,xtrail, barw, ...
    'facecolor',ctrail, ...
    'edgecolor','none')
scatter( ...
    [trail1 trail2], ymat, ...
    marker_sz, 'k', 'o');
errorbar(...
    xtrail, x, negtrail, postrail,...
    'o', ...
    'horizontal', ...
    'marker','none', ...    
    'color',cerr, ...
    'linewidth',lw)


xlabel({'Perceived offset (dva)', '(in direction of motion)'})
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

yticks(ytick_vec)
yticklabels({'One-probe', 'Two-probe'})
ylim([ytick_vec(1)-.8 ytick_vec(end)+.6])

text(-.5,.3,'Trailing probe','color',ctrail,'horizontalalignment','right')
text(.5,.3,'Leading probe','color',clead,'horizontalalignment','left')

cleanplot

%%% ---------------------------------
%%% stat fig02-B

%%% all vs baseline

null_dist_trail = mean_boot_trail - xtrail;
ptrail1 = ( ...
    sum(null_dist_trail(:,1)>abs(xtrail(1))) ...
    + sum(null_dist_trail(:,1)<-abs(xtrail(1)))) ...
    / nboot;

ptrail2 = ( ...
    sum(null_dist_trail(:,2)>abs(xtrail(2))) ...
    + sum(null_dist_trail(:,2)<-abs(xtrail(2)))) ...
    / nboot;

null_dist_lead = mean_boot_lead - xlead;
plead1 = ( ...
    sum(null_dist_lead(:,1)>abs(xlead(1))) ...
    + sum(null_dist_lead(:,1)<-abs(xlead(1)))) ...
    / nboot;

plead2 = ( ...
    sum(null_dist_lead(:,2)>abs(xlead(2))) ...
    + sum(null_dist_lead(:,2)<-abs(xlead(2)))) ...
    / nboot;

disp([ ...
    'One-probe trail: ', ...
    'diff = ', num2str(mean(trail1)),' dva, ', ...
    'p = ', num2str(ptrail1) ...
    ])

disp([ ...
    'One-probe lead: ', ...
    'diff = ', num2str(mean(lead1)),' dva, ', ...
    'p = ', num2str(plead1) ...
    ])

disp([ ...
    'Two-probe trail: '...
    'diff = ', num2str(mean(trail2)),' dva, ', ...
    'p = ', num2str(ptrail2) ...
    ])

disp([ ...
    'Two-probe lead: ', ...
    'diff = ', num2str(mean(lead2)),' dva, ', ...
    'p = ', num2str(plead2) ...
    ])

disp('---')

%%% lead vs trail

measured_diff = mean([lead1, lead2] - [trail1, trail2]);

null_dist_diff = (mean_boot_lead - mean_boot_trail) - measured_diff;

pdiff1 = ( ...
    sum(null_dist_diff(:,1)>abs(measured_diff(1))) + ...
    sum(null_dist_diff(:,1)<-abs(measured_diff(1)))) / ...
    nboot;

pdiff2 = ( ...
    sum(null_dist_diff(:,2)>abs(measured_diff(2))) + ...
    sum(null_dist_diff(:,2)<-abs(measured_diff(2)))) / ...
    nboot;

disp([ ...
    'One-probe lead vs trail, ', ...
    'diff = ', num2str(mean(lead1-trail1)), ' dva, ', ...
    'p = ', num2str(pdiff1) ...
    ])

disp([ ...
    'Two-probe lead vs trail, ', ...
    'diff = ', num2str(mean(lead2-trail2)), ' dva, ', ...
    'p = ', num2str(pdiff2) ...
    ])


disp('---')

%%% trail1 vs trail2

measured_diff_trail = mean(trail2 - trail1);

null_dist_diff_trail = (mean_boot_trail(:,2) - mean_boot_trail(1)) - measured_diff_trail;

pdiff_trail = ( ...
    sum(null_dist_diff_trail>abs(measured_diff_trail)) + ...
    sum(null_dist_diff_trail<-abs(measured_diff_trail))) / ...
    nboot;

disp([ ...    
    'One-probe vs Two-probe trails: ', ...
    'diff = ', num2str(mean(trail2-trail1)), ' dva, ', ...
    'p = ', num2str(pdiff_trail) ...
    ])


%%% lead1 vs lead2

measured_diff_lead = mean(lead2 - lead1);

null_dist_diff_lead = (mean_boot_lead(:,2) - mean_boot_lead(1)) - measured_diff_lead;

pdiff_lead = ( ...
    sum(null_dist_diff_lead>abs(measured_diff_lead)) + ...
    sum(null_dist_diff_lead<-abs(measured_diff_lead))) / ...
    nboot;

disp([ ...
    'One-probe vs Two-probe leads: ', ...
    'diff = ', num2str(mean(lead2-lead1)), ' dva; ', ...
    'p = ', num2str(pdiff_lead) ...
    ])

saveas(gcf, '../results/fig02B.pdf')