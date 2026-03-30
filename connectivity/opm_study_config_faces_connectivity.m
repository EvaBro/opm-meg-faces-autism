function p = opm_study_config_faces_connectivity()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p = opm_study_config()
%
% Script to set configuration parameters for an OPM study
%
% Inputs:
%   None
%
% Requirements:
%   The demographic directory must contain a .csv file (name defined in
%   csv_file variable) with at least the following headings:
%       subject   Contains the subject IDs
%       session	Contains the session number
%       task      Task name
%       run       Contains the run number
%       template	Key word corresponding to the subdirectory in the
%                   template folder specifying which age-appropriate
%                   template was used for registration
%       including   Binary variable defining whether the subject is to be 
%                   included
%       ica         Column containing the ICA components to remove (can be 
%                   blank if not run)
%   Only required when BIDS database is being used:
%       noise_run   Run number corresponding to the noise data to be used
%   Only required when BIDS database is not being used:
%       opm_data    Contains the path to the OPM data
%       opm_noise   (optional) Contains the path to the noise corresponding 
%                   to the OPM data
%   
% Outputs:
%   p  (structure)  Configuration structure containing all set parameters
%
% Created by: Marlee M Vandewouw
% Created on: December 16, 2022
% 
% Modified by: Eva Broeders
% Modified on: April 21, 2025
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PIPELINE NAME

% Key name for pipeline - recommended to have the date
p.pipeline_name = 'faces_ASDvTDC_connectivity_2025-04-21'; %'faces_ASDvTDC_2025-01-17';%

%% PIPELINE DIRECTORY

% Specify the root directory of the pipeline
p.pipeline_path = './functions';

% Add to the current path
addpath(genpath(p.pipeline_path));

% Specify the path of the FieldTrip toolbox
p.fieldtrip_path = '/d/mjt/s4/toolboxes/fieldtrip/fieldtrip-20220214';

% Specify the path do to the template directory
p.template_path = '/d/mjt/9/projects/OPM/opm_pipeline_templates';
%% DIRECTORIES

% Main directory
p.directories.base_dir = '/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC';

% Demographic directory - must contain a .csv/.xlsx file (name defined in
% csv_file) with the following headings:
% subject   Contains the subject IDs
% session	Contains the session number
% task      Task name
% run       Contains the run number
% template	Key word corresponding to the subdirectory in the
%         	template folder specifying which age-appropriate
%           template was used for registration
% including Binary variable defining whether the subject is to be included
% ica       Column containing the ICA components to remove (can be blank if
%           not run)
% Only required when BIDS database is being used:
% noise_run   Run number corresponding to the noise data to be used
% Only required when BIDS database is not being used:
% opm_data  Contains the path to the OPM data
% opm_noise (optional) Contains the path to the noise corresponding to the
%           OPM data
p.directories.demo_dir = [p.directories.base_dir '/demographics'];
p.directories.csv_file = 'opm_faces_including.xlsx';

% Data directory (BIDS format) where all the output data will be stored
p.directories.data_dir = [p.directories.base_dir '/data'];

% Specify whether the data paths are already converted to a
% FieldTrip-compatible BIDS database, or whether the conversion is to be
% performed. Note that if this value is false, opm_data and (optional)
% opm_noise must be specified in the demographics file
p.directory.bids = true;

% Directory of BIDS database if true
p.directory.bids_dir = '/d/mjt/8/megdata/opm_bids';

%% SUBJECT INFORMATION

% Get the options for importing the .csv
opts = detectImportOptions([p.directories.demo_dir '/' p.directories.csv_file]);
ind = strcmp(opts.VariableNames, 'ica');
opts.VariableTypes{ind} = 'char';

% Read in the subject data
p.subject_data = readtable([p.directories.demo_dir '/' p.directories.csv_file], opts);

% Only keep subjects that are indicated to include
p.subject_data = p.subject_data(p.subject_data.including == 1, :);

%% EPOCHING

% Specify whether using an epoching .json file ("json") or epoching by
% trial duration ("duration")
p.epoching.type = 'json';

% Epoching .json file
p.epoching.json = './data/opm-epoching-params/FacesCircles_Faces.json';

% Epoching trial duration (in s)
% p.epoching.duration = 10;

%% INTERFERENCE SUPRESSION

% Interference supression technique. Must be either tSSS (temporal signal
% space separation) or HMC (homogenous field correction)
p.interference.method = 'HMC';

% Parameters for tSSS. For now, do not change the below settings (per
% Natalie Rhodes)
p.interference.tsss.lin = 7;
p.interference.tsss.lout = 2;
p.interference.tsss.corr = 0.98;

%% BAD CHANNELS

% Specify whether to automatically detect bad channels
p.badchannels.auto = false;

%% FILTERING

% If notch filtering (bsfilter = 'yes'), options can either be a 1d array
% specifying the frequences to notch filter at (bsfreq)  or specify 
% "noise peaks" to find peaks in the PSD that overlap with peaks in the 
% noise PSD. If noise peaks, have the option to specify the minimum peak 
% prominance and the minimum distsance between peaks, otherwise will use 
% the defaults in opm_psd_noise_filter

% Notch filtering
p.preproc.bsfilter = 'yes'; 
p.preproc.bsfreq = 'noise_peaks';

% Bandpass filtering
p.preproc.bpfilter = 'yes'; 
p.preproc.bpfreq = [1 150];
p.preproc.bpfiltord = 4;                        
p.preproc.bpfilttype = 'but';

%% ICA

% Number of ICA components
p.ica.ica_numcomponents = 30; 

%% ARTIFACT REJECTION

% Threshold
p.artifactreject.artf_rej_thresh = 4000e-15*13.7837926893474; 

%% HEADMODEL

% Method
p.headmodel.method = 'singleshell';

% Are we using custom MRIs?
p.headmodel.custom = false;

%% SOURCE MODELING

% Specify how to choose the optimized source orientation. Options are (a)
% 'both': both orientations are kept and beamformed data is summed across 
% both orientations, or (b) 'optimal': compute the optimal combination to 
% maximize the SNR - Sekihara et al. 2004
p.sourcemodel.orientation = 'optimal';

% Covariance regularization
p.sourcemodel.mu = 0.02;

% Whether or not to use the neural activity index
p.sourcemodel.nai = false;

% Specify whether to source a grid, or to source coordinates - must contain
% either 'grid' or 'coordinates', or both
p.sourcemodel.method = 'coordinates';

% Units that either the grid or coordinates are defined in
p.sourcemodel.units = 'mm';

%% SOURCE MODELING: COORDINATE OPTIONS

% Frequency to look at - if not specified, will do broadband
p.sourcemodel.coordinates.foi = [4, 40];

% Name for the coordinate set
p.sourcemodel.coordinates.ve_atlas = 'meg38_faces';

%% SOURCE MODELING: GRID OPTIONS

% Frequency to look at - if not specified, will do broadband
% p.sourcemodel.grid.foi = [4, 40];
% 
% % Define the resolution for the grid
% p.sourcemodel.grid.res = 2;
% 
% % Define whether or not to mask the grid by an atlas
% p.sourcemodel.grid.mask = true;
% p.sourcemodel.grid.mask_atlas = 'meg38';
% 
% % Average power over the grid for a time window
% 
% % Whether or not to compute the average power across a timewindow
% p.sourcemodel.grid.avgpow.flag = true;
% 
% % Time window(s) to examine
% p.sourcemodel.grid.avgpow.twoi = [0.1 0.4];  
% 
% % Specify whether to do across all trials, or per condition
% p.sourcemodel.grid.avgpow.per_cond = false;
% 
% % Whether or not to register to MNI space after computation
% p.sourcemodel.grid.reg_mni = true;
% 
% % Find the voxel within each parcel of an atlas that has the maximum power
% % compared to baseline
% 
% % Whether or not to extract the timeseries for a voxel in a parcel with the
% % maximum change in power
% p.sourcemodel.grid.ts.flag = true;
% 
% % The grid power is computed over p.sourcemodel.grid.foi frequency range,
% % but what range do we want to extract the timeseries for?  - if noSSt 
% % specified, will do broadband
% p.sourcemodel.grid.ts.foi = [4, 40]; % Kristina set this to 4, 40
% 
% % Parcellation to use
% p.sourcemodel.grid.ts.atlas_name = 'meg38';
% 
% % Time window to compute the power over
% p.sourcemodel.grid.ts.twoi = [0.1 0.4];
% 
% % Extract the timeseries for each point in the grid, and correlate with a
% % seed
% 
% % Whether or not to extract the timeseries for each voxel
% p.sourcemodel.grid.seed.flag = false;

% Whether or not to filter for the seed analysis
% p.sourcemodel.grid.seed.filter = true;
% 
% % Frequency band to use for the seed analysis
% p.sourcemodel.grid.seed.foi = [8, 29];
% 
% % Whether or not to leakage correct
% p.sourcemodel.grid.seed.leakage = true;
% 
% % Whether or not to downsample, and what the rate is
% p.sourcemodel.grid.seed.downsample.flag = true;
% p.sourcemodel.grid.seed.downsample.freq = 5;
% 
% % Atlas to pull the seeds from
% p.sourcemodel.grid.seed.coord_atlas = 'ICN';
% 
% % Seed IDs (corresponding to atlas file)
% p.sourcemodel.grid.seed.coord_ids = [20, 32, 38, 15]; 
% 
% % Seed names
% p.sourcemodel.grid.seed.names = {'LV1', 'LCS', 'LDIFG', 'LMPFC'};
% 
% % Whether or not to register to MNI space after computation
% p.sourcemodel.grid.seed.reg_mni = true;
% 
% % Extract the PSD for each point in the grid
% 
% % Whether or not to extract the PSD for each voxel
p.sourcemodel.grid.psd.flag = false;
% 
% % Frequency bands to look at
% p.sourcemodel.grid.psd.foi = [2, 40];
% 
% % Whether or not to register to MNI space after computation
% p.sourcemodel.grid.psd.reg_mni = true;

%% TIME-FREQUENCY REPRESENTATION

% % Method to compute the TFR - multitaper or hilbert
% p.tfr.method = 'multitaper'; % Kristina removed this, manuscript mentions Hilbert
% 
% % Frequency band to compute TFR over - needs to be within the
% % "p.sourcemodel.foi"
% p.tfr.fois = [4, 100]; % Kristina set thes to 4,100 but is not within foi?
% 
% % Stepsize and width for the frequency bands
% p.tfr.fois_ss = 1;
% p.tfr.fois_width = 5;
% 
% % Whether or not to compute the TFR across all conditions or within
% % condition
% p.tfr.per_cond = false;
% 
% % What timeseries to use - either the coordinates, or grid_ts
% p.tfr.timesries = 'grid_ts';
% 
% % The ID number of the timeseres to use (can be multiple)
% p.tfr.rois = [55, 56]; % value in retest: [45, 47];
% 
% % Whether or not to produce the TFR for each condition
% p.tfr.per_cond = false;

%% CONNECTIVITY

% Frequency bands to compute connectivity over - needs to be within the
% "p.sourcemodel.foi"
p.connectivity.fois = [4, 40; 4, 6; 7, 13; 14, 25; 26, 40]; 

% Whether or not to compute connectivity across all conditions or within
% condition
p.connectivity.per_cond = false;

% Whether or not to downsample, and what the rate is
% p.connectivity.downsample.flag = true; % Kristina commented this
% p.connectivity.downsample.freq = 5; % Kristina commented this

%% FOOOF

% Whether or not to calculate across the whole brain
% p.fooof.whole_brain = true;

%% CONFIGURE

% Now, configure all the output directories and files
p = configure_study(p);

