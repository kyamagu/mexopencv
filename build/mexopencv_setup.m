%MEXOPENCV_SETUP prepare mexopencv paths
%
% Note: this file must be in the base directory of mexopencv package.

function mexopencv_setup()

base_path = fileparts(mfilename('fullpath'));
addpath(base_path);
addpath(fullfile(base_path, 'opencv_contrib'));

if ispc
    lib_path = fullfile(base_path, 'opencv', 'x64', 'vc16', 'bin');
    prev_path = getenv('PATH');
    prev_parts = split(prev_path, ';');
    if ~any(strcmpi(lib_path, prev_parts))
        setenv('PATH', [lib_path, ';', getenv('PATH')]);
    end
end
