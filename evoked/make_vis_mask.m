%% Script to create a dilated mask containing one or more specific brain regions prior to source modelling
% Author: Natalie Rhodes
% Modified by Eva Broeders for face-evoked analysis

close all
clear
clc

% Run the study configuration
% The configuration should include the atlas that has the parcel of
% interest, as well as the resolution of interest
p = opm_study_config_faces();

% Give a new name to the extracted parcel, 
% which will serve as the new 'atlas' in subsequent analysis
parcel_name = 'fusiformmask'; 

% Define indices of the regions of interest from the original atlas
rois = [55 56];

% Define radius of the sphere used to dilate the parcels
radius = 2;


%% Go through subjects
% Get resolution
res = p.sourcemodel.grid.res;
for ss = 1:size(p.subject_data, 1)
    % check if exists as only need once per template
    if ~exist([p.headmodel.template_dir(ss) '/' parcel_name '_' num2str(res) 'mm.nii.gz'])
        
        % Find voxels within the regions of interest
        grid = ft_read_mri(p.sourcemodel.grid.mask_nii(ss));
        VOI = ismember(grid.anatomy, rois);
        
        % Dilate. Note that any regions not part of the brain will be
        % masked in the pipeline
        SE = strel('sphere',radius);
        load([p.headmodel.template_dir(ss) '/segmentedmri.mat']);
        %dilatedVOI = imdilate(VOI,SE) & (grid.anatomy > 0);
        %dilatedVOI = imdilate(VOI,SE) & (segmentedmri.brain > 0);
        dilatedVOI = imdilate(VOI,SE);

        % Use this code if you want to chop off the back of the brain
        % dilatedVOI = zeros(size(grid.anatomy));
        % dilatedVOI(grid.anatomy>0) = 1; 
        % [x,y,z] = ind2sub(size(dilatedVOI), find(dilatedVOI));
        % xmin = min(x); xmax = max(x); 
        % ymin = min(y); ymax = max(y); % y = posterior -> anterior
        % zmin = min(z); zmax = max(z);
        % bbox = [xmin xmax; ymin ymax; zmin zmax];
        % disp(bbox)
        % dilatedVOI(:, ymin+6:ymax, :) = 0; 

        % Figures for verification
        sil_orig = squeeze(any(grid.anatomy, 1))';   % x–z projection
        sil_new = squeeze(any(dilatedVOI, 1))';
        %calcarineVOI = imdilate(VOI,SE);
        %sil_cal = squeeze(any(calcarineVOI, 1))';

        figure; hold on;
        % Background in grayscale (force black/white)
        imagesc(sil_orig);
        colormap(gray);
        clim([0 1]);          % important for binary images
        axis image off;

        % Red overlay of new mask
        red = cat(3, ones(size(sil_new)), zeros(size(sil_new)), zeros(size(sil_new)));
        h = image(red);       % <-- NOT imagesc
        h.AlphaData = 0.4 * sil_new;   % transparency only where sil_chop==1
        % green = cat(3, zeros(size(sil_cal)), ones(size(sil_cal)), zeros(size(sil_cal)));
        % h2 = image(green);       % <-- NOT imagesc
        % h2.AlphaData = 0.4 * sil_cal;   % transparency only where sil_chop==1

        % Reassign
        vismask = grid;
        vismask.anatomy = double(dilatedVOI);
        
        % Write to template directory
        disp(['Writing new mask to ' p.headmodel.template_dir(ss) '/' parcel_name '_' num2str(res) 'mm.nii.gz'])
        ft_write_mri([p.headmodel.template_dir(ss) '/' parcel_name '_' num2str(res) 'mm.nii.gz'],vismask,'dataformat','nifti_gz')
    end 
end 





