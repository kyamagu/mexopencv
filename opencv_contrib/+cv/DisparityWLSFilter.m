classdef DisparityWLSFilter < handle
    %DISPARITYWLSFILTER  Disparity map filter based on Weighted Least Squares filter
    %
    % Disparity map filter based on Weighted Least Squares filter (in form of
    % Fast Global Smoother that is a lot faster than traditional Weighted
    % Least Squares filter implementations) and optional use of
    % left-right-consistency-based confidence to refine the results in
    % half-occlusions and uniform areas.
    %
    % See also: cv.DisparityWLSFilter.DisparityWLSFilter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Lambda is a parameter defining the amount of regularization during
        % filtering.
        %
        % Larger values force filtered disparity map edges to adhere more to
        % source image edges. Typical value is 8000.
        Lambda
        % SigmaColor is a parameter defining how sensitive the filtering
        % process is to source image edges.
        %
        % Large values can lead to disparity leakage through low-contrast
        % edges. Small values can make the filter too sensitive to noise and
        % textures in the source image. Typical values range from 0.8 to 2.0.
        SigmaColor
        % LRCthresh is a threshold of disparity difference used in
        % left-right-consistency check during confidence map computation.
        %
        % The default value of 24 (1.5 pixels) is virtually always good
        % enough.
        LRCthresh
        % DepthDiscontinuityRadius is a parameter used in confidence
        % computation.
        %
        % It defines the size of low-confidence regions around depth
        % discontinuities.
        DepthDiscontinuityRadius
    end

    methods
        function this = DisparityWLSFilter(in)
            %DISPARITYWLSFILTER  Factory method to create instance of DisparityWLSFilter
            %
            %     obj = cv.DisparityWLSFilter(matcher_left)
            %     obj = cv.DisparityWLSFilter(use_confidence)
            %
            % ## Input
            % * **matcher_left** stereo matcher instance that will be used
            %   with the filter. An object of one of the following classes:
            %   * __cv.StereoBM__ stereo correspondence using the block
            %     matching algorithm.
            %   * __cv.StereoSGBM__ stereo correspondence using the
            %     semi-global block matching algorithm.
            % * **use_confidence** Boolean. Filtering with confidence requires
            %   two disparity maps (for the left and right views) and is
            %   approximately two times slower. However, quality is typically
            %   significantly better.
            %
            % The first variant is a convenience factory method that creates
            % an instance of DisparityWLSFilter and sets up all the relevant
            % filter parameters automatically based on the matcher instance.
            % Currently supports only cv.StereoBM and cv.StereoSGBM.
            %
            % The second variant is a more generic factory method, that create
            % instance of DisparityWLSFilter and execute basic initialization
            % routines. When using this method you will need to set-up the
            % ROI, matchers and other parameters by yourself.
            %
            % See also: cv.DisparityWLSFilter.filter,
            %  cv.DisparityWLSFilter.createRightMatcher
            %
            if isobject(in)
                props = cv.DisparityWLSFilter.StereoMatcher2Cell(in);
                this.id = DisparityWLSFilter_(0, 'new', props);
            else
                this.id = DisparityWLSFilter_(0, 'new', in);
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.DisparityWLSFilter
            %
            if isempty(this.id), return; end
            DisparityWLSFilter_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.DisparityWLSFilter.empty, cv.DisparityWLSFilter.load
            %
            DisparityWLSFilter_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.DisparityWLSFilter.clear, cv.DisparityWLSFilter.load
            %
            b = DisparityWLSFilter_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.DisparityWLSFilter.load
            %
            DisparityWLSFilter_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.DisparityWLSFilter.save
            %
            DisparityWLSFilter_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.DisparityWLSFilter.save, cv.DisparityWLSFilter.load
            %
            name = DisparityWLSFilter_(this.id, 'getDefaultName');
        end
    end

    %% DisparityFilter
    methods
        function filtered_disparity_map = filter(this, disparity_map_left, disparity_map_right, left_view, varargin)
            %FILTER  Apply filtering to the disparity map
            %
            %     filtered_disparity_map = obj.filter(disparity_map_left, disparity_map_right, left_view)
            %     filtered_disparity_map = obj.filter(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * **disparity_map_left** disparity map of the left view,
            %   1-channel `int16` or `single` type. Implicitly assumes that
            %   disparity values are scaled by 16 (one-pixel disparity
            %   corresponds to the value of 16 in the disparity map). Disparity
            %   map can have any resolution, it will be automatically resized
            %   to fit `left_view` resolution.
            % * **disparity_map_right** optional argument, some
            %   implementations might also use the disparity map of the right
            %   view to compute confidence maps, for instance. Pass an empty
            %   matrix `[]` if not used.
            % * **left_view** left view of the original stereo-pair to guide
            %   the filtering process, 8-bit single-channel or three-channel
            %   image.
            %
            % ## Output
            % * **filtered_disparity_map** output disparity map.
            %
            % ## Options
            % * __ROI__ region of the disparity map to filter. Optional,
            %   usually it should be set automatically. Not set by default.
            % * __RightView__ optional argument, some implementations might
            %   also use the right view of the original stereo-pair. Not set
            %   by default.
            %
            % See also: cv.DisparityWLSFilter.DisparityWLSFilter
            %
            filtered_disparity_map = DisparityWLSFilter_(this.id, 'filter', ...
                disparity_map_left, disparity_map_right, left_view, varargin{:});
        end
    end

    %% DisparityWLSFilter
    methods
        function map = getConfidenceMap(this)
            %GETCONFIDENCEMAP  Get the confidence map that was used in the last filter call
            %
            %     map = obj.getConfidenceMap()
            %
            % ## Output
            % * __map__ confidence map. It is a `single` one-channel image
            %   with values ranging from 0.0 (totally untrusted regions of the
            %   raw disparity map) to 255.0 (regions containing correct
            %   disparity values with a high degree of confidence).
            %
            % See also: cv.DisparityWLSFilter.getROI
            %
            map = DisparityWLSFilter_(this.id, 'getConfidenceMap');
        end

        function rect = getROI(this)
            %GETROI  Get the ROI used in the last filter call
            %
            %     rect = obj.getROI()
            %
            % ## Output
            % * __rect__ region of interest `[x,y,w,h]`.
            %
            % See also: cv.DisparityWLSFilter.getConfidenceMap
            %
            rect = DisparityWLSFilter_(this.id, 'getROI');
        end
    end

    %% Getters/Setters
    methods
        function value = get.Lambda(this)
            value = DisparityWLSFilter_(this.id, 'get', 'Lambda');
        end
        function set.Lambda(this, value)
            DisparityWLSFilter_(this.id, 'set', 'Lambda', value);
        end

        function value = get.SigmaColor(this)
            value = DisparityWLSFilter_(this.id, 'get', 'SigmaColor');
        end
        function set.SigmaColor(this, value)
            DisparityWLSFilter_(this.id, 'set', 'SigmaColor', value);
        end

        function value = get.LRCthresh(this)
            value = DisparityWLSFilter_(this.id, 'get', 'LRCthresh');
        end
        function set.LRCthresh(this, value)
            DisparityWLSFilter_(this.id, 'set', 'LRCthresh', value);
        end

        function value = get.DepthDiscontinuityRadius(this)
            value = DisparityWLSFilter_(this.id, 'get', 'DepthDiscontinuityRadius');
        end
        function set.DepthDiscontinuityRadius(this, value)
            DisparityWLSFilter_(this.id, 'set', 'DepthDiscontinuityRadius', value);
        end
    end

    %% Static methods
    methods (Static)
        function matcher_right = createRightMatcher(matcher_left)
            %CREATERIGHTMATCHER  Convenience method to set up the matcher for computing the right-view disparity map that is required in case of filtering with confidence
            %
            %     matcher_right = cv.DisparityWLSFilter.createRightMatcher(matcher_left)
            %
            % ## Input
            % * **matcher_left** main stereo matcher instance that will be used
            %   with the filter. An object of one of the following classes:
            %   * __cv.StereoBM__ stereo correspondence using the block
            %     matching algorithm.
            %   * __cv.StereoSGBM__ stereo correspondence using the
            %     semi-global block matching algorithm.
            %
            % ## Output
            % * **matcher_right** output right matcher. An object of same
            %   class as `matcher_left`.
            %
            % See also: cv.DisparityWLSFilter.DisparityWLSFilter,
            %  cv.StereoBM, cv.StereoSGBM
            %
            props_left = cv.DisparityWLSFilter.StereoMatcher2Cell(matcher_left);
            props_right = DisparityWLSFilter_(0, 'createRightMatcher', props_left);
            matcher_right = cv.DisparityWLSFilter.Struct2StereoMatcher(props_right);
        end

        function dst = readGT(src_path)
            %READGT  Function for reading ground truth disparity maps
            %
            %     dst = cv.DisparityWLSFilter.readGT(src_path)
            %
            % ## Input
            % * **src_path**  path to the image, containing ground-truth
            %   disparity map.
            %
            % ## Output
            % * __dst__ output disparity map, `int16` depth.
            %
            % Supports basic Middlebury and MPI-Sintel formats. Note that the
            % resulting disparity map is scaled by 16.
            %
            % See also: cv.readOpticalFlow
            %
            dst = DisparityWLSFilter_(0, 'readGT', src_path);
        end

        function mse = computeMSE(GT, src, varargin)
            %COMPUTEMSE  Function for computing mean square error for disparity maps
            %
            %     mse = cv.DisparityWLSFilter.computeMSE(GT, src)
            %     mse = cv.DisparityWLSFilter.computeMSE(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __GT__ ground truth disparity map (`int16` or `single`).
            % * __src__ disparity map to evaluate (`int16` or `single`).
            %
            % ## Output
            % * __mse__ returns mean square error between `GT` and `src`.
            %
            % ## Options
            % * __ROI__ region of interest `[x,y,w,h]`. Not set by default.
            %
            % See also: cv.DisparityWLSFilter.computeBadPixelPercent
            %
            mse = DisparityWLSFilter_(0, 'computeMSE', GT, src, varargin{:});
        end

        function prcnt = computeBadPixelPercent(GT, src, varargin)
            %COMPUTEBADPIXELPERCENT  Function for computing the percent of "bad" pixels in the disparity map
            %
            %     prcnt = cv.DisparityWLSFilter.computeBadPixelPercent(GT, src)
            %     prcnt = cv.DisparityWLSFilter.computeBadPixelPercent(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __GT__ ground truth disparity map (`int16` or `single`).
            % * __src__ disparity map to evaluate (`int16` or `single`).
            %
            % ## Output
            % * __prcnt__ returns percent of "bad" pixels between `GT` and
            %   `src` (pixels where error is higher than a specified
            %   threshold).
            %
            % ## Options
            % * __ROI__ region of interest `[x,y,w,h]`. Not set by default.
            % * __Thresh__ threshold used to determine "bad" pixels. default 24
            %
            % See also: cv.DisparityWLSFilter.computeMSE
            %
            prcnt = DisparityWLSFilter_(0, 'computeBadPixelPercent', ...
                GT, src, varargin{:});
        end

        function dst = getDisparityVis(src, varargin)
            %GETDISPARITYVIS  Function for creating a disparity map visualization
            %
            %     dst = cv.DisparityWLSFilter.getDisparityVis(src)
            %     dst = cv.DisparityWLSFilter.getDisparityVis(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ input disparity map (`int16` or `single` depth).
            %
            % ## Output
            % * __dst__ output visualization (clamped `uint8` image).
            %
            % ## Options
            % * __Scale__ disparity map will be multiplied by this value for
            %   visualization. default 1.0
            %
            % See also: cv.DisparityWLSFilter.readGT
            %
            dst = DisparityWLSFilter_(0, 'getDisparityVis', src, varargin{:});
        end
    end

    %% Helper functions
    methods (Static, Access = private)
        function C = StereoMatcher2Cell(matcher)
            %STEREOMATCHER2CELL  Convert StereoMatcher object to a cell array of options
            %
            %     C = cv.DisparityWLSFilter.StereoMatcher2Cell(matcher)
            %
            % ## Input
            % * __matcher__ input matcher object.
            %
            % ## Output
            % * __C__ output cell array.
            %
            % See also: cv.DisparityWLSFilter.Struct2StereoMatcher
            %

            assert(isobject(matcher) && isscalar(matcher));
            C = {};

            % object class name
            if isa(matcher, 'cv.StereoSGBM')
                C{end+1} = 'StereoSGBM';
            elseif isa(matcher, 'cv.StereoBM')
                C{end+1} = 'StereoBM';
            else
                error('mexopencv:error', 'Expecting a StereoMatcher object');
            end

            % object properties (as name/value pairs)
            %p = properties(matcher);  %HACK: Octave doesnt like this, throws syntax error!
            mc = metaclass(matcher);
            if ~mexopencv.isOctave() && isprop(mc, 'PropertyList')
                p = {mc.PropertyList.Name};
            else
                %HACK: backward-compatible and Octave
                p = cellfun(@(x) x.Name, mc.Properties, 'UniformOutput',false);
            end
            for i=1:numel(p)
                if strcmp(p{i}, 'id'), continue; end
                C{end+1} = p{i};
                C{end+1} = matcher.(p{i});
            end
        end

        function matcher = Struct2StereoMatcher(S)
            %STRUCT2STEREOMATCHER  Convert a struct of options to a StereoMatcher object
            %
            %     matcher = cv.DisparityWLSFilter.Struct2StereoMatcher(S)
            %
            % ## Input
            % * __S__ input struct.
            %
            % ## Output
            % * __matcher__ output matcher object.
            %
            % See also: cv.DisparityWLSFilter.StereoMatcher2Cell
            %

            assert(isstruct(S) && isscalar(S));

            % create StereoMatcher instance
            if ~isempty(strfind(S.TypeId, 'SGBM'))
                matcher = cv.StereoSGBM();
            elseif ~isempty(strfind(S.TypeId, 'BM'))
                matcher = cv.StereoBM();
            else
                error('mexopencv:error', 'Unexpected object type');
            end

            % set object properties
            p = fieldnames(S);
            for i=1:numel(p)
                if strcmp(p{i}, 'TypeId'), continue; end
                matcher.(p{i}) = S.(p{i});
            end
        end
    end

end
