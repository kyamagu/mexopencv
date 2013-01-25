function make(varargin)
%MAKE  compile mex functions
%
%    mexopencv.make
%    mexopencv.make('opencv_path', pathname) % Windows only
%
% Make builds mexopencv library. In Unix, this function invokes Makefile
% in the project root. In Windows, the function takes an optional argument
% to specify installed OpenCV path.
%

MEXOPENCV_ROOT = mexopencv.root();

% navigate to directory
cwd = cd(MEXOPENCV_ROOT);
cObj = onCleanup(@()cd(cwd));

if ispc % Windows
    % Clean
    if nargin>0 && strcmp(varargin{1},'clean')
        cmd = fullfile(MEXOPENCV_ROOT, '+cv', ['*.' mexext]);
        disp(cmd);
        delete(cmd);

        cmd = fullfile(MEXOPENCV_ROOT, '+cv', 'private', ['*.' mexext]);
        disp(cmd);
        delete(cmd);

        cmd = fullfile(MEXOPENCV_ROOT, 'lib', '*.obj');
        disp(cmd);
        delete(cmd);

        return;
    end

    % compile flags
    opencv_path = 'C:\opencv';
    for i = 1:2:nargin
        if strcmp(varargin{i}, 'opencv_path')
            opencv_path = varargin{i+1};
        end
    end
    mex_flags = sprintf('-largeArrayDims -D_SECURE_SCL=%d -I"%s" %s',...
        true, fullfile(MEXOPENCV_ROOT,'include'), pkg_config(opencv_path));

    % Compile MxArray
    force = false;
    src = fullfile(MEXOPENCV_ROOT,'src','MxArray.cpp');
    dst = fullfile(MEXOPENCV_ROOT,'lib','MxArray.obj');
    if compile_needed(src, dst)
        cmd = sprintf('mex -c %s "%s" -outdir "%s"', ...
            mex_flags, src, fileparts(dst));
        cmd = strrep(cmd, '"', '''');  % replace with escaped single quotes
        disp(cmd);
        eval(cmd);
        force = true;
    else
        fprintf('Skipped "%s"\n', src);
    end

    if ~exist(dst, 'file')
        error('mexopencv:make', '"%s" not found', dst);
    end

    % Compile other MEX files
    obj = fullfile(MEXOPENCV_ROOT,'lib','MxArray.obj');
    srcs = dir( fullfile(MEXOPENCV_ROOT,'src','+cv','*.cpp') );
    [~,srcs] = cellfun(@fileparts, {srcs.name}, 'UniformOutput',false);
    psrcs = dir( fullfile(MEXOPENCV_ROOT,'src','+cv','private','*.cpp'));
    [~,psrcs] = cellfun(@fileparts, {psrcs.name}, 'UniformOutput',false);
    psrcs = strcat('private', filesep, psrcs);
    srcs = [srcs,psrcs];
    for i = 1:numel(srcs)
        src = fullfile(MEXOPENCV_ROOT,'src','+cv',[srcs{i} '.cpp']);
        dst = fullfile(MEXOPENCV_ROOT,'+cv',srcs{i});
        fulldst = [dst, '.', mexext];
        if compile_needed(src, fulldst) || force
            cmd = sprintf('mex %s "%s" "%s" -output "%s"',...
                mex_flags, src, obj, dst);
            cmd = strrep(cmd, '"', '''');  % replace with escaped single quotes
            disp(cmd);
            eval(cmd);
        else
            fprintf('Skipped "%s"\n', src);
        end
    end
else % Unix
    cmd = sprintf('make MATLABDIR="%s" MEXEXT=%s %s', ...
        matlabroot, mexext, sprintf(' %s', varargin{:}));
    disp(cmd);
    system(cmd);
end

end

%
% Helper functions for windows
%
function s = pkg_config(opencv_path)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    L_path = fullfile(opencv_path,'build',arch_str(),compiler_str(),'lib');
    I_path = fullfile(opencv_path,'build','include');
    l_options = strcat({' -l'}, lib_names(L_path));
    l_options = [l_options{:}];
    s = sprintf('-I"%s" -L"%s" %s', I_path, L_path, l_options);
end

function s = arch_str()
    %ARCH_STR  return architecture used in mex
    if isempty(strfind(mexext, '64'))
        s = 'x86';
    else
        s = 'x64';
    end
end

function s = compiler_str()
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
        error('mexopencv:make', 'Unsupported compiler: %s', c.Name);
    end
end

function l = lib_names(L_path)
    %LIB_NAMES  return library names
    d = dir( fullfile(L_path,'opencv_*d.lib') );
    l = regexp({d.name}, '(opencv_.+)d\.lib', 'tokens', 'once');
    l = [l{:}];
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
