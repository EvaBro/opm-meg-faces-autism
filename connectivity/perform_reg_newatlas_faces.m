%% Add new regions to an existing atlas
% Author: Natalie Rhodes
% Modified by Eva Broeders for face-evoked analysis

clear all
close all
clc

% Fieldtrip setup 
% Specify the path of the FieldTrip toolbox
fieldtrip_path = '/d/mjt/s4/toolboxes/fieldtrip/fieldtrip-20220214';
addpath(fieldtrip_path)

ft_defaults

%% Load in atlas 4D

atlas_4D = ft_read_mri('/d/mjt/9/projects/OPM/opm_pipeline_templates/Adult/MEGatlas_38reg/MEG_atlas_38_regions_4D.nii.gz');

%% Make 3D atlas

atlas_3D = atlas_4D;
atlas_3D.anatomy = [];

atlas_3D.anatomy = zeros(size(squeeze(atlas_4D.anatomy(:,:,:,1))));

for i = 1:36 % Skip the anterior and posterior cingulate because we will add it as custom coordinates
    atlas_3D.anatomy(atlas_4D.anatomy(:,:,:,i)==max(atlas_4D.anatomy(:,:,:,i),[],'all')) = i;
end


%% Add in face regions

ffgl = [-30.88961, -41.905195, -22.106061];
ffgr = [34.159253	-40.69857	-22.033757];
insl = [-34.910118, 4.940258, 1.672228];
insr = [39.222034, 4.520339, 0.313559];
accl = [-3.864286, 33.695714, 12.035714];
accr = [8.617289, 35.222772, 13.932597];
amyl = [-23.009091, -2.445455, -18.954545];
amyr = [27.556452, -1.072581, -19.306452];
pccl = [-4.705184, -44.672786, 22.778618];
pccr = [7.676119, -43.586567, 19.971642];

ffgl_trans = [ffgl, 1] * inv(atlas_3D.transform');
ffgr_trans = [ffgr, 1] * inv(atlas_3D.transform');
insl_trans = [insl, 1] * inv(atlas_3D.transform');
insr_trans = [insr, 1] * inv(atlas_3D.transform');
accl_trans = [accl, 1] * inv(atlas_3D.transform');
accr_trans = [accr, 1] * inv(atlas_3D.transform');
amyl_trans = [amyl, 1] * inv(atlas_3D.transform');
amyr_trans = [amyr, 1] * inv(atlas_3D.transform');
pccl_trans = [pccl, 1] * inv(atlas_3D.transform');
pccr_trans = [pccr, 1] * inv(atlas_3D.transform');

atlas_3D.anatomy(round(ffgl_trans(1)), round(ffgl_trans(2)), round(ffgl_trans(3))) = 37; % FFGL
atlas_3D.anatomy(round(ffgr_trans(1)), round(ffgr_trans(2)), round(ffgr_trans(3))) = 38; % FFGR
atlas_3D.anatomy(round(insl_trans(1)), round(insl_trans(2)), round(insl_trans(3))) = 39; % INSL
atlas_3D.anatomy(round(insr_trans(1)), round(insr_trans(2)), round(insr_trans(3))) = 40; % INSR
atlas_3D.anatomy(round(accl_trans(1)), round(accl_trans(2)), round(accl_trans(3))) = 41; % ACCL
atlas_3D.anatomy(round(accr_trans(1)), round(accr_trans(2)), round(accr_trans(3))) = 42; % ACCR
atlas_3D.anatomy(round(amyl_trans(1)), round(amyl_trans(2)), round(amyl_trans(3))) = 43; % AMYL
atlas_3D.anatomy(round(amyr_trans(1)), round(amyr_trans(2)), round(amyr_trans(3))) = 44; % AMYR
atlas_3D.anatomy(round(pccl_trans(1)), round(pccl_trans(2)), round(pccl_trans(3))) = 45; % PCCL
atlas_3D.anatomy(round(pccr_trans(1)), round(pccr_trans(2)), round(pccr_trans(3))) = 46; % PCCR

ft_write_mri('/d/mjt/9/projects/OPM/opm_pipeline_templates/Adult/meg38_faces_1mm.nii.gz',atlas_3D.anatomy,'transform',atlas_3D.transform, 'unit', atlas_3D.unit)

%% Register to all templates
cd('/d/mjt/9/projects/OPM-Analysis/OPM_faces_ASDvTDC/code')
p = opm_study_config_faces_meg38faces();
for sub_num = 1:size(p.subject_data, 1)
    if ~exist(p.sourcemodel.coordinates.ve_locs(sub_num))
        output_dir = p.headmodel.template_dir(sub_num);
        output_dir_reg = [output_dir '/registrations'];
        cmd = ['antsApplyTransforms -d 3 -i /d/mjt/9/projects/OPM/opm_pipeline_templates/Adult/meg38_faces_1mm.nii.gz -r ' output_dir_reg '/T1_template_brain_BrainExtractionBrain.nii.gz -t [ ' output_dir_reg '/T1_template_registeredMNI152_0GenericAffine.mat, 1] -t ' output_dir_reg '/T1_template_registeredMNI152_1InverseWarp.nii.gz -n GenericLabel -o ' output_dir '/meg38_faces.nii.gz'];
        system(cmd);
        % Copy over the text file
        cmd = ['cp /d/mjt/9/projects/OPM/opm_pipeline_templates/Adult/meg38_faces.txt ' output_dir '/'];
        system(cmd);
        % Split the parcels
        cmd = ['mkdir ' output_dir '/split'];
        system(cmd);
        cmd = ['for i in {1..46}; do fslmaths ' output_dir '/meg38_faces.nii.gz -uthr ${i} -thr ${i} ' output_dir '/split/meg38_faces_${i}.nii.gz; done'];
        system(cmd);
        cmd = ['for i in {1..46}; do fslstats ' output_dir '/split/meg38_faces_${i}.nii.gz -c; done > ' output_dir '/meg38_faces_COG.txt'];
        system(cmd);

        % Remove the split directory
        cmd = ['rm -r ' output_dir '/split'];
        system(cmd);
    end
end