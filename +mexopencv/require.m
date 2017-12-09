function [status, v] = require(name)
    %REQUIRE  Check if a toolbox/package is available
    %
    %     [status, v] = mexopencv.require(name)
    %
    % ## Input
    % * __name__ name of toolbox/packge to check.
    %
    % ## Output
    % * __status__ boolean result of test.
    % * __v__ version struct.
    %
    % This function only handle a few commonly used toolboxes.
    % It works on both MATLAB and Octave.
    %
    % See also: ver, license, verLessThan, version, feature, pkg
    %

    narginchk(1,1);
    nargoutchk(0,2);
    validateattributes(name, {'char'}, {'row', 'nonempty'});

    % list of supported toolboxes
    toolboxes = get_toolboxes();

    % name of toolbox (lookup id)
    name = validatestring(name, toolboxes(:,1));
    idx = find(strcmp(name, toolboxes(:,1)));  % row index

    % corresponding product/feature name
    if mexopencv.isOctave()
        tbx_ver = toolboxes{idx,4};
        tbx_lic = toolboxes{idx,5};
    else
        tbx_ver = toolboxes{idx,2};
        tbx_lic = toolboxes{idx,3};
    end

    % check toolbox is available
    if ~isempty(tbx_ver) && ~isempty(tbx_lic)
        v = ver(tbx_ver);
        status = license('test', tbx_lic) && ~isempty(v);
    else
        v = struct([]);
        status = false;
    end

    % load package in Octave if not already loaded
    if status && mexopencv.isOctave()
        octave_pkg_load(tbx_ver);
    end
end

function toolboxes = get_toolboxes()
    % List of toolboxes/packages we recognize (both MATLAB and Octave)
    %   id         m_version  m_license                  o_version        o_license
    % -----------------------------------------------------------------------------
    toolboxes = {
        'matlab'   'matlab'   'matlab'                   ''               ''
        'octave'   ''         ''                         'octave'         'octave'
        'comm'     'comm'     'communication_toolbox'    'communications' 'communications'
        'control'  'control'  'control_toolbox'          'control'        'control'
        'curvefit' 'curvefit' 'curve_fitting_toolbox'    ''               ''
        'finance'  'finance'  'financial_toolbox'        'financial'      'financial'
        'images'   'images'   'image_toolbox'            'image'          'image'
        'nnet'     'nnet'     'neural_network_toolbox'   ''               ''
        'optim'    'optim'    'optimization_toolbox'     'optim'          'optim'
        'signal'   'signal'   'signal_toolbox'           'signal'         'signal'
        'stats'    'stats'    'statistics_toolbox'       'statistics'     'statistics'
        'symbolic' 'symbolic' 'symbolic_toolbox'         'symbolic'       'symbolic'
        'vision'   'vision'   'video_and_image_blockset' ''               ''
    };
end

function octave_pkg_load(name)
    if strcmp(name, 'octave')
        return;
    end
    [~,list] = pkg('list');                             % cell array of structs
    list = list(cellfun(@(s) s.loaded, list));          % loaded packages
    list = cellfun(@(s) s.name, list, 'Uniform',false); % name of packages
    if ~ismember(name, list)
        pkg('load', name);
    end
end
