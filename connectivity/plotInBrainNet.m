function [] = plotInBrainNet(edgepath, nodepath, varargin)

iP = inputParser;
addParameter(iP, 'options', []);
addParameter(iP, 'surface', '/d/mjt/s4/toolboxes/brainnetviewer/2019-10-31/Data/SurfTemplate/BrainMesh_ICBM152_smoothed.nv');
parse(iP, varargin{:});

% setup the parameters that will go into BrainNetViewer
brainnet_params = {iP.Results.surface, edgepath, nodepath};
if ~isempty(iP.Results.options)
  brainnet_params{end+1} = iP.Results.options;
end

% call BrainNetViewer
BrainNet_MapCfg(brainnet_params{:});
end