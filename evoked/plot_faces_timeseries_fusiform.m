close all
clear
clc


%% Load data

% Run the study configuration
p = opm_study_config_faces_voxelwise();

% Load
fusiform_l = importdata('fusiform_l.mat');
fusiform_r = importdata('fusiform_r.mat');
load('time.mat')

srstotal = p.subject_data.srs_total_T_merged;

active_win = [0.1 0.4]; active_idx = active_win(1) <= time & time <= active_win(2);
baseline_win = [-0.5 0]; baseline_idx = baseline_win(1)<= time & time <= baseline_win(2);

%% Flip if needed

% Get flip parameters
flip_l = p.subject_data.ffg_flip_l; 
flip_r = p.subject_data.ffg_flip_r; 

fusiform_l(flip_l == 1, :) = -fusiform_l(flip_l == 1, :);
fusiform_r(flip_r == 1, :) = -fusiform_r(flip_r == 1, :);

%% Group data
num_subjects = size(p.subject_data, 1);
ts_tdc = zeros(2, length(time), num_subjects/2);
ts_asd = zeros(2, length(time), num_subjects/2);

ffg_l = 1;
ffg_r = 2;

ts_tdc(ffg_l, :, :) = fusiform_l(strcmp(p.subject_data.dx, "TDC"), :)';
ts_tdc(ffg_r, :, :) = fusiform_r(strcmp(p.subject_data.dx, "TDC"), :)';
ts_asd(ffg_l, :, :) = fusiform_l(strcmp(p.subject_data.dx, "ASD"), :)';
ts_asd(ffg_r, :, :) = fusiform_r(strcmp(p.subject_data.dx, "ASD"), :)';

p_asd = p.subject_data(strcmp(p.subject_data.dx, 'ASD'), :);
p_tdc = p.subject_data(strcmp(p.subject_data.dx, 'TDC'), :);

%% Calculate mean and std
[mean_tdc, std_tdc, std_err_tdc] = compute_stats((ts_tdc));
[mean_asd, std_asd, std_err_asd] = compute_stats((ts_asd));

[meanabs_tdc, stdabs_tdc, std_errabs_tdc] = compute_stats(abs(ts_tdc));
[meanabs_asd, stdabs_asd, std_errabs_asd] = compute_stats(abs(ts_asd));

%% Get peaks M170
m170_amp_asd = zeros(2, num_subjects/2);
m170_amp_tdc = zeros(2, num_subjects/2);
m170_lat_asd = zeros(2, num_subjects/2);
m170_lat_tdc = zeros(2, num_subjects/2);

m170_lat_asd(ffg_l, :) = p_asd.ffg_lat_l;
m170_lat_asd(ffg_r, :) = p_asd.ffg_lat_r;
m170_lat_tdc(ffg_l, :) = p_tdc.ffg_lat_l;
m170_lat_tdc(ffg_r, :) = p_tdc.ffg_lat_r;

m170_amp_asd(ffg_l, :) = p_asd.ffg_amp_l;
m170_amp_asd(ffg_r, :) = p_asd.ffg_amp_r;
m170_amp_tdc(ffg_l, :) = p_tdc.ffg_amp_l;
m170_amp_tdc(ffg_r, :) = p_tdc.ffg_amp_r;


%% Get peaks M100
m100_amp_asd = zeros(2, num_subjects/2);
m100_amp_tdc = zeros(2, num_subjects/2);
m100_lat_asd = zeros(2, num_subjects/2);
m100_lat_tdc = zeros(2, num_subjects/2);

m100_lat_asd(ffg_l, :) = p_asd.ffg_p1_lat_l;
m100_lat_asd(ffg_r, :) = p_asd.ffg_p1_lat_r;
m100_lat_tdc(ffg_l, :) = p_tdc.ffg_p1_lat_l;
m100_lat_tdc(ffg_r, :) = p_tdc.ffg_p1_lat_r;

m100_amp_asd(ffg_l, :) = p_asd.ffg_p1_amp_l;
m100_amp_asd(ffg_r, :) = p_asd.ffg_p1_amp_r;
m100_amp_tdc(ffg_l, :) = p_tdc.ffg_p1_amp_l;
m100_amp_tdc(ffg_r, :) = p_tdc.ffg_p1_amp_r;


%% color settings
cmap = lines();
RGB = orderedcolors("gem");
H = rgb2hex(RGB);

asd_color = hex2rgb('#ed5b00');
tdc_color = RGB(6, :);

%% Plot global means per diagnosis

% Set the colormap
cmap = lines();

figure
subplot(1, 2, 1)
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_tdc(ffg_l, :), std_err_tdc(ffg_l, :), 'lineProps', lineProps);
lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_asd(ffg_l, :), std_err_asd(ffg_l, :), 'lineProps', lineProps);

xlim([-0.2 0.7])
xlabel('Time (s)')
ylabel('Amplitude (a.u.)')
title('Left fusiform gyrus')
ax = gca;
ax.FontSize = 20;
ax.Title.FontSize = 20;
ax.XLabel.FontSize = 20;
ax.YLabel.FontSize = 20;
ax.LineWidth = 2;

subplot(1, 2, 2)
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_tdc(ffg_r, :), std_err_tdc(ffg_r, :), 'lineProps', lineProps);

lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_asd(ffg_r, :), std_err_asd(ffg_r, :), 'lineProps', lineProps);
xlim([-0.2 0.7])
xlabel('Time (s)')
ylabel('Amplitude (a.u.)')
lgd = legend({'NT', 'AU'});

title('Right fusiform gyrus')

% Figure properties
fig = gcf;
fig.Position = [50, 50, 1000, 400];

ax = gca;
ax.FontSize = 20;
ax.Title.FontSize = 20;
ax.XLabel.FontSize = 20;
ax.YLabel.FontSize = 20;
ax.LineWidth = 2;

lgd.FontSize = 14;

%% Plot individual data

nplots = num_subjects/2;
nrows = 4;
ncols = ceil(nplots/nrows);

figure('Name','TDC')
for ss = 1:nplots
    subplot(nrows, ncols, ss)
    hold on
    plot(time, (squeeze(ts_tdc(ffg_l,:,ss))))
    plot(time, (squeeze(ts_tdc(ffg_r,:,ss))))
    %plot(time, mean_tdc(ffg_l, :), 'b')
    %plot(time, mean_tdc(ffg_r, :), 'r')
    plot(m170_lat_tdc(ffg_l,ss), m170_amp_tdc(ffg_l, ss), 'ob', 'MarkerFaceColor','b')
    plot(m170_lat_tdc(ffg_r,ss), m170_amp_tdc(ffg_r, ss), 'or', 'MarkerFaceColor','r')
    plot(m100_lat_tdc(ffg_l,ss), m100_amp_tdc(ffg_l, ss), 'ob', 'MarkerFaceColor','b')
    plot(m100_lat_tdc(ffg_r,ss), m100_amp_tdc(ffg_r, ss), 'or', 'MarkerFaceColor','r')
    patch([0.13, 0.21, 0.21, 0.13], [-10 -10 10 10], [0.5, 0.5, 0.5], 'EdgeColor','none','FaceAlpha',0.2)
    xline([0.1])
    yline([-3, 3])
    hold off
    ylim([-10 10])
    xlim([-0.1 0.5])
    title(char(p_tdc.subject(ss)))
    %legend({'Left'; 'Right'})

end

nplots = size(p_asd, 1);
nrows = 4;
ncols = ceil(nplots/nrows);

figure('Name','ASD')
for ss = 1:nplots
    subplot(nrows, ncols, ss)
    hold on
    plot(time, (ts_asd(ffg_l,:,ss)))
    plot(time, (ts_asd(ffg_r,:,ss)))
    %plot(time, mean_asd(ffg_l, :), 'b')
    %plot(time, mean_asd(ffg_r, :), 'r')
    plot(m170_lat_asd(ffg_l,ss), m170_amp_asd(ffg_l, ss), 'ob', 'MarkerFaceColor','b')
    plot(m170_lat_asd(ffg_r,ss), m170_amp_asd(ffg_r, ss), 'or', 'MarkerFaceColor','r')
    plot(m100_lat_asd(ffg_l,ss), m100_amp_asd(ffg_l, ss), 'ob', 'MarkerFaceColor','b')
    plot(m100_lat_asd(ffg_r,ss), m100_amp_asd(ffg_r, ss), 'or', 'MarkerFaceColor','r')
    
    patch([0.13, 0.21, 0.21, 0.13], [-10 -10 10 10], [0.5, 0.5, 0.5], 'EdgeColor','none','FaceAlpha',0.2)

    xline([0.1])
    yline([-3, 3])
    hold off
    ylim([-10 10])
    xlim([-0.1 0.5])
    title(char(p_asd.subject(ss)))
    %legend(['Left'; 'Right'])
end


%% Manuscript figure 2 - M170 & boxplots

figure('Position', [0, 0, 1200, 1200]);
t = tiledlayout(3, 2, "TileSpacing",'Compact', 'Padding','compact');

% Amplitude left
nexttile([1, 1])
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_tdc(ffg_l, :), std_err_tdc(ffg_l, :), 'lineProps', lineProps);
lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_asd(ffg_l, :), std_err_asd(ffg_l, :), 'lineProps', lineProps);
xlabel('Time (s)')
ylabel(sprintf('Amplitude (a.u.)'))
title('Left fusiform gyrus')
ax = gca;
format_axes(ax);
xlim([-0.2 0.7])
ylim([-5 5])

% Amplitude right
nexttile([1, 1])
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_tdc(ffg_r, :), std_err_tdc(ffg_r, :), 'lineProps', lineProps);
lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, mean_asd(ffg_r, :), std_err_asd(ffg_r, :), 'lineProps', lineProps);
xlabel('Time (s)')
ylabel(sprintf('Amplitude (a.u.)'))
lgd = legend({'NT', 'ASD'});
title('Right fusiform gyrus')
ax = gca;
format_axes(ax);
format_legend(lgd);
xlim([-0.2 0.7])
ylim([-5 5])


%%%% Boxplot M100 amplitude
nexttile([1, 1])

amplitude = [p.subject_data.ffg_p1_amp_l; p.subject_data.ffg_p1_amp_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
hemi = [repmat('L', num_subjects, 1); repmat('R', num_subjects, 1)];
valid = ~isnan(amplitude);
grouping_variables = {dx(valid), hemi(valid)};

boxplot(amplitude(valid), grouping_variables, ...
    'Labels',{'ASD L', 'ASD R', 'NT L', 'NT R'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(3),'XData'), get(h(3),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(4),'XData'), get(h(4),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');

set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('M100 amplitude (a.u.)'))
ax = gca;
format_axes(ax);
%ylim([-12,0])
xlim([0, 5])



%%%%
% Boxplot M100 latency
nexttile([1, 1])
hold on

latency = [p.subject_data.ffg_p1_lat_l; p.subject_data.ffg_p1_lat_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
hemi = [repmat('L', num_subjects, 1); repmat('R', num_subjects, 1)];

valid = ~isnan(latency);
grouping_variables = {dx(valid), hemi(valid)};


boxplot(latency(valid), grouping_variables, ...
    'Labels',{'ASD L', 'ASD R', 'NT L', 'NT R'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')



% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(3),'XData'), get(h(3),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(4),'XData'), get(h(4),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');

set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('M100 latency (s)'))
ax = gca;
format_axes(ax);
ylim([0.07, 0.15])
xlim([0, 5])

%%%% Boxplot M170 amplitude
nexttile([1, 1])

amplitude = [p.subject_data.ffg_amp_l; p.subject_data.ffg_amp_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
hemi = [repmat('L', num_subjects, 1); repmat('R', num_subjects, 1)];
valid = ~isnan(amplitude);
grouping_variables = {dx(valid), hemi(valid)};

boxplot(amplitude(valid), grouping_variables, ...
    'Labels',{'ASD L', 'ASD R', 'NT L', 'NT R'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(3),'XData'), get(h(3),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(4),'XData'), get(h(4),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');

set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('M170 amplitude (a.u.)'))
ax = gca;
format_axes(ax);
ylim([-12,0])
xlim([0, 5])



%%%%
% Boxplot M170 latency
nexttile([1, 1])
hold on

latency = [p.subject_data.ffg_lat_l; p.subject_data.ffg_lat_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
hemi = [repmat('L', num_subjects, 1); repmat('R', num_subjects, 1)];

valid = ~isnan(latency);
grouping_variables = {dx(valid), hemi(valid)};


boxplot(latency(valid), grouping_variables, ...
    'Labels',{'ASD L', 'ASD R', 'NT L', 'NT R'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')



% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(3),'XData'), get(h(3),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(4),'XData'), get(h(4),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');

set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('M170 latency (s)'))
ax = gca;
format_axes(ax);
ylim([0.1, 0.25])
xlim([0, 5])




%% Manuscript figure 3 - SRS total regression
% Extract variables
m170_amp_l = p.subject_data.ffg_amp_l;
m170_amp_r = p.subject_data.ffg_amp_r;
m170_lat_l = p.subject_data.ffg_lat_l;
m170_lat_r = p.subject_data.ffg_lat_r;

m100_amp_l = p.subject_data.ffg_p1_amp_l;
m100_amp_r = p.subject_data.ffg_p1_amp_r;
m100_lat_l = p.subject_data.ffg_p1_lat_l;
m100_lat_r = p.subject_data.ffg_p1_lat_r;

figure('Position', [50, 50, 1200, 400]);
t = tiledlayout(2, 2, "TileSpacing",'Compact', 'Padding','compact');

% M100
nexttile([1,1])
hold on
scatter(srstotal, m100_amp_l, 'MarkerFaceColor', H(1), 'MarkerEdgeColor', 'None')
scatter(srstotal, m100_amp_r, 'MarkerFaceColor', H(6), 'MarkerEdgeColor', 'None')
xlabel('SRS-2 total \itT\rm-score')
ylabel(sprintf('M100 amplitude (a.u.)'))
%lgd = legend({'Left hemisphere', 'Right hemisphere'});

% Fit linear regression model
mdl_l = fitlm(srstotal, m100_amp_l);
mdl_r = fitlm(srstotal, m100_amp_r);

% Generate line for regression fit
xx = linspace(min(srstotal), max(srstotal), 100)';
[yl, CIl] = predict(mdl_l, xx);
[yr, CIr] = predict(mdl_r, xx);

% Confidence interval as a shaded area
cil = fill([xx; flipud(xx)], [CIl(:,1); flipud(CIl(:,2))], RGB(1, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
cir = fill([xx; flipud(xx)], [CIr(:,1); flipud(CIr(:,2))], RGB(6, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');


line_l = plot(xx, yl, 'Color', H(1), 'LineWidth', 2);
line_r = plot(xx, yr, 'Color', H(6), 'LineWidth', 2);

line_l.Annotation.LegendInformation.IconDisplayStyle = 'off';
line_r.Annotation.LegendInformation.IconDisplayStyle = 'off';
cil.Annotation.LegendInformation.IconDisplayStyle = 'off';
cir.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax = gca;
format_axes(ax);
%format_legend(lgd);
%lgd.Location = 'southeast';
%xlim([33 91])
%ylim([-2.5, 2.5])
axis tight


nexttile([1,1])
hold on
scatter(srstotal, m100_lat_l, 'MarkerFaceColor', H(1), 'MarkerEdgeColor', 'None')
scatter(srstotal, m100_lat_r, 'MarkerFaceColor', H(6), 'MarkerEdgeColor', 'None')
xlabel('SRS-2 total \itT\rm-score')
ylabel(sprintf('M100 latency (s)'))
%lgd = legend({'Left hemisphere', 'Right hemisphere'});

% Fit linear regression model
mdl_l = fitlm(srstotal, m100_lat_l);
mdl_r = fitlm(srstotal, m100_lat_r);

% Generate line for regression fit
xx = linspace(min(srstotal), max(srstotal), 100)';
[yl, CIl] = predict(mdl_l, xx);
[yr, CIr] = predict(mdl_r, xx);

% Confidence interval as a shaded area
cil = fill([xx; flipud(xx)], [CIl(:,1); flipud(CIl(:,2))], RGB(1, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
cir = fill([xx; flipud(xx)], [CIr(:,1); flipud(CIr(:,2))], RGB(6, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');


line_l = plot(xx, yl, 'Color', H(1), 'LineWidth', 2);
line_r = plot(xx, yr, 'Color', H(6), 'LineWidth', 2);

line_l.Annotation.LegendInformation.IconDisplayStyle = 'off';
line_r.Annotation.LegendInformation.IconDisplayStyle = 'off';
cil.Annotation.LegendInformation.IconDisplayStyle = 'off';
cir.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax = gca;
format_axes(ax);
%format_legend(lgd);
%xlim([33 91])
%ylim([-2.5, 2.5])
axis tight

% M170
nexttile([1,1])
hold on
scatter(srstotal, m170_amp_l, 'MarkerFaceColor', H(1), 'MarkerEdgeColor', 'None')
scatter(srstotal, m170_amp_r, 'MarkerFaceColor', H(6), 'MarkerEdgeColor', 'None')
xlabel('SRS-2 total \itT\rm-score')
ylabel(sprintf('M170 amplitude (a.u.)'))
lgd = legend({'Left hemisphere', 'Right hemisphere'});

% Fit linear regression model
mdl_l = fitlm(srstotal, m170_amp_l);
mdl_r = fitlm(srstotal, m170_amp_r);

% Generate line for regression fit
xx = linspace(min(srstotal), max(srstotal), 100)';
[yl, CIl] = predict(mdl_l, xx);
[yr, CIr] = predict(mdl_r, xx);

% Confidence interval as a shaded area
cil = fill([xx; flipud(xx)], [CIl(:,1); flipud(CIl(:,2))], RGB(1, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
cir = fill([xx; flipud(xx)], [CIr(:,1); flipud(CIr(:,2))], RGB(6, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');


line_l = plot(xx, yl, 'Color', H(1), 'LineWidth', 2);
line_r = plot(xx, yr, 'Color', H(6), 'LineWidth', 2);

line_l.Annotation.LegendInformation.IconDisplayStyle = 'off';
line_r.Annotation.LegendInformation.IconDisplayStyle = 'off';
cil.Annotation.LegendInformation.IconDisplayStyle = 'off';
cir.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax = gca;
format_axes(ax);
format_legend(lgd);
lgd.Location = 'southeast';
%xlim([33 91])
%ylim([-2.5, 2.5])
axis tight


nexttile([1,1])
hold on
scatter(srstotal, m170_lat_l, 'MarkerFaceColor', H(1), 'MarkerEdgeColor', 'None')
scatter(srstotal, m170_lat_r, 'MarkerFaceColor', H(6), 'MarkerEdgeColor', 'None')
xlabel('SRS-2 total \itT\rm-score')
ylabel(sprintf('M170 latency (s)'))
%lgd = legend({'Left hemisphere', 'Right hemisphere'});

% Fit linear regression model
mdl_l = fitlm(srstotal, m170_lat_l);
mdl_r = fitlm(srstotal, m170_lat_r);

% Generate line for regression fit
xx = linspace(min(srstotal), max(srstotal), 100)';
[yl, CIl] = predict(mdl_l, xx);
[yr, CIr] = predict(mdl_r, xx);

% Confidence interval as a shaded area
cil = fill([xx; flipud(xx)], [CIl(:,1); flipud(CIl(:,2))], RGB(1, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
cir = fill([xx; flipud(xx)], [CIr(:,1); flipud(CIr(:,2))], RGB(6, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');


line_l = plot(xx, yl, 'Color', H(1), 'LineWidth', 2);
line_r = plot(xx, yr, 'Color', H(6), 'LineWidth', 2);

line_l.Annotation.LegendInformation.IconDisplayStyle = 'off';
line_r.Annotation.LegendInformation.IconDisplayStyle = 'off';
cil.Annotation.LegendInformation.IconDisplayStyle = 'off';
cir.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax = gca;
format_axes(ax);
%format_legend(lgd);
%xlim([33 91])
%ylim([-2.5, 2.5])
axis tight

%% Manuscript supplementary figure 1 - magnitude & power
% Create figure
figure('Position', [50, 50, 1200, 800]);
t = tiledlayout(2, 2, "TileSpacing",'Compact', 'Padding','compact');

%Magnitude left
nexttile([1, 1])
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, meanabs_tdc(ffg_l, :), std_errabs_tdc(ffg_l, :), 'lineProps', lineProps);
lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, meanabs_asd(ffg_l, :), std_errabs_asd(ffg_l, :), 'lineProps', lineProps);
xlabel('Time (s)')
ylabel(sprintf('Magnitude (a.u.)'))
ax = gca;
format_axes(ax);
axis tight
xlim([-0.2 0.7])
ylim([0 5])
title('Left fusiform gyrus')


% Magnitude right
nexttile([1, 1])
hold on
lineProps = {'Color', cmap(1, :), 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, meanabs_tdc(ffg_r, :), std_errabs_tdc(ffg_r, :), 'lineProps', lineProps);
lineProps = {'Color', asd_color, 'LineWidth', 2, 'LineStyle','-'};
shadedErrorBar(time, meanabs_asd(ffg_r, :), std_errabs_asd(ffg_r, :), 'lineProps', lineProps);
xlabel('Time (s)')
ylabel(sprintf('Magnitude (a.u.)'))
ax = gca;
format_axes(ax);
axis tight
xlim([-0.2 0.7])
ylim([0 5])
title('Right fusiform gyrus')
lgd = legend({'NT', 'ASD'});
format_legend(lgd);

% Boxplot
nexttile([1, 1])

abs_l = abs(fusiform_l);
abs_r = abs(fusiform_r);

power_l = ( mean(abs_l(:, active_idx), 2) - mean(abs_l(:, baseline_idx), 2) ) ./ mean(abs_l(:, baseline_idx), 2);
power_r = ( mean(abs_r(:, active_idx), 2) - mean(abs_r(:, baseline_idx), 2) ) ./ mean(abs_r(:, baseline_idx), 2);

hold on

dx = repmat(p.subject_data.dx(:), 2, 1);
hemi = [repmat('L', num_subjects, 1); repmat('R', num_subjects, 1)];
grouping_variables = {dx, hemi};

boxplot([power_l; power_r], grouping_variables, ...
    'Labels', {'ASD L', 'ASD R', 'NT L', 'NT R'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(3),'XData'), get(h(3),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(4),'XData'), get(h(4),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('Signal power (a.u.)'))
ax = gca;
format_axes(ax);
%ylim([-2.5, 2.5])
xlim([0, 5])

%%%% Signal power
nexttile([1,1])
hold on
scatter(srstotal, power_l, 'MarkerFaceColor', H(1), 'MarkerEdgeColor', 'None')
scatter(srstotal, power_r, 'MarkerFaceColor', H(6), 'MarkerEdgeColor', 'None')
xlabel('SRS-2 total \itT\rm-score')
ylabel(sprintf('Signal power (a.u.)'))
lgd = legend({'Left hemisphere', 'Right hemisphere'});

% Fit linear regression model
mdl_l = fitlm(srstotal, power_l);
mdl_r = fitlm(srstotal, power_r);

% Generate line for regression fit
xx = linspace(min(srstotal), max(srstotal), 100)';
[yl, CIl] = predict(mdl_l, xx);
[yr, CIr] = predict(mdl_r, xx);

% Confidence interval as a shaded area
cil = fill([xx; flipud(xx)], [CIl(:,1); flipud(CIl(:,2))], RGB(1, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
cir = fill([xx; flipud(xx)], [CIr(:,1); flipud(CIr(:,2))], RGB(6, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');


line_l = plot(xx, yl, 'Color', H(1), 'LineWidth', 2);
line_r = plot(xx, yr, 'Color', H(6), 'LineWidth', 2);

line_l.Annotation.LegendInformation.IconDisplayStyle = 'off';
line_r.Annotation.LegendInformation.IconDisplayStyle = 'off';
cil.Annotation.LegendInformation.IconDisplayStyle = 'off';
cir.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax = gca;
format_axes(ax);
format_legend(lgd);
%xlim([33 91])
%ylim([-2.5, 2.5])
axis tight

%% Boxplots - collapsed across hemispheres for RI retreat poster

figure('Position', [50, 50, 1500, 370]);
t = tiledlayout(1, 3, "TileSpacing",'Compact', 'Padding','compact');

%%%% Peak amplitude
nexttile([1, 1])

amplitude = [p.subject_data.ffg_amp_l; p.subject_data.ffg_amp_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
valid = ~isnan(amplitude);

boxplot(amplitude(valid), {dx(valid)}, ...
    'Labels',{'Autism', 'NT'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('Peak amplitude (a.u.)'))
ax = gca;
format_axes(ax);
%ylim([-2.5, 2.5])
xlim([0, 3])


%%%%
% Peak latency
nexttile([1, 1])
hold on

latency = [p.subject_data.ffg_lat_l; p.subject_data.ffg_lat_r];
dx = repmat(p.subject_data.dx(:), 2, 1);
valid = ~isnan(latency);

boxplot(latency(valid), {dx(valid)}, ...
    'Labels',{'Autism', 'NT'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(1),'XData'), get(h(1),'YData'), RGB(6, :), 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(2),'XData'), get(h(2),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 14);

boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('Peak latency (s)'))
ax = gca;
format_axes(ax);
ylim([0.1, 0.25])
xlim([0, 3])



%%%% Power
nexttile([1, 1])

abs_l = abs(fusiform_l);
abs_r = abs(fusiform_r);
power_l = ( mean(abs_l(:, active_idx), 2) - mean(abs_l(:, baseline_idx), 2) ) ./ mean(abs_l(:, baseline_idx), 2);
power_r = ( mean(abs_r(:, active_idx), 2) - mean(abs_r(:, baseline_idx), 2) ) ./ mean(abs_r(:, baseline_idx), 2);

hold on
boxplot([power_l; power_r], [p.subject_data.dx; p.subject_data.dx], ...
    'Labels', {'Autism', 'NT'}, ...
    'Colors', 'k', ...            % box outline colour
    'Widths', 0.6, ...
    'BoxStyle', 'outline')

% Fill boxes manually
h = findobj(gca,'Tag','Box'); % Last child is returned first
patch(get(h(2),'XData'), get(h(2),'YData'), asd_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
patch(get(h(1),'XData'), get(h(1),'YData'), tdc_color, 'FaceAlpha', 0.5, 'EdgeColor','k');
boxlines = findobj(gca, 'Type', 'Line');
set(boxlines, 'LineWidth', 2)

ylabel(sprintf('Signal power (a.u.)'))
ax = gca;
format_axes(ax);
%ylim([-2.5, 2.5])
xlim([0, 3])








