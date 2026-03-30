%% Script to investigate raw connectivity values:
% Time course of average connectivity to determine active window
% Average connectivity versus potential confounds like age, head motion...
% Preliminary relation between average raw connectivity and behavioural
% scores

close all
clear
clc

load_connectivity_parameters

%% Pre-loop logistics

% Get time vector
temp = load(p.sourcemodel.coordinates.ve(p.subject(1), p.session(1), p.run(1),p.task(1)));
time = temp.time';

% Define matrix sizes
num_subjects = size(p.subject_data, 1);
num_regions = length(temp.pos_name);
num_rois = length(rois);

% Get window indices
baseline_ind = baseline_win(1) <= time & time <= baseline_win(2);
active_ind = active_win(1) <= time & time <= active_win(2);

% Pre-allocate memory
conn_matrices = zeros(num_regions, num_regions, length(time), num_subjects);
conn_rois = zeros(num_rois, num_regions, length(time), num_subjects);

%% Load data
for ss = 1:num_subjects
    disp(num2str(ss))
    z_adjmat = load_connectivity_data(p, ss, ff, baseline_ind);

    % mask regions of interest
    conn_rois(:, :, :, ss) = z_adjmat(rois, :, :);
end

%% Connectivity versus time

idx_asd = strcmp(p.subject_data.dx, 'ASD');
idx_tdc = strcmp(p.subject_data.dx, 'TDC');

% Mean across first dimension, then sum to calculate strength
mean_rois = squeeze(mean(conn_rois, 1)); % After squeezing, the first dim becomes 46
mean_rois = squeeze(sum(mean_rois, 1));

% Mean across groups
mean_asd = mean(mean_rois(:, idx_asd), 2);
mean_tdc = mean(mean_rois(:, idx_tdc), 2);
mean_all = mean(mean_rois, 2);

figure;
subplot(2, 1, 1)
hold on
plot(time, mean_all');
xlabel('Time (s)');
yline(mean(mean_all(1 < time & time < 1.5)))
xline([active_win(1), active_win(2)])
ylabel('Z-scored mean connectivity')
%xlim([-0.5, 1])
%ylim([-2, 4.5])
title('Raw')


subplot(2, 1, 2)
hold on
plot(time, smoothdata(mean_all)');
xlabel('Time (s)');
%yline(0)
yline(mean(mean_all(1 < time & time < 1.5)))
xline([active_win(1), active_win(2)])
ylabel('Z-scored mean connectivity')
%xlim([-0.5, 1])
%ylim([-2, 4.5])
title('Smoothened')


%% Connectivity in active window between groups

% Mean across time per subject
mean_active = mean(mean_rois(active_ind, :), 1);

% Boxplots
figure
boxplot(mean_active, p.subject_data.dx)
ylabel('Mean connectivity in active window (a.u.)')

% Test
[h,pt] = ttest2(mean_active(idx_tdc), mean_active(idx_asd));
disp(['T-test of connectivity between TDC and ASD: p = ', num2str(pt)])

%% Connectivity in active window versus age

age = p.subject_data.age;

% Plot versus age
figure
subplot(1, 2, 1)
plot(age, mean_active, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Age (years)')
subplot(1, 2, 2)
hold on
plot(age(idx_tdc), mean_active(idx_tdc), 'o')
plot(age(idx_asd), mean_active(idx_asd), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Age (years)')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(age, mean_active');
disp(['Correlation between connectivity and age: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

%[rho, prho] = corrcoef(age(idx_asd), mean_active(idx_asd)');
%disp(['Correlation between connectivity and age for ASDs: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

%[rho, prho] = corrcoef(age(idx_tdc), mean_active(idx_tdc)');
%disp(['Correlation between connectivity and age for TDCs: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

%% Connectivity in active window versus head motion

HM = p.subject_data.HM;

figure
subplot(1, 2, 1)
plot(HM, mean_active, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Head motion (mm)')
subplot(1, 2, 2)
hold on
plot(HM(idx_tdc), mean_active(idx_tdc), 'o')
plot(HM(idx_asd), mean_active(idx_asd), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Head motion (mm)')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(HM, mean_active', 'Rows', 'complete');
disp(['Correlation between connectivity and HM: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

%% Connectivity in active window versus number of bad channels

bch = p.subject_data.num_bad_channels;

figure
subplot(1, 2, 1)
plot(bch, mean_active, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Number of bad channels')
subplot(1, 2, 2)
hold on
plot(bch(idx_tdc), mean_active(idx_tdc), 'o')
plot(bch(idx_asd), mean_active(idx_asd), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Number of bad channels')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(bch, mean_active', 'Rows', 'complete');
disp(['Correlation between connectivity and numbadch: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])


%% Connectivity in active window versus number of trials

num_trials = p.subject_data.trials;

figure
subplot(1, 2, 1)
plot(num_trials, mean_active, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Number of trials')
subplot(1, 2, 2)
hold on
plot(num_trials(idx_tdc), mean_active(idx_tdc), 'o')
plot(num_trials(idx_asd), mean_active(idx_asd), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('Number of trials')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(num_trials, mean_active', 'Rows', 'complete');
disp(['Correlation between connectivity and number of trials: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

%% Connectivity in active window versus SRS_total
srs_t = p.subject_data.srs_total_T_merged;

figure
subplot(1, 2, 1)
plot(srs_t, mean_active, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('SRS total score')
subplot(1, 2, 2)
hold on
plot(srs_t(idx_tdc), mean_active(idx_tdc), 'o')
plot(srs_t(idx_asd), mean_active(idx_asd), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('SRS total score')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(srs_t, mean_active', 'Rows', 'complete');
disp(['Correlation between connectivity and SRS total score: rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

% Compute correlation Spearman
[rho, prho] = corr(srs_t, mean_active', 'Rows', 'complete', 'Type','Spearman');
disp(['Spearman correlation between connectivity and SRS total score: rho = ', num2str(rho), ', p = ', num2str(prho)])

%%
% Remove one suspected outlier
outlier_idx = 39;
mean_active_nooutlier = mean_active;
mean_active_nooutlier(outlier_idx) = [];
srs_t_nooutlier = srs_t;
srs_t_nooutlier(outlier_idx) = [];
idx_tdc_nooutlier = idx_tdc;
idx_tdc_nooutlier(outlier_idx) = [];
idx_asd_nooutlier = idx_asd;
idx_asd_nooutlier(outlier_idx) = [];

figure
subplot(1, 2, 1)
plot(srs_t_nooutlier, mean_active_nooutlier, 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('SRS total score')
subplot(1, 2, 2)
hold on
plot(srs_t_nooutlier(idx_tdc_nooutlier), mean_active_nooutlier(idx_tdc_nooutlier), 'o')
plot(srs_t_nooutlier(idx_asd_nooutlier), mean_active_nooutlier(idx_asd_nooutlier), 'o')
ylabel('Connectivity strength to 8 face regions')
xlabel('SRS total score')
legend({'TDC'; 'ASD'})

% Compute correlation
[rho, prho] = corrcoef(srs_t_nooutlier, mean_active_nooutlier', 'Rows', 'complete');
disp(['Correlation between connectivity and SRS total score (no outlier): rho = ', num2str(rho(1, 2)), ', p = ', num2str(prho(1,2))])

% Compute correlation Spearman
[rho, prho] = corr(srs_t_nooutlier, mean_active_nooutlier', 'Rows', 'complete', 'Type','Spearman');
disp(['Spearman correlation between connectivity and SRS total score (no outlier): rho = ', num2str(rho), ', p = ', num2str(prho)])



