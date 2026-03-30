%% Calculate connectivity strength to create a node file for brainnetviewer
% Case-control
% Edge value = mean difference between two groups, in case we want to color-code them

close all
clear all
clc

% To plot separate networks = true, to merge networks = false
plotSeparateNetworks = true;

% Add paths to toolboxes
addpath /d/mjt/s4/toolboxes/brainnetviewer/2019-10-31/
addpath /d/mjt/s4/toolboxes/brain-connectivity-toolbox/2019_03_03_BCT/

% Define input files for node and edge file creation
node_coords = load('/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC/code/data/atlases/meg38_faces_COG.txt');
node_labels = readtable('/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC/code/data/atlases/meg38_faces_labels.txt', 'Delimiter', '\t', 'ReadVariableNames', false);
node_labels = node_labels.Var1;
node_cat = load('./data/connectivity_plot_files/meg38_faces_node_categories.txt');

%% Load data files

% File suffixes required by the brainnetviewer toolbox
postfixes = {'nbsdata', 'nbsdesign', 'nbsoutput'};

% Ask user to indicate NBS output file
[nbspath,nbsdir] = uigetfile(['*_', postfixes{3}, '.mat'], 'NBS Output');
nbsoutputpath = fullfile(nbsdir,nbspath);

% Ask user to indicate connectivity matrix
[nbspath,nbsdir] = uigetfile(fullfile(nbsdir,['*_', postfixes{1}, '.mat']), 'NBS Data');
datapath = fullfile(nbsdir,nbspath);

% Ask user to indicate design matrix
[nbspath,nbsdir] = uigetfile(fullfile(nbsdir,['*_', postfixes{2}, '.mat;*_', postfixes{2}, '.txt']), 'NBS Design');
designpath = fullfile(nbsdir,nbspath);

% construct output paths
[a,b,~] = fileparts(nbsoutputpath);
nodepath = fullfile(a,[b,'.node']);
edgepath = fullfile(a,[b,'.edge']);    

% Load matrices
fprintf('Loading... \n%s\n%s\n%s\n', nbsoutputpath, datapath, designpath);
nbsdata = load(nbsoutputpath);
design = load(designpath);
data = load(datapath);

% If design was a mat file, then extract the first variable
if isstruct(design)
    fn = fieldnames(design);
    design = design.(fn{1});
end
%design = logical(design);

% load in the average
fn = fieldnames(data);
data = data.(fn{1});

% Get nummat = total number of networks that come out of NBS
num_networks = length(nbsdata.nbs.NBS.con_mat);

%% Loop through networks and get significant connections

if plotSeparateNetworks
    comb = cell(num_networks,1);
    % comb contains all the NBS output that corresponds to the NBS network
    for kk = 1:num_networks 

        % Get the significant edges, convert them from sparse to full 
        % matrix, and convert to logical
        comb{kk} = logical(full(nbsdata.nbs.NBS.con_mat{kk}));

        % Make comb symmetric (nbs outputs only what's above the diagonal)
        comb{kk} = comb{kk} | comb{kk}';
    end
else
    comb = {false(size(nbsdata.nbs.NBS.con_mat{1}))};
    for kk = 1:num_networks
        comb{1} = comb{1} | logical(full(nbsdata.nbs.NBS.con_mat{kk}));
    end
    
    comb{1} = comb{1} | comb{1}';
end

%% Create edge file and node file

for kk = 1:num_networks
    %%% Edge file
    % compute mean difference
    % Assuming there are two groups (active vs baseline or ASD vs TDC)
    size_data = size(data, 3);
    group_1 = 1:size_data/2;
    group_2 = size_data/2+1:size_data;
    meandiffmat = mean(data(:,:,group_2), 3) - mean(data(:,:,group_1), 3);
    meandiffmat(isnan(meandiffmat)) = 0;
  
    % threshold mean diff mat by combined NBS results to get edge file
    edge = meandiffmat .* comb{kk};
    edge(isnan(edge)) = 0;
    save(edgepath, '-ascii', 'edge');
    
    %%% Node file
    % compute node degree (the number of connections per node)
    node_size = degrees_und(comb{kk})';

    % construct node file
    t = table();
    t.Var1 = node_coords(:,1);
    t.Var2 = node_coords(:,2);
    t.Var3 = node_coords(:,3);
    t.Var4 = reshape(node_cat,[],1);
    t.Var5 = node_size;
    t.Var6 = reshape(node_labels,[],1);

    writetable(t, nodepath, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false);
end