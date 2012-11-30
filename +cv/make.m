function make(varargin)
%MAKE  compile mex functions
%
%    cv.make
%    cv.make('opencv_path',pathname) % Windows only
%
% Make builds mexopencv library. In Unix, this function invokes Makefile
% in the project root. In Windows, the function takes an optional argument
% to specify installed OpenCV path.
%

cwd = pwd;
cd(fileparts(fileparts(mfilename('fullpath'))));

if ispc % Windows
    % Clean
    if nargin>0 && strcmp(varargin{1},'clean')
        cmd = sprintf('delete +cv\\*.%s +cv\\private\\*.%s lib\\*', mexext, mexext);
        disp(cmd);
        eval(cmd);
        return;
    end

    opencv_path = 'C:\opencv';
    for i = 1:2:nargin
        if strcmp(varargin{i}, 'opencv_path')
            opencv_path = varargin{i+1};
        end
    end
    mex_flags = sprintf('-largeArrayDims -D_SECURE_SCL=%d -Iinclude %s',...
                        true, pkg_config(opencv_path));

    % Compile MxArray
    force = false;
    src = 'src\\MxArray.cpp';
    dst = 'lib\\MxArray.obj';
    if compile_needed(src, dst)
        cmd = sprintf('mex -c %s %s -outdir lib', mex_flags, src);
        disp(cmd);
        eval(cmd);
        force = true;
    end

    if ~exist(dst, 'file')
        error('cv:make', 'lib\MxArray.obj not found');
    end

    % Compile other files
    srcs = dir('src\+cv\*.cpp');
    srcs = cellfun(@(x) regexprep(x,'(.*)\.cpp', '$1'), {srcs.name},...
                   'UniformOutput', false);
    psrcs = dir('src\+cv\private\*.cpp');
    psrcs = cellfun(@(x) regexprep(x,'(.*)\.cpp', 'private\\$1'), ...
                    {psrcs.name}, 'UniformOutput', false);
    srcs = [srcs,psrcs];
    for i = 1:numel(srcs)
        src = sprintf('src\\+cv\\%s.cpp', srcs{i});
        dst = sprintf('+cv\\%s', srcs{i});
        fulldst = [dst, '.', mexext];
        if compile_needed(src, fulldst) || force
            cmd = sprintf('mex %s %s lib\\MxArray.obj -output %s',...
                          mex_flags, src, dst);
            disp(cmd);
            eval(cmd);
        else
            fprintf('Skipped %s\n', src);
        end
    end
else % Unix
    system(sprintf('make MATLABDIR=%s%s', matlabroot,...
           sprintf(' %s', varargin{:})));
end

cd(cwd);

end

%
% Helper functions for windows
%
function s = pkg_config(opencv_path)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    L_path = sprintf('%s\\build\\%s\\%s\\lib', ...
                     opencv_path, arch_str, compiler_str);
    I_path = sprintf('%s\\build\\include', opencv_path);
    l_options = cellfun(@(x) ['-l', x, ' '], lib_names(L_path), ...
                        'UniformOutput', false);
    l_options = [l_options{:}];
    s = sprintf('-I"%s" -L"%s" %s', I_path, L_path, l_options);
end

function s = arch_str
    %ARCH_STR  return architecture used in mex
    if isempty(strfind(mexext, '64'))
        s = 'x86';
    else
        s = 'x64';
    end
end

function s = compiler_str
    %COMPILER_STR  return compiler shortname
    c = mex.getCompilerConfigurations;
    if ~isempty(strfind(c.Name, 'Visual'))
        if ~isempty(strfind(c.Version, '10.0')) % vc2010
            s = 'vc10';
        elseif ~isempty(strfind(c.Version, '9.0')) % vc2008
            s = 'vc9';
        else
            error('cv:make', 'Unsupported compiler');
        end
    elseif ~isempty(strfind(c.Name, 'Microsoft SDK')) % win64
        s = 'vc10';
    elseif ~isempty(strfind(c.Name, 'GNU'))
        s = 'mingw';
    else
        error('cv:make', 'Unsupported compiler');
    end
end

function l = lib_names(L_path)
    %LIB_NAMES  return library names
    d = dir([L_path, '\opencv_*d.lib']);
    l = cellfun(@(x) regexprep(x, '(opencv_.+)d.lib','$1'), {d.name},...
                'UniformOutput',false);
end

function r = compile_needed(src, dst)
    %COMPILE_NEEDED check timestamps
    if ~exist(dst, 'file')
        r = true;
    else
        d1 = dir(src);
        d2 = dir(dst);
        r = (d1.datenum >= d2.datenum);
    end
end
