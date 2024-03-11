clc
clear
close all

% Specify the path to the JSON files

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
figure('units','inches','outerposition',[7, 4, 8.5, 8])

%%% Figure 03-A
% The stimulus scheme

%%% Figure 03-B
subplot(2,2,2)

color = 'k';
lw = 1.5;  % line width
xtick_vec = -10:5:10;
ytick_vec = 0:3;

err = SE(y_all);
y = mean(y_all);

errorbar(...
    x,y,err,...
    'o', ...
    'markerfacecolor',color, ...
    'markeredgecolor','none', ...
    'color',color, ...
    'linewidth',lw)

yline(0,'--')

xlabel 'Probe to frame''s center (dva)'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Perceived offset (dva)', '(in direction of motion)'})
yticks(ytick_vec)
ylim([ytick_vec(1)-.4 ytick_vec(end)])

text(6.5,-.2,['N = ', num2str(nsub)])

cleanplot

%%% Figure 03-C
subplot(2,2,3)
hold on

color = gray(4);
lw = 1.5;
xtick_vec = -10:5:10;
ytick_vec = 0:3;

for isz = 1:3
    err = SE(y_sz(:,:,isz));
    y = mean(y_sz(:,:,isz));

    errorbar(...
        x,y,err,...
        'o', ...
        'markerfacecolor',color(isz,:), ...
        'markeredgecolor','none', ...
        'color',color(isz,:), ...
        'linewidth',lw)
end

yline(0,'--')

xlabel 'Probe to frame''s center (dva)'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Perceived offset (dva)', '(in direction of motion)'})
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
text(-10,2,'Frame width = 5.0 dva','color',color(2,:))
text(-10,1.8,'Frame width = 0.5 dva','color',color(3,:))
text(6.5,-.2,['N = ', num2str(nsub)])

cleanplot

%%% stat fig03-C
lead_trail_diff = y_all(:,6:10) - y_all(:,1:5);
display(['Lead vs Trail (all): ', num2str(signrank(lead_trail_diff(:)))])

lead_trail_diff = y_sz(:,6:10,1) - y_sz(:,1:5,1);
display(['Lead vs Trail (7): ', num2str(signrank(lead_trail_diff(:)))])
lead_trail_diff = y_sz(:,6:10,2) - y_sz(:,1:5,2);
display(['Lead vs Trail (5): ', num2str(signrank(lead_trail_diff(:)))])
lead_trail_diff = y_sz(:,6:10,3) - y_sz(:,1:5,3);
display(['Lead vs Trail (0.5): ', num2str(signrank(lead_trail_diff(:)))])

diff_sz1_sz2 = y_sz(:,:,1)-y_sz(:,:,2);
display(['7 vs 5: ',num2str(signrank(diff_sz1_sz2(:)))])
diff_sz2_sz3 = y_sz(:,:,2)-y_sz(:,:,3);
display(['5 vs 0.5: ',num2str(signrank(diff_sz2_sz3(:)))])


%%% fit Gaussian

x = (-9:2:9)';
x_precise = (-9:.1:9)';

%%% for all sizes poold
subplot(2,2,2)
hold on

y = mean(y_all)';
[y_mod, gof] = fit(x, y, fittype('gauss1'));
r2_all = gof.adjrsquare;
fit_amp_all = y_mod.a1;
fit_mean_all = y_mod.b1;
fit_std_all = y_mod.c1;

fprintf( ...
    'Fig03B fit (r2=%4.2f): amp = %3.1f dva, dist = %3.1f dva, std = %3.1f\n', ...
    r2_all, fit_amp_all, fit_mean_all, fit_std_all)

y_precise = feval(y_mod, x_precise);
plot(x_precise, y_precise, ...
    'color','k', ...
    'linewidth',lw)

%%% for each size separately
subplot(2,2,3)
hold on

log_legend = {'width 7.5', 'width 5', 'width 0.5'};

for iframe_sz = 1:3
    y = mean(y_sz(:,:,iframe_sz))';
    [y_mod, gof] = fit(x, y, fittype('gauss1'));
    r2(iframe_sz) = gof.adjrsquare;
    fit_amp(iframe_sz) = y_mod.a1;
    fit_mean(iframe_sz) = y_mod.b1;
    fit_std(iframe_sz) = y_mod.c1;
    
    fprintf( ...
    'Fig03C fit %s (r2=%4.2f): amp = %3.1f dva, dist = %3.1f dva, std = %3.1f\n', ...
    log_legend{iframe_sz}, r2(iframe_sz), ...
    fit_amp(iframe_sz), fit_mean(iframe_sz), fit_std(iframe_sz))

    y_precise(:,iframe_sz) = feval(y_mod, x_precise);
    plot(x_precise, y_precise(:,iframe_sz), ...
        'color',color(iframe_sz,:), ...
        'linewidth',lw)
end


%%% Figure 03-D
subplot(2,2,4)
hold on
plot(x_precise, y_precise(:,1)./max(y_precise(:,1)), ...
    'color',color(1,:), 'linewidth',lw)
plot(x_precise, y_precise(:,2)./max(y_precise(:,2)), ...
    'color',color(2,:), 'linewidth',lw)
plot(x_precise, y_precise(:,3)./max(y_precise(:,3)), ...
    'color',color(3,:), 'linewidth',lw)

yline(0,'--')

xlabel 'Probe to frame''s center (dva)'
xticks(xtick_vec)
xlim([xtick_vec(1)-.5 xtick_vec(end)+.5])

ylabel({'Normalized perceived offset', '(in direction of motion)'})
yticks([0 .5 1])
ylim([-0.15 1.2])

plot( ...
    [-7.5/2 7.5/2],[1.2 1.2], ...
    'linewidth',2*lw, ...
    'color',color(1,:));
plot( ...
    [-5/2 5/2],[1.16 1.16], ...
    'linewidth',2*lw, ...
    'color',color(2,:));
plot( ...
    [-.5/2 .5/2],[1.12 1.12], ...
    'linewidth',2*lw, ...
    'color',color(3,:));

cleanplot

saveas(gcf, '../results/fig03BCD.pdf')

%% calculate the time corresponding x-axis
round(1433 * 20 / 18) / 2