function make(varargin)
%MAKE  Compile MEX-functions
%
%    mexopencv.make
%    mexopencv.make('OptionName', optionValue, ...)
%
% Make builds mexopencv library. In Unix, this function invokes Makefile
% in the project root. In Windows, the function takes an optional argument
% to specify installed OpenCV path.
%
% ## Options
% * **opencv_path** string specifying the path to OpenCV installation
%       default `'C:\OpenCV'`
% * __clean__ clean all compiled MEX files. default `false`
% * __test__ run all unit-tests. default `false`
% * __dryrun__ dont actually run commands, just print them. default `false`
% * __force__ Unconditionally build all files. default `false`
% * __extra__ extra arguments passed to Unix make command. default `''`
%
% ## Examples
%    mexopencv.make('opencv_path', pathname)      % Windows only
%    mexopencv.make('clean',true)                 % clean MEX files
%    mexopencv.make('test',true)                  % run unittests
%    mexopencv.make('dryrun',true, 'force',true)  % print commands used to build
%
% See also mex
%

MEXOPENCV_ROOT = mexopencv.root();

% navigate to directory
cwd = cd(MEXOPENCV_ROOT);
cObj = onCleanup(@()cd(cwd));

% parse options
[opencv_path,clean_mode,test_mode,dry_run,force,extra] = getargs(varargin{:});

if ispc % Windows
    % Clean
    if clean_mode
        fprintf('Cleaning all generated files...\n');

        cmd = fullfile(MEXOPENCV_ROOT, '+cv', ['*.' mexext]);
        disp(cmd);
        if ~dry_run, delete(cmd); end

        cmd = fullfile(MEXOPENCV_ROOT, '+cv', 'private', ['*.' mexext]);
        disp(cmd);
        if ~dry_run, delete(cmd); end

        cmd = fullfile(MEXOPENCV_ROOT, 'lib', '*.obj');
        disp(cmd);
        if ~dry_run, delete(cmd); end

        return;
    end

    % Unittests
    if test_mode
        cd(fullfile(MEXOPENCV_ROOT,'test'));
        if ~dry_run, UnitTest(); end
        return;
    end

    % compile flags
    [cv_cflags,cv_libs] = pkg_config(opencv_path);
    mex_flags = sprintf('-largeArrayDims -D_SECURE_SCL=%d -I"%s" %s %s',...
        true, fullfile(MEXOPENCV_ROOT,'include'), cv_cflags, cv_libs);

    % Compile MxArray
    src = fullfile(MEXOPENCV_ROOT,'src','MxArray.cpp');
    dst = fullfile(MEXOPENCV_ROOT,'lib','MxArray.obj');
    if compile_needed(src, dst) || force
        cmd = sprintf('mex %s -c "%s" -outdir "%s"', ...
            mex_flags, src, fileparts(dst));
        cmd = strrep(cmd, '"', '''');  % replace with escaped single quotes
        disp(cmd);
        if ~dry_run, eval(cmd); end
        force = true;
    else
        fprintf('Skipped "%s"\n', src);
    end
    if ~exist(dst, 'file') && ~dry_run
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
            if ~dry_run, eval(cmd); end
        else
            fprintf('Skipped "%s"\n', src);
        end
    end
else % Unix
    opts = { sprintf('OPENCV_DIR="%s"',opencv_path) };
    if dry_run, opts = [opts '--dry-run']; end
    if force, opts = [opts '--always-make']; end
    if clean_mode, opts = [opts 'clean']; end
    if test_mode, opts = [opts 'test']; end
    if ~isempty(extra), opts = [opts extra]; end

    cmd = sprintf('make MATLABDIR="%s" MEXEXT=%s %s', ...
        matlabroot, mexext, sprintf(' %s', opts{:}));
    disp(cmd);
    system(cmd);
end

end

%
% Helper functions for windows
%
function [cflags,libs] = pkg_config(opencv_path)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    I_path = fullfile(opencv_path,'build','include');
    L_path = fullfile(opencv_path,'build',arch_str(),compiler_str(),'lib');
    l_options = strcat({' -l'}, lib_names(L_path));
    l_options = [l_options{:}];

    cflags = sprintf('-I"%s"', I_path);
    libs = sprintf('-L"%s" %s', L_path, l_options);
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
        if ~isempty(strfind(c.Version, '11.0'))       % vc2012
            s = 'vc11';
        elseif ~isempty(strfind(c.Version, '10.0'))   % vc2010
            s = 'vc10';
        elseif ~isempty(strfind(c.Version, '9.0'))    % vc2008
            s = 'vc9';
        else
            error('mexopencv:make', 'Unsupported compiler');
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

%
% Helper function to parse options
%
function [opencv_path,clean_mode,test_mode,dry_run,force,extra] = getargs(varargin)
    %GETARGS  Process parameter name/value pairs

    % default values
    opencv_path = 'C:\opencv';  % OpenCV location
    clean_mode = false;         % clean mode
    test_mode = false;          % unittest mode
    dry_run = false;            % dry run mode
    force = false;              % force recompilation of all files
    extra = '';                 % extra options to be passed to MAKE (Unix only)

    nargs = length(varargin);
    if mod(nargs,2)~=0
        error('mexopencv:make', 'Wrong number of arguments.');
    end

    % parse options
    for i=1:2:nargs
        pname = varargin{i};
        val = varargin{i+1};
        switch lower(pname)
            case 'opencv_path'
                opencv_path = val;
            case 'clean'
                clean_mode = val;
            case 'test'
                test_mode = val;
            case 'dryrun'
                dry_run = val;
            case 'force'
                force = val;
            case 'extra'
                extra = val;
            otherwise
                error('mexopencv:make', 'Invalid parameter name:  %s.', pname);
        end
    end
end
