%% FileStorage demo
% Demonstration of reading/writing from/to XML and YAML file storages.
%
% <https://github.com/Itseez/opencv/blob/master/modules/core/include/opencv2/core/persistence.hpp>

%% Data
% First we create some different variables to save.
% We have an integer, text string (calibration date), 2 matrices,
% and a custom structure "feature" (struct-array), which includes feature
% coordinates and LBP (local binary pattern) value.
frameCount = int32(5);
calibrationDate = datestr(now);
cameraMatrix = [1000, 0, 320; 0, 1000, 240; 0, 0, 1];
distCoeffs = [0.1; 0.01; -0.001; 0; 0];
features = struct('x',cell(1,3), 'y',cell(1,3), 'lbp',cell(1,3));
for i=1:numel(features);
    features(i).x = randi(640,'int32');
    features(i).y = randi(480,'int32');
    features(i).lbp = num2cell(bitget(randi(255,'uint8'),1:8));
end

%%
% now we collect the variable inside a structure fields
% (that way we get a named collection (mapping) of variables)
S = struct(...
    'frameCount',frameCount, ...
    'calibrationDate',calibrationDate, ...
    'cameraMatrix',cameraMatrix, ...
    'distCoeffs', distCoeffs, ...
    'features',features);
display(S)
display(S.features)

%% Save
% next we save them to XML/YML files
fname = tempname;
cv.FileStorage([fname '.xml'], S)
cv.FileStorage([fname '.yml'], S)

%% XML file
type([fname '.xml'])

%% YML file
type([fname '.yml'])

%% Load
% we read the files back
S_xml = cv.FileStorage([fname '.xml']);
S_yml = cv.FileStorage([fname '.yml']);

%%
% and show the result
display(S_yml)
display(S_yml.cameraMatrix)
display(S_yml.distCoeffs)
celldisp(S_yml.features, 'features')

%%
% finally, we clean up the temporary files
delete([fname '.xml'])
delete([fname '.yml'])
