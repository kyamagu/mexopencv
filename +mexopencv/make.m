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
% * __progress__ show a progress bar GUI during compilation (Windows only).
%       default `true`
% * __extra__ extra arguments passed to Unix make command. default `''`
%
% ## Examples
%    mexopencv.make('opencv_path', pathname)      % Windows only
%    mexopencv.make('clean',true)                 % clean MEX files
%    mexopencv.make('test',true)                  % run unittests
%    mexopencv.make('dryrun',true, 'force',true)  % print commands used to build
%    mexopencv.make(..., 'progress',true)         % show progress bar
%
% See also mex
%

MEXOPENCV_ROOT = mexopencv.root();

% navigate to directory
cwd = cd(MEXOPENCV_ROOT);
cObj = onCleanup(@()cd(cwd));

% parse options
opts = getargs(varargin{:});

if ispc % Windows
    % Clean
    if opts.clean
        fprintf('Cleaning all generated files...\n');

        cmd = fullfile(MEXOPENCV_ROOT, '+cv', ['*.' mexext]);
        disp(cmd);
        if ~opts.dryrun, delete(cmd); end

        cmd = fullfile(MEXOPENCV_ROOT, '+cv', 'private', ['*.' mexext]);
        disp(cmd);
        if ~opts.dryrun, delete(cmd); end

        cmd = fullfile(MEXOPENCV_ROOT, 'lib', '*.obj');
        disp(cmd);
        if ~opts.dryrun, delete(cmd); end

        return;
    end

    % Unittests
    if opts.test
        cd(fullfile(MEXOPENCV_ROOT,'test'));
        if ~opts.dryrun, UnitTest(); end
        return;
    end

    % compile flags
    [cv_cflags,cv_libs] = pkg_config(opts.opencv_path);
    mex_flags = sprintf('-largeArrayDims -D_SECURE_SCL=%d -I"%s" %s %s',...
        true, fullfile(MEXOPENCV_ROOT,'include'), cv_cflags, cv_libs);

    % Compile MxArray
    src = fullfile(MEXOPENCV_ROOT,'src','MxArray.cpp');
    dst = fullfile(MEXOPENCV_ROOT,'lib','MxArray.obj');
    if compile_needed(src, dst) || opts.force
        cmd = sprintf('mex %s -c "%s" -outdir "%s"', ...
            mex_flags, src, fileparts(dst));
        cmd = strrep(cmd, '"', '''');  % replace with escaped single quotes
        disp(cmd);
        if ~opts.dryrun, eval(cmd); end
        opts.force = true;
    else
        fprintf('Skipped "%s"\n', src);
    end
    if ~exist(dst, 'file') && ~opts.dryrun
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
    if opts.progressbar
        hWait = waitbar(0, 'Compiling MEX files...');
    end
    for i = 1:numel(srcs)
        if opts.progressbar
            waitbar(i/numel(srcs), hWait);
        end
        src = fullfile(MEXOPENCV_ROOT,'src','+cv',[srcs{i} '.cpp']);
        dst = fullfile(MEXOPENCV_ROOT,'+cv',srcs{i});
        fulldst = [dst, '.', mexext];
        if compile_needed(src, fulldst) || opts.force
            cmd = sprintf('mex %s "%s" "%s" -output "%s"',...
                mex_flags, src, obj, dst);
            cmd = strrep(cmd, '"', '''');  % replace with escaped single quotes
            disp(cmd);
            if ~opts.dryrun, eval(cmd); end
        else
            fprintf('Skipped "%s"\n', src);
        end
    end
    if opts.progressbar
        close(hWait);
    end

else % Unix
    options = { sprintf('OPENCV_DIR="%s"',opts.opencv_path) };
    if opts.dryrun         , options = [options '--dry-run']; end
    if opts.force          , options = [options '--always-make']; end
    if opts.clean          , options = [options 'clean']; end
    if opts.test           , options = [options 'test']; end
    if ~isempty(opts.extra), options = [options opts.extra]; end

    cmd = sprintf('make MATLABDIR="%s" MEXEXT=%s %s', ...
        matlabroot, mexext, sprintf(' %s', options{:}));
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

    if ~exist(I_path,'dir')
        error('mexopencv:make', 'OpenCV include path not found: %s', I_path);
    end
    if ~exist(L_path,'dir')
        error('mexopencv:make', 'OpenCV library path not found: %s', L_path);
    end

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
function opts = getargs(varargin)
    %GETARGS  Process parameter name/value pairs

    % default values
    opts.opencv_path = 'C:\opencv';  % OpenCV location
    opts.clean = false;              % clean mode
    opts.test = false;               % unittest mode
    opts.dryrun = false;             % dry run mode
    opts.force = false;              % force recompilation of all files
    opts.progressbar = true;         % show a progress bar GUI during compilation
    opts.extra = '';                 % extra options to be passed to MAKE (Unix only)

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
                opts.opencv_path = char(val);
            case 'clean'
                opts.clean = logical(val);
            case 'test'
                opts.test = logical(val);
            case 'dryrun'
                opts.dryrun = logical(val);
            case 'force'
                opts.force = logical(val);
            case 'progress'
                opts.progressbar = logical(val);
            case 'extra'
                opts.extra = char(val);
            otherwise
                error('mexopencv:make', 'Invalid parameter name:  %s.', pname);
        end
    end
end
