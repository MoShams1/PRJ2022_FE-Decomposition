clc
clear
close all

% Specify the path to the JSON filesß

file_dir = dir('../data/*Exp02*');
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
    cnd_single1 = strcmp(cnd_proben,'single1');
    cnd_single2 = strcmp(cnd_proben,'single2');
    click1_x = cell2mat(struct2cell(jsonData.click1_xloc)) * click_coeff;
    click2_x = struct2cell(jsonData.click2_xloc);
    click2_x(cellfun(@isempty, click2_x)) = {NaN};
    click2_x = cell2mat(click2_x) * click_coeff;
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

    lead2_vec = click1_err_vec;  % as the subjs had to click in order of appearance
    lead2_vec(~cnd_double) = nan;
    lead2(isub,1) = nanmean(lead2_vec);

    trail2_vec = click2_err_vec;
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
%%%%% Figure 3A
figure('units','inches','outerposition',[7, 4, 6, 4.5])

subplot(1,3,[1 2])
pbaspect([1.8 1 1])
set(gca,'ydir','reverse')
hold on

c = lines(7);
clead = c(1,:);
ctrail = c(2,:);
cfill1 = zeros(1,3);
cfill2 = c(5,:) * .85;
fill_alpha = .15;
xtick_vec = -5:6;
ytick_vec = [1.5, 5.5];

cmap = [ctrail;clead;ctrail;clead];
scatterbarh({trail1, lead1, trail2, lead2},cmap)

xline(0, 'linestyle','--')

xlabel({'Position shift (dva)', '(in direction of motion)'})
xticks(-4:5)
xlim([xtick_vec(1) xtick_vec(end)])

yticks(ytick_vec)
set(gca,'YColor','none')
ylim([0 6])

text(-4.8, 1.5, 'One-probe', 'color', cfill1, 'horizontalalignment','right')
text(-4.8, 4.5, 'Two-probe', 'color', cfill2, 'horizontalalignment','right')

text(-.25,-.35,'Terminating probe','color',ctrail,'horizontalalignment','right')
text(.25,-.35,'Initiating probe','color',clead,'horizontalalignment','left')

offset = .15;

fill_obj = fill([-4 5.5 5.5 -4], [0+offset 0+offset 3-offset 3-offset], cfill1);
fill_obj.LineWidth = 3;
fill_obj.FaceAlpha = fill_alpha;
fill_obj.EdgeColor = 'none';

fill_obj = fill([-4 5.5 5.5 -4], [3+offset 3+offset 6-offset 6-offset], cfill2);
fill_obj.LineWidth = 3;
fill_obj.FaceAlpha = fill_alpha;
fill_obj.EdgeColor = 'none';

cleanplot

%%% ---------------------------------
%%% stat fig 3A

%%% all vs baseline
[med, p, W, z, r] = signrank_full(trail1);
fprintf('<trail1> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

[med, p, W, z, r] = signrank_full(lead1);
fprintf('<lead1 > md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

[med, p, W, z, r] = signrank_full(trail2);
fprintf('<trail2> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

[med, p, W, z, r] = signrank_full(lead2);
fprintf('<lead2 > md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n\n', ...
med,W,z,p,r)

text(-3.5, 1, '\it n.s.', 'color', 'k', 'horizontalalignment','center')
text(5, 2, '***', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')
text(-3.5, 4, '*', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')
text(5, 5, '***', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')

%%% trail1 vs trail2
[med, p, W, z, r] = signrank_full(trail2,trail1);
fprintf('<trail1 vs trail2> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

line([-4.2 -4.2], [1 4], 'color', 'k', 'linewidth', 2)
text(-4.5, 2.5, '*', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')

%%% lead1 vs lead2
[med, p, W, z, r] = signrank_full(lead2,lead1);
fprintf('<lead1  vs lead2 > md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

line([5.7 5.7], [2 5], 'color', 'k', 'linewidth', 2)
text(6, 3.5, '*', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')

%%% =====================================================================================
%%%%% Figure 3B
subplot(1,3,3)
hold on

one_probe_dist = abs(lead1-trail1);
two_probe_dist = abs(lead2-trail2);

cmap = [0 0 0; c(5,:) .* .85];
xs = scatterbar({one_probe_dist, two_probe_dist},50,cmap);
plot(xs', [one_probe_dist, two_probe_dist]','color',[.5 .5 .5])

yline(0, 'linestyle','--')
yline(6, 'linestyle','--')

xticks([1 2])
xticklabels({'One-probe', 'Two-probe'})
xlim([.5 2.5])

ylabel({'Distance between two clicks (dva)'})
yticks(-4:6)
ylim([-.5 6.2])

cleanplot

%%% stats
[med, p, W, z, r] = signrank_full(two_probe_dist,one_probe_dist);
fprintf('\n<One-probe vs Two-probe> md = %4.1f dva, W = %5d, z = %5.2f, p = %5.3f, r = %4.2f \n', ...
med,W,z,p,r)

fprintf('<One-probe> md = %4.1f dva\n', median(one_probe_dist))
fprintf('<Two-probe> md = %4.1f dva\n', median(two_probe_dist))
fprintf('<Two-probe/Travel distance> %4.1f %%\n', median(two_probe_dist)/6*100)
fprintf('<Two-probe increase> %4.1f %%\n', ...
    median((two_probe_dist-one_probe_dist)./one_probe_dist*100))

line([1 2], [6.2 6.2], 'color', 'k', 'linewidth', 2)
text(1.5, 6.3, '***', 'fontsize', 18, 'color', 'k', 'horizontalalignment','center')
text(.55, 5.8, 'Travel path length')
%%% =====================================================================================
saveas(gcf, '../results/fig03AB.pdf')


function scatterbarh(A,c)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .05; % standard deviation of scatters in each category
linelm  = .6; % line length for median
marksz = 50;
alpha = .5;

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    
    offset = icat;
    if icat >2
        offset = offset+1;
    end

    y = randn(n,1)*stdx + offset;
    
    scatter(A{icat},y, ...
        marksz, c(icat,:), 'o', 'filled', 'markerfacealpha', alpha);
    line([nanmedian(A{icat}) nanmedian(A{icat})],...
        [offset-linelm offset+linelm], ...
        'color',c(icat,:),'linewidth',3);
end
end

function xs = scatterbar(A,marksz,c)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .05; % standard deviation of scatters in each category
linelm  = .4; % line length for median
lw = 3;
alpha = .4;

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    xs(:,icat) = x;
    
    scatter(x,A{icat}, ...
        marksz, c(icat,:), 'o', 'filled', 'markerfacealpha', alpha);
    line([icat-linelm icat+linelm],[nanmedian(A{icat}) nanmedian(A{icat})],...
        'color',c(icat,:),'linewidth',lw);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)
end
