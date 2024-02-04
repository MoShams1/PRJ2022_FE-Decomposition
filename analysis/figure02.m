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


%%%%% Figure 02
figure('units','inches','outerposition',[7, 4, 4.5, 4])

%%% Figure 02-A
% The stimulus scheme

%%% Figure 02-B
set(gca,'ydir','reverse')
hold on

clead = .4 * ones(1,3);
ctrail = .7 * ones(1,3);
cerr = 'k';
lw = 1.5;  % line width
xtick_vec = -2:3;
ytick_vec = 1:2;

% plot the leading mislocalizations
x = [1, 2];
y = [nanmean(lead1), nanmean(lead2)];
err = [SE(lead1), SE(lead2)];
barh(x,y, ...
    'facecolor',clead, ...
    'edgecolor','none')
errorbar(...
    y,x,err,...
    'o', ...
    'horizontal', ...
    'marker','none', ...    
    'color',cerr, ...
    'linewidth',lw)

% plot the trailing mislocalizations
y = [nanmean(trail1), nanmean(trail2)];
err = [SE(trail1), SE(trail2)];
barh(x,y, ...
    'facecolor',ctrail, ...
    'edgecolor','none')
errorbar(...
    y,x,err,...
    'o', ...
    'horizontal', ...
    'marker','none', ...    
    'color',cerr, ...
    'linewidth',lw)

xlabel({'Perceived offset (dva)', 'in direction of motion'})
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

yticks(ytick_vec)
yticklabels({'Single', 'Double'})
ylim([ytick_vec(1)-.8 ytick_vec(end)+.5])

text(-2,.3,'Trailing probe','color',ctrail)
text(.5,.3,'Leading probe','color',clead)
text(-2.2, 2.3, 'N = 5')

cleanplot

%%% stat fig02-B
display(['single-trail: ', num2str(signrank(trail1))])
display(['double-trail: ', num2str(signrank(trail2))])
display(['single-lead: ',  num2str(signrank(lead1))])
display(['double-lead: ',  num2str(signrank(lead2))])

display(['single vs double trail: ', num2str(signrank(trail1,trail2))])
display(['single vs double lead: ', num2str(signrank(lead1,lead2))])