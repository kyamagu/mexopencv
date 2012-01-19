function make(varargin)
%MAKE  compile mex functions
%
%   cv.make
%   cv.make('opencv_path',pathname) % Windows only
%
% Make builds mexopencv library. In Unix, this function invokes Makefile
% in the project root. In Windows, the function takes an optional argument
% to specify installed OpenCV path.
%

cwd = pwd;
cd(fileparts(fileparts(mfilename('fullpath'))));
	
if ispc % Windows
    opencv_path = 'C:\opencv';
    for i = 1:2:nargin
        if strcmp(varargin{i},'opencv_path')
            opencv_path = varargin{i+1};
        end
    end
    
	mex_flags = '-largeArrayDims -Iinclude';
	
	% Compile MxArray
	cmd = sprintf('mex -c %s %s src\\MxArray.cpp',...
        mex_flags,pkg_config(opencv_path));
	disp(cmd);
	eval(cmd);
	if ~exist('MxArray.obj','file')
		error('cv:make','MxArray.obj not found');
	end
	
	% Compile other files
	srcs = dir('src\matlab\*.cpp');
	srcs = cellfun(@(x) regexprep(x,'(.*)\.cpp','$1'), {srcs.name},...
		'UniformOutput', false);
	for i = 1:numel(srcs)
		cmd = sprintf('mex %s %s -outdir +cv src\\matlab\\%s.cpp MxArray.obj',...
			mex_flags,pkg_config,srcs{i});
		disp(cmd);
		eval(cmd);
	end
else % Unix
	system('make');
end

cd(cwd);

end

%
% Helper functions for windows
%
function s = pkg_config(opencv_path)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    if nargin < 1, opencv_path = 'C:\opencv'; end
    L_path = sprintf('%s\\build\\%s\\%s\\lib',opencv_path,arch_str,compiler_str);
    I_path = sprintf('%s\\build\\include',opencv_path);

    l_options = cellfun(@(x) ['-l',x,' '], lib_names(L_path),...
        'UniformOutput', false);
    l_options = [l_options{:}];
    
    s = sprintf('-I%s -L%s %s',I_path,L_path,l_options);
end

function s = arch_str
    %ARCH_STR  return architecture used in mex
    if isempty(strfind(mexext,'64'))
        s = 'x86';
    else
        s = 'x64';
    end
end

function s = compiler_str
    %COMPILER_STR  return compiler shortname
    c = mex.getCompilerConfigurations;
    if ~isempty(strfind(c.Name,'Visual'))
        if ~isempty(strfind(c.Version,'10.0')) % vc2010
            s = 'vc10';
        elseif ~isempty(strfind(c.Version,'9.0')) % vc2008
            s = 'vc9';
        else
            error('cv:make','Unsupported compiler');
        end
    elseif ~isempty(strfind(c.Name,'GNU'))
        s = 'mingw';
    else
        error('cv:make','Unsupported compiler');
    end
end

function l = lib_names(L_path)
    %LIB_NAMES  return library names
    d = dir([L_path,'\opencv_*d.lib']);
    l = cellfun(@(x) regexprep(x,'(opencv_.+)d.lib','$1'),{d.name},...
        'UniformOutput',false);
end