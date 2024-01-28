clc
clear
close all

% Specify the path to the JSON filesß

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

%%%%% Figure 01
figure('units','inches','outerposition',[7, 4, 6, 5])

%%% Figure 01-A
% The stimulus scheme

%%% Figure 01-B
subplot(1,2,1)
hold on

csingle = .6 * ones(1,3);
cdouble = 'k';
lw = 1.5;  % line width
xtick_vec = 1:3;
ytick_vec = 0:5;

x = 1:3;
y1 = mean(one_click_offset_mat,1);
err1 = SE(one_click_offset_mat);

y2 = mean(two_click_dist_mat,1);
err2 = SE(two_click_dist_mat);

errorbar(...
    x, y1, err1,...
    'color',csingle,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',csingle,...
    'markeredgecolor',csingle)

errorbar(...
    x, y2, err2,...
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

text(2.2, .7, 'Signle', 'color', csingle)
text(2.2, 4.7, 'Double', 'color', cdouble)
text(.7, 0, 'N = 5')

cleanplot

%%% Figure 01-C
subplot(1,2,2)

c = 'k';
lw = 1.5;  % line width
xtick_vec = 1:3;
ytick_vec = 1:3;

x = 1:3;
ratio_mat = two_click_dist_mat ./ one_click_offset_mat;
y = mean(ratio_mat, 1);
err = SE(ratio_mat);

errorbar(...
    x, y, err,...
    'color',c,...
    'linewidth',lw,...
    'marker','o',...
    'markerfacecolor',c, ...
    'markeredgecolor',c)

yline(...
    2, ...
    'linestyle','--')

xlabel 'Number of cycles'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Relative perceived offset'; 'Two probes / One probe'});
yticks(ytick_vec)
ylim([ytick_vec(1)-.2 ytick_vec(end)])

text(.7, 1, 'N = 5')

cleanplot
