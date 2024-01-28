clc
clear
close all

% Specify the path to the JSON filesß

file_dir = dir('../data/*Exp03*');
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
    frame_x = cell2mat(struct2cell(jsonData.frame_flashxloc));
    frame_sz = cell2mat(struct2cell(jsonData.frame_size));
    click_x = cell2mat(struct2cell(jsonData.click1_xloc));
    probe_x = cell2mat(struct2cell(jsonData.probe_xloc));
    
    
    %%% prepare data for figures

    % calculate probe distance to the frame
    pr_fr_dist = probe_x - frame_x;
    % calculate click error
    click_err = click_x - probe_x;
    % calculate avverage error independent of the frame size
    [x,y_all(isub,:)] = scatter2line([pr_fr_dist, click_err], 10);
    % calculate average error for each frame size
    ind75 = frame_sz == 7.5;
    [x,y_sz(isub,:,1)] = scatter2line([pr_fr_dist(ind75), click_err(ind75)], 10);    
    ind50 = frame_sz == 5;
    [x,y_sz(isub,:,2)] = scatter2line([pr_fr_dist(ind50), click_err(ind50)], 10);
    ind05 = frame_sz == .5;
    [x,y_sz(isub,:,3)] = scatter2line([pr_fr_dist(ind05), click_err(ind05)], 10);

end


%%%%% Figure 03
figure('units','inches','outerposition',[7, 4, 4, 8])

%%% Figure 03-A
% The stimulus scheme

%%% Figure 03-B
subplot(2,1,1)

color = 'k';
lw = 1.5;  % line width
xtick_vec = -10:5:10;
ytick_vec = 0:3;

err = SE(y_all);
y = mean(y_all);

errorbar(...
    x,y,err,...    
    'color',color, ...
    'linewidth',lw)

xlabel 'Probe to frame''s center distance (dva)'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Perceived offset (dva)', 'in direction of motion'})
yticks(ytick_vec)
ylim([ytick_vec(1)-.4 ytick_vec(end)])

text(6.5,-.1,'N = 4')

cleanplot

%%% Figure 03-C
subplot(2,1,2)
hold on

color = gray(4);
lw = 1.5;  % line width
xtick_vec = -10:5:10;
ytick_vec = 0:3;

for isz = 1:3
    err = SE(y_sz(:,:,isz));
    y = mean(y_sz(:,:,isz));

    errorbar(...
        x,y,err,...
        'color',color(isz,:), ...
        'linewidth',lw)
end

xlabel 'Probe to frame''s center distance (dva)'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Perceived offset (dva)', 'in direction of motion'})
yticks(ytick_vec)
ylim([ytick_vec(1)-.4 ytick_vec(end)])

plot( ...
    [-7.5/2 7.5/2],[3 3], ...
    'linewidth',2*lw, ...
    'color',color(1,:));
plot( ...
    [-5/2 5/2],[2.9 2.9], ...
    'linewidth',2*lw, ...
    'color',color(2,:));
plot( ...
    [-.5/2 .5/2],[2.8 2.8], ...
    'linewidth',2*lw, ...
    'color',color(3,:));

text(-10,2.2,'Frame width = 7.5 dva','color',color(1,:))
text(-10,2,'Frame width = 5 dva','color',color(2,:))
text(-10,1.8,'Frame width = 0.5 dva','color',color(3,:))
text(6.5,-.1,'N = 4')

cleanplot

