%%  Script to organize data for NBS, dimensional

close all
clear
clc

load_connectivity_parameters

%% DEMEAN metric

metric_data = p.subject_data{:, metric};
metric_data = metric_data - mean(metric_data, 'all', 'omitmissing');

%% Create design matrix

num_subjects = length(p.subject_data.subject);

% Active window between group
designmat_corr = zeros(num_subjects, 2);
designmat_corr(:, 1) = ones(num_subjects, 1);
designmat_corr(:, 2) = metric_data;

% Remove subjects with missing data
designmat_corr(isnan(p.subject_data{:, metric}), :) = [];

% Remove outlier if one is specified in load_connectivity_parameters
new_outlier_idx = [];
if ~isempty(outlier_idx)
    idx_vector = 1:num_subjects;
    idx_vector(isnan(p.subject_data{:, metric})) = [];
    new_outlier_idx = find(idx_vector == outlier_idx);
    if ~isempty(new_outlier_idx)
        designmat_corr(new_outlier_idx,:) = [];
    end
end

figure
imagesc(designmat_corr)
title('Design matrix active window')

% Save
if ~isempty(new_outlier_idx)
    save([out_dir, '/nooutlier_nbsdesign.mat'], 'designmat_corr');
else
    save([out_dir, '/nbsdesign.mat'], 'designmat_corr');
end

%% Pre-loop logistics

% Extract the number of regions
num_regions = length(temp.pos_name);

% Load in all the timeseries data
conn_active_all = zeros(num_regions, num_regions, num_subjects);

%% Loop over subjects
for ss = 1:num_subjects
        disp(['Processing data for ', p.subject(ss)])
        
        z_adjmat = load_connectivity_data(p, ss, ff, baseline_ind); % 46x46x3000
       
        % Compute baseline mean and active window mean
        conn_active = mean(z_adjmat(:, :, active_ind), 3); % 46x46
        conn_baseline = mean(z_adjmat(:, :, baseline_ind), 3);

        % Plot for verification
        % colorlim = [min([conn_active(:); conn_baseline(:)]), max([conn_active(:); conn_baseline(:)])];
        % figure
        % subplot(1, 2, 1)
        % imagesc(conn_baseline)
        % colorbar
        % caxis(colorlim)
        % axis square;
        % title('Baseline window')
        % subplot(1, 2, 2)
        % imagesc(conn_active)
        % colorbar
        % caxis(colorlim)
        % axis square;
        % title('Active window')
       
        % Change nan into 0
        conn_active(isnan(conn_active))= 0;
        
        % Choose nodes of interest
        mask = zeros(num_regions,num_regions);
        mask(rois, :) = 1;
        mask(:, rois) = 1;
        conn_active_filtered = conn_active.*mask;        

        % % Plot for verification
        % colorlim = [min([conn_active(:); conn_baseline(:)]), max([conn_active(:); conn_baseline(:)])];
        % figure
        % subplot(1, 2, 1)
        % imagesc(conn_baseline_filtered)
        % colorbar
        % caxis(colorlim)
        % axis square;
        % title('Baseline window')
        % subplot(1, 2, 2)
        % imagesc(conn_active_filtered)
        % colorbar
        % caxis(colorlim)
        % axis square;
        % title('Active window')

        % Assign
        conn_active_all(:, :, ss) = conn_active_filtered;
end

%% Post-loop logistics

% Remove connectivity matrix if the metric is NaN
conn_active_all(:, :, isnan(p.subject_data{:, metric})) = [];

% Remove outlier
if ~isempty(new_outlier_idx)
    conn_active_all(:, :, new_outlier_idx) = [];
    save([out_dir, '/' num2str(baseline_win(1)) '-' num2str(baseline_win(2)) '_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nooutlier_nbsdata.mat'], 'conn_active_all');
else
    save([out_dir, '/' num2str(baseline_win(1)) '-' num2str(baseline_win(2)) '_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nbsdata.mat'], 'conn_active_all');
end

%% Plot means & std

conn_mean = mean(squeeze(conn_active_all(:, :, :)), 3);

colorlim = [min(conn_mean(:)), max(conn_mean(:))];
figure
imagesc(conn_mean)
colorbar
caxis(colorlim)
axis square;
title('Mean connectivity')

