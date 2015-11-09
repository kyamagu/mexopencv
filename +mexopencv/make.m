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
%       default `'C:\OpenCV\build'`
% * **opencv_contrib** flag to indicate whether optional opencv modules are
%       available or not. These can only be selected in OpenCV at compile-time.
%       default `false`.
% * __clean__ clean all compiled MEX files. default `false`
% * __test__ run all unit-tests. default `false`
% * __dryrun__ dont actually run commands, just print them. default `false`
% * __force__ Unconditionally build all files. default `false`
% * __verbose__ output verbosity. The higher the number, the more output
%       is shown. default 1
%      * __0__ no output at all
%      * __1__ echo commands and information messages only
%      * __2__ verbose output from mex
%      * __3__ show all compile/link warnings and errors
% * __progress__ show a progress bar GUI during compilation (Windows only).
%       default `true`
% * __debug__ Produce binaries with debugging information, linked against
%       the debug version of OpenCV libraries. default false
% * __extra__ extra arguments passed to Unix make command. default `''`
%
% ## Examples
%
%    mexopencv.make('opencv_path', pathname)      % Windows only
%    mexopencv.make(..., 'opencv_contrib', true)  % build with contrib modules
%    mexopencv.make('clean',true)                 % clean MEX files
%    mexopencv.make('test',true)                  % run unittests
%    mexopencv.make('dryrun',true, 'force',true)  % print commands used to build
%    mexopencv.make(..., 'verbose',2)             % verbose compiler output
%    mexopencv.make(..., 'progress',true)         % show progress bar
%    mexopencv.make(..., 'debug',true)            % enalbe debugging symbols
%    mexopencv.make('extra','--jobs=2')           % instruct Make to execute N
%                                                 %  jobs in parallel (Unix only)
%
% See also: mex
%

% navigate to directory
cwd = cd(mexopencv.root());
cObj = onCleanup(@()cd(cwd));

% parse options
opts = getargs(varargin{:});

if ispc % Windows
    % Clean
    if opts.clean
        if opts.verbose > 0
            fprintf('Cleaning all generated files...\n');
        end

        del_cmds = {
            fullfile('+cv', ['*.' mexext]) ;
            fullfile('+cv', '*.pdb') ;
            fullfile('+cv', '*.idb') ;
            fullfile('+cv', 'private', ['*.' mexext]) ;
            fullfile('+cv', 'private', '*.pdb') ;
            fullfile('+cv', 'private', '*.idb') ;
            fullfile('+cv', '+test', 'private', ['*.' mexext]) ;
            fullfile('+cv', '+test', 'private', '*.pdb') ;
            fullfile('+cv', '+test', 'private', '*.idb') ;
            fullfile('lib', '*.obj') ;
            fullfile('lib', '*.o') ;
            fullfile('lib', '*.lib') ;
            fullfile('lib', '*.pdb') ;
            fullfile('lib', '*.idb')
        };
        if opts.opencv_contrib
            del_cmds = [del_cmds ; ...
                fullfile('opencv_contrib', '+cv', ['*.' mexext]) ; ...
                fullfile('opencv_contrib', '+cv', '*.pdb') ; ...
                fullfile('opencv_contrib', '+cv', '*.idb') ; ...
                fullfile('opencv_contrib', '+cv', 'private', ['*.' mexext]) ; ...
                fullfile('opencv_contrib', '+cv', 'private', '*.pdb') ; ...
                fullfile('opencv_contrib', '+cv', 'private', '*.idb') ...
            ];
        end

        for i=1:numel(del_cmds)
            cmd = fullfile(mexopencv.root(), del_cmds{i});
            if opts.verbose > 0, disp(cmd); end
            if ~opts.dryrun, delete(cmd); end
        end

        return;
    end

    % Unit-testing
    if opts.test
        if opts.verbose > 0
            fprintf('Running unit-tests...\n');
        end

        cd(fullfile(mexopencv.root(),'test'));
        if ~opts.dryrun, UnitTest(opts.opencv_contrib); end
        return;
    end

    % mex build options
    [cv_cflags,cv_libs] = pkg_config(opts);
    [comp_flags,link_flags] = compilation_flags(opts);
    mex_flags = sprintf('%s %s -I''%s'' %s %s',...
        comp_flags, link_flags, fullfile(mexopencv.root(),'include'), ...
        cv_cflags, cv_libs);
    if ~mexopencv.isOctave()
        mex_flags = ['-largeArrayDims ' mex_flags];
    end
    if opts.verbose > 1
        mex_flags = ['-v ' mex_flags];    % verbose mex output
    elseif opts.verbose == 0 && ~mexopencv.isOctave() && ~verLessThan('matlab', '8.3')
        mex_flags = ['-silent ' mex_flags];  % R2014a
    end
    if opts.debug
        mex_flags = ['-g ' mex_flags];    % debug vs. optimized builds
    else
        if ~mexopencv.isOctave()
            mex_flags = ['-O ' mex_flags];
        else
            mex_flags = ['-O2 ' mex_flags];
        end
    end

    % Compile MxArray and any other shared sources into OBJs (compile-only)
    if ~mexopencv.isOctave()
        objext = 'obj';
    else
        objext = 'o';
    end
    files = prepare_source_files(...
        fullfile(mexopencv.root(),'src'), 'cpp', ...
        fullfile(mexopencv.root(),'lib'), objext);
    for i=1:numel(files)
        if opts.force || compile_needed(files(i).src, files(i).dst)
            if ~mexopencv.isOctave()
                cmd = sprintf('mex %s -c ''%s'' -outdir ''%s''', ...
                    mex_flags, files(i).src, fullfile(mexopencv.root(),'lib'));
            else
                cmd = sprintf('mex %s -c ''%s'' -o ''%s''', ...
                    mex_flags, files(i).src, files(i).dst);
            end
            if opts.verbose > 0, disp(cmd); end
            if ~opts.dryrun, eval(cmd); end
            opts.force = true;  % dependency changed, invalidate all MEX-files
        else
            if opts.verbose > 0, fprintf('Skipped "%s"\n', files(i).src); end
        end
        if ~opts.dryrun && ~exist(files(i).dst, 'file')
            error('mexopencv:make', 'Failed to compile "%s"', files(i).src);
        end
    end
    objs = strtrim(sprintf(' ''%s''',files.dst));
    %objs = fullfile(mexopencv.root(),'lib',['*.' objext]);

    % Build MEX files
    files = collect_mex_files(opts);
    if opts.progressbar
        if ~mexopencv.isOctave()
            cancellation = {'CreateCancelBtn','setappdata(gcbf,''cancel'',true)'};
        else
            %TODO: https://savannah.gnu.org/bugs/?45364
            cancellation = {};
        end
        hWait = waitbar(0, 'Compiling MEX files...', ...
            'Name','mexopencv', cancellation{:});
        setappdata(hWait, 'cancel',false);
        wbCleanObj = onCleanup(@() delete(hWait));  % close(hWait)
    end
    for i = 1:numel(files)
        if opts.progressbar
            waitbar(i/numel(files), hWait, strrep(files(i).name,'_','\_'));
            if getappdata(hWait, 'cancel'), break; end
        end
        if opts.force || compile_needed(files(i).src, files(i).dst)
            if ~mexopencv.isOctave()
                cmd = sprintf('mex %s ''%s'' %s -output ''%s''',...
                    mex_flags, files(i).src, objs, files(i).out);
            else
                cmd = sprintf('mex %s ''%s'' %s -o ''%s''',...
                    mex_flags, files(i).src, objs, files(i).dst);
            end
            if opts.verbose > 0, disp(cmd); end
            if ~opts.dryrun, eval(cmd); end
        else
            if opts.verbose > 0, fprintf('Skipped "%s"\n', files(i).src); end
        end
        if ~opts.dryrun && ~exist(files(i).dst, 'file')
            error('mexopencv:make', 'Failed to compile "%s"', files(i).src);
        end
    end

    % Octave mex command leaves behind temporary obj files in current dir
    if ~opts.dryrun && mexopencv.isOctave()
        delete(fullfile(mexopencv.root(),'*.o'));
    end

    % check both OpenCV/mexopencv folders are on the appropriate paths
    check_path_opencv(opts);
    check_path_mexopencv(opts);

else % Unix
    options = {};
    if mexopencv.isOctave(), options = [options 'WITH_OCTAVE=1']; end
    if opts.dryrun         , options = [options '--dry-run']; end
    if opts.force          , options = [options '--always-make']; end
    if opts.verbose < 1    , options = [options '--silent']; end
    if opts.verbose > 1    , options = [options 'CFLAGS+=-v']; end
    if opts.debug          , options = [options 'CFLAGS+=-g']; end
    if ~isempty(opts.extra), options = [options opts.extra]; end

    targets = {'all'};
    if opts.clean          , targets = ['clean' targets]; end
    if opts.opencv_contrib , targets = [targets 'contrib']; end
    if opts.test           , targets = [targets 'test']; end

    % call Makefile
    cmd = sprintf('make MATLABDIR="%s" MEXEXT=%s %s %s', ...
        matlabroot, mexext, ...
        sprintf(' %s', options{:}), sprintf(' %s', targets{:}));
    if opts.verbose > 0, disp(cmd); end
    system(cmd);
end

end

%%
% Helper functions for windows
%

function [cflags,libs] = pkg_config(opts)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    %

    I_path = fullfile(opts.opencv_path,'include');
    if ~exist(I_path,'dir')
        error('mexopencv:make', 'OpenCV include path not found: %s', I_path);
    end

    L_path = fullfile(opts.opencv_path,arch_str(),compiler_str(),'lib');
    if ~exist(L_path,'dir')
        error('mexopencv:make', 'OpenCV library path not found: %s', L_path);
    end

    l_options = strcat({' -l'}, lib_names(L_path));
    if opts.debug
        l_options = strcat(l_options,'d');    % link against debug binaries
    end
    l_options = [l_options{:}];

    cflags = sprintf('-I''%s''', I_path);
    libs = sprintf('-L''%s'' %s', L_path, l_options);
end

function s = arch_str()
    %ARCH_STR  return architecture used in mex
    %
    % See also: mexext, computer
    %
    persistent cacheval;
    if isempty(cacheval)
        if ~mexopencv.isOctave()
            pattern64 = '64';
        else
            pattern64 = 'x86_64';
        end
        if isempty(strfind(computer('arch'), pattern64))
            cacheval = 'x86';
        else
            cacheval = 'x64';
        end
    end
    s = cacheval;
end

function s = compiler_str()
    %COMPILER_STR  return compiler shortname
    %
    % See also: mex.getCompilerConfigurations
    %
    if mexopencv.isOctave()
        s = 'mingw';
    else
        s = '';
        cc = mex.getCompilerConfigurations('C++', 'Selected');
        if strcmp(cc.Manufacturer, 'Microsoft')
            if ~isempty(strfind(cc.Name, 'Visual'))  % Visual Studio
                switch cc.Version
                    case '14.0'
                        s = 'vc14';    % VS2015
                    case '12.0'
                        s = 'vc12';    % VS2013
                    case '11.0'
                        s = 'vc11';    % VS2012
                    case '10.0'
                        s = 'vc10';    % VS2010
                    case '9.0'
                        s = 'vc9';     % VS2008
                    case '8.0'
                        s = 'vc8';     % VS2005
                end
            elseif ~isempty(strfind(cc.Name, 'SDK'))  % Windows SDK
                switch cc.Version
                    case '8.1'
                        s = 'vc12';    % VS2013
                    case '8.0'
                        s = 'vc11';    % VS2012
                    case '7.1'
                        s = 'vc10';    % VS2010
                    case {'7.0', '6.1'}
                        s = 'vc9';     % VS2008
                    case '6.0'
                        s = 'vc8';     % VS2005
                end
            end
        elseif strcmp(cc.Manufacturer, 'Intel')  % Intel C++ Composer
            % TODO: check versions 11.0, 12.0, 13.0, 14.0, 15.0
        elseif ~isempty(strfind(cc.Name, 'GNU'))  % MinGW (GNU GCC)
            s = 'mingw';
        end
        if isempty(s)
            error('mexopencv:make', 'Unsupported compiler: %s', cc.Name);
        end
    end
end

function [comp_flags,link_flags] = compilation_flags(opts)
    %COMPILATION_FLAGS  return compiler/linker flags passed directly to them
    %
    % See also: mex.getCompilerConfigurations
    %

    % additional flags. default none
    comp_flags = {};
    link_flags = {};

    if ~mexopencv.isOctave()
        % override _SECURE_SCL for VS versions prior to VS2010,
        % or when linking against debug OpenCV binaries
        c = mex.getCompilerConfigurations('C++','Selected');
        isVS = strcmp(c.Manufacturer,'Microsoft') && ~isempty(strfind(c.Name,'Visual'));
        if isVS && (str2double(c.Version) < 10 || opts.debug)
            comp_flags{end+1} = '/D_SECURE_SCL=1';
        end
        if isVS && opts.debug
            comp_flags{end+1} = '/MDd';   % link against debug CRT
        end
    else
        comp_flags{end+1} = '-fpermissive';
    end

    % show all compiler warnings, and verbose output from linker
    if opts.verbose > 2
        comp_flags{end+1} = '-Wall';
        if ~mexopencv.isOctave()
            link_flags{end+1} = '/VERBOSE';
        else
            comp_flags{end+1} = '--verbose';
            link_flags{end+1} = '-Wl,--verbose';
        end
    end

    % construct the output strings
    comp_flags = strtrim(sprintf(' %s',comp_flags{:}));
    link_flags = strtrim(sprintf(' %s',link_flags{:}));
    if ~isempty(comp_flags)
        if ~mexopencv.isOctave()
            comp_flags = ['COMPFLAGS="$COMPFLAGS ' comp_flags '"'];
        else
            % mex/mkoctfile in Octave do not support directly passing options
            % to compiler/linker, instead we use environment variables
            setenv('CFLAGS',   comp_flags);
            setenv('CXXFLAGS', comp_flags);
            comp_flags = '';
        end
    end
    if ~isempty(link_flags)
        if ~mexopencv.isOctave()
            link_flags = ['LINKFLAGS="$LINKFLAGS ' link_flags '"'];
        else
            setenv('LDFLAGS',  link_flags);
            link_flags = '';
        end
    end
end

function l = lib_names(L_path)
    %LIB_NAMES  return library names
    %
    if ~mexopencv.isOctave()
        d = dir( fullfile(L_path,'opencv_*.lib') );
        l = unique(regexprep({d.name}, 'd?\.lib$', ''));
    else
        d = dir( fullfile(L_path,'libopencv_*.a') );
        l = unique(regexprep({d.name}, 'd?(?:\.dll)?\.a$', ''));
        l = regexprep(l, '^(?:lib)?', '');
    end
    if isempty(l)
        error('mexopencv:make', 'Failed to find OpenCV libraries in %s', L_path)
    end
end

function r = compile_needed(src, dst)
    %COMPILE_NEEDED  check timestamps
    %
    if ~exist(dst, 'file')
        r = true;
    else
        d1 = dir(src);
        d2 = dir(dst);
        r = (d1.datenum >= d2.datenum);
    end
end

function files = prepare_source_files(dir_src, src_ext, dir_dst, dst_ext)
    %PREPARE_SOURCE_FILES  Lists source files and corresponding targets
    %

    % get directory listing of sources
    f = dir(fullfile(dir_src,['*.' src_ext]));

    % base filenames
    [~,names] = cellfun(@fileparts, {f.name}, 'UniformOutput',false);

    % full source filenames
    srcs = cellfun(@(n) fullfile(dir_src,[n '.' src_ext]), names, 'Uniform',false);

    % destionation filenames (w/o extension)
    outs = cellfun(@(n) fullfile(dir_dst,n), names, 'Uniform',false);

    % full destination filenames (w/ extension)
    dsts = strcat(outs, ['.' dst_ext]);

    % return structure
    files = struct('name',names, 'src',srcs, 'dst',dsts, 'out',outs);
end

function files = collect_mex_files(opts)
    %COLLECT_MEX_FILES  Collect all source files to be compiled into MEX
    %

    files = {};

    % ROOT\src\+cv\*.cpp
    files{end+1} = prepare_source_files(...
        fullfile(mexopencv.root(),'src','+cv'), 'cpp', ...
        fullfile(mexopencv.root(),'+cv'), mexext);

    % ROOT\src\+cv\private\*.cpp
    files{end+1} = prepare_source_files(...
        fullfile(mexopencv.root(),'src','+cv','private'), 'cpp', ...
        fullfile(mexopencv.root(),'+cv','private'), mexext);

    % ROOT\src\+cv\+test\private\*.cpp
    files{end+1} = prepare_source_files(...
        fullfile(mexopencv.root(),'src','+cv','+test','private'), 'cpp', ...
        fullfile(mexopencv.root(),'+cv','+test','private'), mexext);

    if opts.opencv_contrib
        % ROOT\opencv_contrib\src\+cv\*.cpp
        files{end+1} = prepare_source_files(...
            fullfile(mexopencv.root(),'opencv_contrib','src','+cv'), 'cpp', ...
            fullfile(mexopencv.root(),'opencv_contrib','+cv'), mexext);

        % ROOT\opencv_contrib\src\+cv\private\*.cpp
        files{end+1} = prepare_source_files(...
            fullfile(mexopencv.root(),'opencv_contrib','src','+cv','private'), 'cpp', ...
            fullfile(mexopencv.root(),'opencv_contrib','+cv','private'), mexext);
    end

    % all combined as an array of structs
    files = [files{:}];
end

function check_path_opencv(opts)
    %CHECK_PATH_OPENCV  check OpenCV bin folder is on the system PATH env. var.
    %
    % See also: getenv, setenv
    %

    % check system PATH environment variable
    cv_folder = fullfile(opts.opencv_path,arch_str(),compiler_str(),'bin');
    p = getenv('PATH');
    C = textscan(p, '%s', 'Delimiter',pathsep());
    if ~any(strcmpi(cv_folder,C{1}))
        % reminder
        if opts.verbose > 0
            disp('To finish the setup, add OpenCV bin folder to the system');
            disp('PATH, then restart MATLAB for changes to take effect.');
            fprintf(' set PATH=%%PATH%%;%s\n', cv_folder);
        end

        % append opencv to PATH temporarily for this session
        if ~opts.dryrun
            setenv('PATH', [p pathsep() cv_folder]);
        end
    end
end

function check_path_mexopencv(opts)
    %CHECK_PATH_MEXOPENCV  check mexopencv is on MATLAB search path
    %
    % See also: path, addpath
    %

    % check MATLAB search path
    C = textscan(path(), '%s', 'Delimiter',pathsep());
    if ~any(strcmpi(mexopencv.root(), C{1}))
        % reminder
        if opts.verbose > 0
            disp('To use mexopencv, add its root folder to MATLAB search path.');
            fprintf(' addpath(''%s'')\n', mexopencv.root());
        end

        % add mexopencv to path temporarily for this session
        if ~opts.dryrun
            addpath(mexopencv.root(), '-end');
        end
    end
    if opts.opencv_contrib && ~opts.dryrun && ...
            ~any(strcmpi(fullfile(mexopencv.root(),'opencv_contrib'), C{1}))
        addpath(fullfile(mexopencv.root(),'opencv_contrib'), '-end');
    end
end

%%
% Helper function to parse options
%

function opts = getargs(varargin)
    %GETARGS  Process parameter name/value pairs
    %
    % See also: inputParser
    %

    % default values
    opts.opencv_path = 'C:\opencv\build';  % OpenCV location
    opts.opencv_contrib = false;     % optional/extra OpenCV modules
    opts.clean = false;              % clean mode
    opts.test = false;               % unittest mode
    opts.dryrun = false;             % dry run mode
    opts.force = false;              % force recompilation of all files
    opts.verbose = 1;                % output verbosity
    opts.progressbar = true;         % show a progress bar GUI during compilation
    opts.debug = false;              % enable debug symbols in MEX-files
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
            case 'opencv_contrib'
                opts.opencv_contrib = logical(val);
            case 'clean'
                opts.clean = logical(val);
            case 'test'
                opts.test = logical(val);
            case 'dryrun'
                opts.dryrun = logical(val);
            case 'force'
                opts.force = logical(val);
            case 'verbose'
                opts.verbose = double(val);
            case 'progress'
                opts.progressbar = logical(val);
            case 'extra'
                opts.extra = char(val);
            case 'debug'
                opts.debug = logical(val);
            otherwise
                error('mexopencv:make', 'Invalid parameter name:  %s.', pname);
        end
    end
end
