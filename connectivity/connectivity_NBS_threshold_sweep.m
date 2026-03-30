%% Script to sweep through a range of thresholds for NBS
% Goal is to characterize the sensitivity of the p-value and network extent 
% to changes in the threshold, so that we are sure that the network we find 
% is stable and not a mere coincidence at one specific value of the threshold. 
% See NBS manual, section 2.7, page 14
%
% THIS SCRIPT WILL NOT WORK IF YOUR FILE PATHS ARE TOO LONG
% You will get an error like 'Stop. Design matrix not found or
% inconsistent'
%
% THIS SCRIPT WILL NOT WORK IF YOU HAVE ANY NODE OR EDGE FILES
% in the same directory as the nbsdesign, nbsdata, and exchange blocks
% files

close all
clear all
clc

% Add subfolders to path
addpath(genpath('.'))

% Define thresholds
thresholds = 1:0.1:3.5;

% Desired extent
desired_extent = 33; 

%% Create input structure for NBS

% User-dependent parameters
input_dir = '/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC/analysis/NBS/srstotal/';
fig_dir = input_dir;
UI.contrast.ui = '[0 -1]';%'[1, zeros(1, 19)]'; %Contrast vector
UI.design.ui =   [input_dir '/nooutlier_nbsdesign.mat']; % Design matrix
UI.exchange.ui = ''; %[input_dir '/within_tdc_nooutlier_exchangeblocks.mat'];%'';%[input_dir '/within_group_exchangeblocks.mat']; % Exchange blocks
UI.matrices.ui = [input_dir '/-0.5-0_0.1-0.3_nooutlier_nbsdata.mat']; % Connectivity matrix
fig_name = '/-0.5-0_0.1-0.3_nooutlier_threshold_sweep';

% Standard parameters
UI.method.ui='Run NBS'; 
UI.test.ui='t-test';
UI.size.ui='Extent';
UI.perms.ui='5000';
UI.alpha.ui='0.05';
UI.node_coor.ui='./data/atlases/meg38_faces_COG.txt';                         
UI.node_label.ui='./data/atlases/meg38_faces_labels.txt';
global nbs

%% Sweep through thresholds

% Initialize
n_thresholds = length(thresholds);
pval = zeros(1, n_thresholds);
network_size = zeros(1, n_thresholds);

for t = 1:length(thresholds)
    % Assign threshold
    threshold = thresholds(t);
    UI.thresh.ui=num2str(threshold);

    % Run NBS
    NBSrun(UI)
    
    % Get p-value
    pval(t) = nbs.NBS.misc.pval;

    % Get network size
    network_size(t) = nbs.NBS.misc.sz;
end

figure
subplot(2, 1, 1)
plot(thresholds, pval)
hold on
yline(0.05)
ylabel('p')
subplot(2, 1, 2)
plot(thresholds, network_size)
hold on
yline(desired_extent)
ylabel('Network extent')
xlabel('Threshold')

saveas(gcf, [fig_dir fig_name '.png'])

