%MEX_COMPILE compile opencv bindings for Matlab or octave.
% Tested for win64 build. Mac and Linux use makefile.

% Keep this script in path.
addpath(pwd);
base_path = pwd


% Move to mexopencv and add paths.
cd('..');
addpath(pwd);
addpath(fullfile(pwd,'opencv_contrib'));
addpath(fullfile(pwd,'utils'));

% Build
mexopencv.make('clean', true, 'opencv_path', 'opencv', 'opencv_contrib', true);
mexopencv.make('opencv_path', 'opencv', 'opencv_contrib', true);

% Documentation
MDoc('-clean');
MDoc('-wiki');
MDoc;

% Group binaries in the same folder in order to only copy the dll once. 
copyfile(fullfile(pwd, 'opencv_contrib', '+cv'), fullfile(pwd, '+cv'));
copyfile(fullfile(pwd, 'opencv_contrib', '+cv', 'private'), fullfile(pwd, '+cv', 'private'));

% We avoid dll path problems by copying dlls in .mexw64 folders. If not we need to do a setenv('PATH')
copyfile(fullfile(pwd, 'opencv', 'x64', 'vc16', 'bin','*.dll'), fullfile(pwd, '+cv'));
copyfile(fullfile(pwd, 'opencv', 'x64', 'vc16', 'bin','*.dll'), fullfile(pwd, '+cv', 'private'));