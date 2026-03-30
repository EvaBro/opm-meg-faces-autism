%% Script to plot selected node and edge files in brainnetviewer 

close all
clear all
clc

addpath('/d/mjt/s4/toolboxes/brainnetviewer/2019-10-31/')


edgepath = '../analysis/NBS/group/nbsoutput/tdc_nbsoutput.edge';
nodepath = '../analysis/NBS/group/nbsoutput/tdc_nbsoutput.node';
options = './data/connectivity_plot_files/brainnetoptions.mat';

plotInBrainNet(edgepath, nodepath, 'options', options)