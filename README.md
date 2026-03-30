Analysis code accompanying the OPM-MEG study on emotional face processing in preschool children with and without autism. 

Developed using MATLAB2024a, FieldTrip version 20220214, NBS1.2, BrainnetViewer 1.63, R 4.4.2

Workflow evoked analysis:
1. make_vis_mask to create the fusiform mask
2. opm_study_config_faces_voxelwise to specify parameters for the OPM preprocessing pipeline
3. extract_voxel_with_max_power to find the voxel within the fusiform mask with the strongest overall evoked response
4. faces_find_peak to select the M100 peak and M170 valley
5. plot_faces_timeseries_fusiform for plotting
6. M100_stats and M170_stats for statistics

Workflow connectivity: 
1. perform_reg_newatlas_faces to add ROIs to existing atlas
2. opm_study_faces_connectivity to specify parameters for the OPM preprocessing pipeline
3. connectivity_raw to inspect timeseries and behaviour of raw connectivity values pre-NBS
4. connectivity_organizer to prepare files for NBS
5. connectivity_NBS_threshold_sweep to inspect the robustness of any significant networks
6. connectivity_create_node_and_edge_files to prepare NBS output for plotting, after running NBS
7. connectivity_plot_in_brainnet for visualisation

Data will be made available through the Ontario Brain Institute. 
