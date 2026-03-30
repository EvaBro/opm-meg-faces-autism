%%  Script to organize data for NBS, case-control
close all
clear
clc

load_connectivity_parameters

%% Create design matrix and exchange blocks

subject_labels = p.subject_data.subject;
num_subjects = length(subject_labels);
idx_asd = strcmp(p.subject_data.dx, 'ASD');
idx_tdc = strcmp(p.subject_data.dx, 'TDC');

% Active vs. baseline within all subjects
designmat_within_all = zeros(2*num_subjects,1+num_subjects);
designmat_within_all(:, 1) = [-1*ones(num_subjects, 1); ones(num_subjects,1)];
designmat_within_all(:,2:end) = [eye(num_subjects); eye(num_subjects)];
exchangeblock_within_all = [1:num_subjects, 1:num_subjects];

figure
imagesc(designmat_within_all)
title('Design matrix active vs baseline within all subjects')

save([out_dir, '/within_all_nbsdesign.mat'], 'designmat_within_all');
save([out_dir, '/within_all_exchangeblocks.mat'], 'exchangeblock_within_all');

% Active vs. baseline within group (here we assume both groups are of equal
% size), so the design matrix will be reused
num_asd = sum(idx_asd);
designmat_within_group = zeros(2*num_asd, 1 + num_asd);
designmat_within_group(:, 1) = [-1*ones(num_asd, 1); ones(num_asd,1)];
designmat_within_group(:,2:end) = [eye(num_asd); eye(num_asd)];
exchangeblock_within_group = [1:num_asd, 1:num_asd];

figure
imagesc(designmat_within_group)
title('Design matrix active vs baseline within group')

save([out_dir, '/within_group_nbsdesign.mat'], 'designmat_within_group');
save([out_dir, '/within_group_exchangeblocks.mat'], 'exchangeblock_within_group');

% Active window between group
designmat_between_group = zeros(num_subjects, 2);
designmat_between_group(:, 1) = idx_asd;
designmat_between_group(:, 2) = idx_tdc;

figure
imagesc(designmat_between_group)
title('Design matrix active window between group')

save([out_dir, '/between_group_nbsdesign.mat'], 'designmat_between_group');


%% Load and z-score all the data

% Extract the number of regions
num_regions = length(temp.pos_name);

% Load in all the timeseries data
conn_active_all = zeros(num_regions, num_regions, num_subjects);
conn_baseline_all = zeros(num_regions, num_regions, num_subjects);
conn_active_all_unfiltered = zeros(num_regions, num_regions, num_subjects);

for ss = 1:num_subjects
    disp(['Processing data for ', p.subject(ss)])

    z_adjmat = load_connectivity_data(p,ss, ff, baseline_ind); % 46x46x3000

    % Compute baseline mean and active window mean
    conn_active = mean(z_adjmat(:, :, active_ind), 3); % 46x46
    conn_baseline = mean(z_adjmat(:,:, baseline_ind), 3); %46x46

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
    %saveas(gcf, [out_dir '/conmat_' p.subject(ss) '.png'])

    mask = zeros(num_regions,num_regions);
    mask(rois, :) = 1;
    mask(:, rois) = 1;
    conn_active_filtered = conn_active.*mask;
    conn_baseline_filtered = conn_baseline.*mask;

    % Assign
    conn_active_all(:, :, ss) = conn_active_filtered; 
    conn_baseline_all(:,:, ss) = conn_baseline_filtered; 
    conn_active_all_unfiltered(:, :, ss) = conn_active;
end

% Concatenate / select groups
conn_within_all = cat(3, conn_baseline_all, conn_active_all); % 46x46x80
conn_within_asd = cat(3, conn_baseline_all(:, :, idx_asd), conn_active_all(:, :, idx_asd)); % 46x46x40
conn_within_tdc = cat(3, conn_baseline_all(:, :, idx_tdc), conn_active_all(:, :, idx_tdc)); % 46x46x40
conn_between_group = conn_active_all; %46x46x40

% Save
save([out_dir, '/within_all_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nbsdata.mat'], 'conn_within_all');
save([out_dir, '/within_asd_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nbsdata.mat'], 'conn_within_asd');
save([out_dir, '/within_tdc_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nbsdata.mat'], 'conn_within_tdc');
save([out_dir, '/between_group_' num2str(active_win(1)) '-' num2str(active_win(2)) '_nbsdata.mat'], 'conn_between_group');

%% Plot means & std

conn_asd_mean = mean(squeeze(conn_active_all(:, :, idx_asd)), 3);
conn_tdc_mean = mean(squeeze(conn_active_all(:, :, idx_tdc)), 3);
conn_asd_std = std(squeeze(conn_active_all(:, :, idx_asd)), [], 3);
conn_tdc_std = std(squeeze(conn_active_all(:, :, idx_tdc)), [], 3);

colorlim = [min([conn_asd_mean(:); conn_tdc_mean(:)]), max([conn_asd_mean(:); conn_tdc_mean(:)])];
figure
subplot(2, 2, 1)
imagesc(conn_tdc_mean)
colorbar
caxis(colorlim)
axis square;
title('TDC mean')
subplot(2, 2, 2)
imagesc(conn_asd_mean)
colorbar
caxis(colorlim)
axis square;
title('ASD mean')
colorlim = [min([conn_asd_std(:); conn_tdc_std(:)]), max([conn_asd_std(:); conn_tdc_std(:)])];
subplot(2, 2, 3)
imagesc(conn_tdc_std)
colorbar
caxis(colorlim)
axis square;
title('TDC std')
subplot(2, 2, 4)
imagesc(conn_asd_std)
colorbar
caxis(colorlim)
axis square;
title('ASD std')
saveas(gcf, [fig_dir '/mean_conn_asd_vs_tdc_' num2str(active_win(1)) '-' num2str(active_win(2)) '.png'])