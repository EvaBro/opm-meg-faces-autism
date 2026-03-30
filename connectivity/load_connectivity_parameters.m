%% Script with all parameters for connectivity analyses

% Run config
p = opm_study_config_faces_connectivity();

% Active and baseline window
baseline_win = [-0.5, 0];
active_win = [0.1, 0.3];

% Select behavioural metric if doing dimensional analyses
metric = ''; %'srs_awareness_T_merged';

% Specify any potential outliers to see what happens if they are removed
outlier_idx = [];

% Regions of interest
rois = 37:44;

% Frequency
ff = 1;

% Output directory to save data and figures
out_dir = '/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC/analysis/NBS/group/';
fig_dir = out_dir;

%% Secondary assignments
% Extract time
temp = load(p.sourcemodel.coordinates.ve(p.subject(1), p.session(1), p.run(1),p.task(1)));
time = temp.time';

% Get baseline and active window indices
baseline_ind = baseline_win(1) <= time & time < baseline_win(2);
active_ind = active_win(1) <= time & time < active_win(2);

%% Printouts
disp(['Analyzing frequency range: ' num2str(p.connectivity.fois(ff, 1)) '-' num2str(p.connectivity.fois(ff, 2)) ' Hz'])
disp(['Baseline window:           ' num2str(baseline_win(1)) '-' num2str(baseline_win(2))])
disp(['Active window:             ' num2str(active_win(1)) '-' num2str(active_win(2))])
disp(['Metric:                    ' metric])
if ~ isempty(outlier_idx)
disp(['Remove outlier:            ' num2str(outlier_idx)])
else
disp('Remove outlier:            None' )
end
disp(['Saving data to ' out_dir])
disp('-------------------------------------------------')