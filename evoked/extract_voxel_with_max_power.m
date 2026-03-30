%%  Script to extract the voxel with maximum power change

close all
clear
clc

% Run the study configuration
p = opm_study_config_faces_voxelwise();

% Window parameters
active_window = [0.1 0.4]; % for overall evoked response
baseline_window = [-0.5 0]; 

% Set to 1 you want to save the output variables
save_data = 0;

%% Plot logistics

% Extract time
temp = load(p.sourcemodel.grid.ts.ve(p.subject(1), p.session(1), p.run(1),p.task(1)));
time = temp.time';

% Load meshes for plotting
load('/d/mjt/9/projects/OPM/opm_pipeline_templates/Adult/meshes.mat');

% Colorbar limits
global_clim = [-3, 3];

%% Loop over subjects
n_sub = size(p.subject_data, 1);
maxpower_data_l = zeros(n_sub, length(time));
maxpower_data_r = zeros(n_sub, length(time));
coords_max_l = zeros(n_sub, 3);
coords_max_r = zeros(n_sub, 3);

for ss = 1:size(p.subject_data, 1)
    disp(ss)
    %% Load data
    disp('Loading data')
    VE = load(p.sourcemodel.grid.ts.ve(p.subject(ss), p.session(ss), p.run(ss), p.task(ss)));
    ts_temp = mean(VE.ts, 3); % voxels x timestamps

    % Get the coordinates for plotting
    coords = VE.pos_coord_MNI*1e-3;

    % Some voxels are warped outside of the brain during registration. They
    % get masked, and the corresponding timeseries will be NaN. Therefore,
    % remove the NaNs first:
    rows_with_nan = any(isnan(ts_temp), 2);
    ts_temp(rows_with_nan, :) = [];
    coords(rows_with_nan, :) = [];

    % Get left and right hemisphere separately
    ts_l = ts_temp(coords(:,1)<0,:);
    ts_r = ts_temp(coords(:,1)>0,:);
    coords_l = coords(coords(:,1)<0, :, :);
    coords_r = coords(coords(:,1)>0, :, :);
    
    %% Get window indices

    active_idx = active_window(1) <= time & time <= active_window(2); 
    baseline_idx = baseline_window(1) <= time & time <= baseline_window(2); 
   
    %% z-scoring over baseline
    disp('z-scoring')
    z_ts_l = z_score(ts_l, baseline_idx);
    z_ts_r = z_score(ts_r, baseline_idx);

    %% Find channel with max change in power in active versus baseline window
    power_change_l = ( rms(z_ts_l(:, active_idx)') - rms(z_ts_l(:, baseline_idx)') )./ rms(z_ts_l(:, baseline_idx)');
    power_change_r = ( rms(z_ts_r(:, active_idx)') - rms(z_ts_r(:, baseline_idx)') )./ rms(z_ts_r(:, baseline_idx)');
    [~, max_power_idx_l] = max(power_change_l);
    [~, max_power_idx_r] = max(power_change_r);
    ts_max_l = z_ts_l(max_power_idx_l, :);
    ts_max_r = z_ts_r(max_power_idx_r, :);
    
    %% Polarity matching
    % Correlate all channels with a reference, and flip them
    % if correlation is negative to make nicer plots

    % Match polarity
    disp('matching polarity')
    [rhos, ts_max_l] = match_polarity(ts_max_l, ts_max_r, active_idx);

    %% Store the data
    disp('storing data')
    maxpower_data_l(ss,:) = ts_max_l;
    maxpower_data_r(ss,:) = ts_max_r;
    coords_max_l(ss, :) = coords_l(max_power_idx_l, :);
    coords_max_r(ss, :) = coords_r(max_power_idx_r, :);
end

%% Plot the timeseries data
disp('plotting')
nplots = n_sub/2;
nrows = 4;
ncols = ceil(nplots/nrows);

figure('Name','ASD','Units','normalized', 'outerposition', [0, 0, 1, 1])
for ss = 1:nplots
    subplot(nrows, ncols, ss)
    hold on
    plot(time, squeeze(maxpower_data_l(ss,:)))
    plot(time, squeeze(maxpower_data_r(ss,:)))
    xline([0.1])
    yline([-3, 3])
    hold off
    ylim([-10 10])
    xlim([-0.1 0.5])
    title(char(p.subject(ss)))
end
legend({'left'; 'right'})

figure('Name','TDC','Units','normalized', 'outerposition', [0, 0, 1, 1])
for ss = 1+nplots : nplots+nplots
    subplot(nrows, ncols, ss-nplots)
    hold on
    plot(time, squeeze(maxpower_data_l(ss, :)))
    plot(time, squeeze(maxpower_data_r(ss, :)))
    xline([0.1])
    yline([-3, 3])
    hold off
    ylim([-10 10])
    xlim([-0.1 0.5])
    title(char(p.subject(ss)))
end
legend({'left'; 'right'})

%% Plot the voxels with max power in glass brain
% Generate N unique colors (one per subject)
colors = lines(n_sub);

figure
subplot(2, 2, 1)
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
hold on
for s = 1:n_sub
    % left dot
    scatter3(coords_max_l(s,1), ...
             coords_max_l(s,2), ...
             coords_max_l(s,3), ...
             50, colors(s,:), 'filled');
    % right dot (same color)
    scatter3(coords_max_r(s,1), ...
             coords_max_r(s,2), ...
             coords_max_r(s,3), ...
             50, colors(s,:), 'filled');
end
view([0, 0])

subplot(2, 2, 2)
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
hold on
for s = 1:n_sub
   % left dot
    scatter3(coords_max_l(s,1), ...
             coords_max_l(s,2), ...
             coords_max_l(s,3), ...
             50, colors(s,:), 'filled');
    % right dot (same color)
    scatter3(coords_max_r(s,1), ...
             coords_max_r(s,2), ...
             coords_max_r(s,3), ...
             50, colors(s,:), 'filled');
end
view([90, 0])

subplot(2, 2, 3)
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
hold on
for s = 1:n_sub
    % left dot
    scatter3(coords_max_l(s,1), ...
             coords_max_l(s,2), ...
             coords_max_l(s,3), ...
             50, colors(s,:), 'filled');
    % right dot (same color)
    scatter3(coords_max_r(s,1), ...
             coords_max_r(s,2), ...
             coords_max_r(s,3), ...
             50, colors(s,:), 'filled');
end
view([90, 90])

%% Plot voxels by group
idx_asd = strcmp(p.subject_data.dx,'ASD');
idx_tdc = strcmp(p.subject_data.dx,'TDC');

figure
subplot(2, 2, 1)
hold on
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
% left dot
scatter3(coords_max_l(idx_asd,1), ...
    coords_max_l(idx_asd,2), ...
    coords_max_l(idx_asd,3), ...
    50,'red', 'filled');
% right dot (same color)
scatter3(coords_max_r(idx_asd,1), ...
    coords_max_r(idx_asd,2), ...
    coords_max_r(idx_asd,3), ...
    50, 'red', 'filled');
% left dot
scatter3(coords_max_l(idx_tdc,1), ...
    coords_max_l(idx_tdc,2), ...
    coords_max_l(idx_tdc,3), ...
    50,'blue', 'filled');
% right dot (same color)
scatter3(coords_max_r(idx_tdc,1), ...
    coords_max_r(idx_tdc,2), ...
    coords_max_r(idx_tdc,3), ...
    50, 'blue', 'filled');
view([0, 0])



subplot(2, 2, 2)
hold on
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
% left dot
scatter3(coords_max_l(idx_asd,1), ...
    coords_max_l(idx_asd,2), ...
    coords_max_l(idx_asd,3), ...
    50,'red', 'filled');
% right dot (same color)1
scatter3(coords_max_r(idx_asd,1), ...
    coords_max_r(idx_asd,2), ...
    coords_max_r(idx_asd,3), ...
    50, 'red', 'filled');
% left dot
scatter3(coords_max_l(idx_tdc,1), ...
    coords_max_l(idx_tdc,2), ...
    coords_max_l(idx_tdc,3), ...
    50,'blue', 'filled');
% right dot (same color)
scatter3(coords_max_r(idx_tdc,1), ...
    coords_max_r(idx_tdc,2), ...
    coords_max_r(idx_tdc,3), ...
    50, 'blue', 'filled');
view([90, 0])


subplot(2, 2, 3)
hold on
ft_plot_mesh(meshes(1:2), 'facecolor', [.5 .5 .5], 'facealpha', .3, 'edgecolor', 'none')
% left dot
scatter3(coords_max_l(idx_asd,1), ...
    coords_max_l(idx_asd,2), ...
    coords_max_l(idx_asd,3), ...
    50,'red', 'filled');
% right dot (same color)
scatter3(coords_max_r(idx_asd,1), ...
    coords_max_r(idx_asd,2), ...
    coords_max_r(idx_asd,3), ...
    50, 'red', 'filled');
% left dot
scatter3(coords_max_l(idx_tdc,1), ...
    coords_max_l(idx_tdc,2), ...
    coords_max_l(idx_tdc,3), ...
    50,'blue', 'filled');
% right dot (same color)
scatter3(coords_max_r(idx_tdc,1), ...
    coords_max_r(idx_tdc,2), ...
    coords_max_r(idx_tdc,3), ...
    50, 'blue', 'filled');
view([90, 90])



%% Save data
if save_data == 1
    save('fusiform_l.mat', 'maxpower_data_l');
    save('fusiform_r.mat', 'maxpower_data_r');
    save('coords_ffg_l.mat', 'coords_max_l')
    save('coords_ffg_r.mat', 'coords_max_r')
end

%% Helper functions

function [rhos, aligned] = match_polarity(data, reference, window)
% Correlates channels in data with specified reference channel to match
% polarity 
% data = channels x timestamps
% reference = 1 x timestamps

% Preallocate memory
aligned = zeros(size(data));  
rhos = zeros(size(data, 1), 1);

% Loop through channels
for ch = 1:size(data, 1)
    rho = corr(reference(window)', data(ch, window)', 'Type','Spearman');
    if rho < 0
        aligned(ch, :) = -data(ch, :);
    else
        aligned(ch, :) = data(ch, :);
    end
    rhos(ch) = rho;
end

end

function z_ts = z_score(ts, baseline_idx)
% z-scores the individual channels in ts
% assuming:
% ts = channels x timestamps 
% baseline_idx = logical array of size 1xtimestamps or timestampsx1 

mean_baseline = mean(ts(:, baseline_idx), 2);
std_baseline = std(ts(:, baseline_idx), [], 2);
z_ts = (ts - mean_baseline)./std_baseline;
end


