function cvsetup(isContrib, rootCV)
    if nargin < 1, isContrib = false; end
    if nargin < 2, rootCV = getenv('OPENCV_DIR'); end
    rootMCV = fileparts(fileparts(mfilename('fullpath')));

    % initializations for Octave
    if isOctave()
        crash_dumps_octave_core(false);
        more('off');
        warning('off', 'Octave:shadowed-function');
        warning('off', 'Octave:GraphicsMagic-Quantum-Depth');
        try, pkg('load', 'statistics'); end
        try, pkg('load', 'image'); end
    end

    % add root dir of OpenCV to PATH env var
    if ispc() && isdir(rootCV)
        try
            p = fullfile(rootCV, arch(), compiler(), 'bin');
            setenv('PATH', [p pathsep() getenv('PATH')]);
        end
    end

    % add root dir of mexopencv to MATLAB path
    addpath(rootMCV);
    if isContrib
        addpath(fullfile(rootMCV, 'opencv_contrib'));
    end
    if isOctave()
        % HACK: we have to also add private directories to path in Octave
        % http://savannah.gnu.org/bugs/?45444
        addpath(fullfile(rootMCV, '+cv', 'private'));
        if isContrib
            addpath(fullfile(rootMCV, 'opencv_contrib', '+cv', 'private'));
        end
    end

    % tests
    addpath(fullfile(rootMCV, 'test'));
    addpath(fullfile(rootMCV, 'test', 'unit_tests'));
    if isContrib
        addpath(fullfile(rootMCV, 'opencv_contrib', 'test', 'unit_tests'));
    end

    % samples
    addpath(fullfile(rootMCV, 'samples'));
    addpath(fullfile(rootMCV, 'samples', 'common'));
    if isContrib
        addpath(fullfile(rootMCV, 'opencv_contrib', 'samples'));
    end

    % docs and utils
    addpath(fullfile(rootMCV, 'utils'));
    addpath(fullfile(rootMCV, 'doc'));
end

function b = isOctave()
    b = exist('OCTAVE_VERSION', 'builtin') == 5;
end

function s = arch()
    if isOctave()
        pattern64 = 'x86_64';
    else
        pattern64 = '64';
    end
    if isempty(strfind(computer('arch'), pattern64))
        s = 'x86';
    else
        s = 'x64';
    end
end

function s = compiler()
    if isOctave()
        s = 'mingw';
    else
        cc = mex.getCompilerConfigurations('C++', 'Selected');
        assert(~isempty(cc));
        switch cc.Manufacturer
            case 'Microsoft'
                assert(~isempty(strfind(cc.Name, 'Visual')));
                s = ['vc' sscanf(cc.Version, '%d', 1)];
            case 'GNU'
                s = 'mingw';
            otherwise
                s = '';
        end
        assert(~isempty(s));
    end
end
