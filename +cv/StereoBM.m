classdef StereoBM < handle
    %STEREOBM  Class for computing stereo correspondence using the block matching algorithm
    %
    % Class for computing stereo correspondence using the block matching
    % algorithm, introduced and contributed to OpenCV by K. Konolige.
    %
    % ## Usage
    %
    %    bm = cv.StereoBM('NumDisparities',0, ...);
    %    bm.MinDisparity = ...;
    %    disparity = bm.compute(left, right);
    %
    % See also: cv.StereoBM.StereoBM, cv.StereoBM.compute, cv.StereoSGBM,
    %  disparity
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Minimum possible disparity value, default 0
        MinDisparity
        % Maximum disparity minus minimum disparity, positive and divisble by
        % 16. default 64
        NumDisparities
        % SAD window size, odd within 5..255 and not larger than image width
        % or height. default 21
        BlockSize
        % Maximum size of smooth disparity regions to consider their noise
        % speckles and invalidate (when `SpeckleRange>=0` and
        % `SpeckleWindowSize>0`). See `maxSpeckleSize` in cv.filterSpeckles,
        % default 0
        SpeckleWindowSize
        % Maximum disparity variation within each connected component (when
        % `SpeckleRange>=0` and `SpeckleWindowSize>0`). See `maxDiff` in
        % cv.filterSpeckles, default 0
        SpeckleRange
        % Maximum allowed difference (in integer pixel units) in the
        % left-right disparity check (when `Disp12MaxDiff>=0`). see
        % cv.validateDisparity, default -1
        Disp12MaxDiff

        % pre-filtering type, one of: 'NormalizedResponse' or 'XSobel' (default)
        PreFilterType
        % pre-filtering size, odd and betweeen 5..255, default 9
        PreFilterSize
        % Truncation value for prefiltering image pixels, within 1..63,
        % default 31
        PreFilterCap
        % texture threshold, non-negative. default 10
        TextureThreshold
        % uniqueness ratio, non-negative. default 15
        UniquenessRatio
        % currently unused. default 0
        SmallerBlockSize
        % computes disparity for ROI in first image. default [0,0,0,0].
        % see cv.getValidDisparityROI
        ROI1
        % computes disparity for ROI in second image. default [0,0,0,0].
        % see cv.getValidDisparityROI
        ROI2
    end

    methods
        function this = StereoBM(varargin)
            %STEREOBM  Creates StereoBM object
            %
            %    bm = cv.StereoBM()
            %    bm = cv.StereoBM('OptionName', optionValue, ...)
            %
            % ## Options
            % * __NumDisparities__ the disparity search range. For each pixel
            %       algorithm will find the best disparity from 0 (default
            %       minimum disparity) to `NumDisparities`. The search range
            %       can then be shifted by changing the minimum disparity.
            %       default 0 (which uses 64 by default).
            % * __BlockSize__ the linear size of the blocks compared by the
            %       algorithm. The size should be odd (as the block is
            %       centered at the current pixel). Larger block size implies
            %       smoother, though less accurate disparity map. Smaller
            %       block size gives more detailed disparity map, but there is
            %       is higher chance for algorithm to find a wrong
            %       correspondence. default 21.
            %
            % The function creates cv.StereoBM object. You can then call
            % cv.StereoBM.compute to compute disparity for a specific stereo
            % pair.
            %
            % See also: cv.StereoBM.compute
            %
            this.id = StereoBM_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.StereoBM
            %
            StereoBM_(this.id, 'delete');
        end

        function disparity = compute(this, left, right)
            %COMPUTE  Computes disparity map for the specified stereo pair
            %
            %    disparity = bm.compute(left, right)
            %
            % ## Input
            % * __left__ Left 8-bit single-channel image.
            % * __right__ Right image of the same size and the same type as
            %       the left one.
            %
            % ## Output
            % * __disparity__ Output disparity map. It has the same size as
            %       the input images. Some algorithms, like cv.StereoBM or
            %       cv.StereoSGBM compute 16-bit fixed-point disparity map
            %       (where each disparity value has 4 fractional bits),
            %       whereas other algorithms output 32-bit floating-point
            %       disparity map.
            %
            % The method executes the BM algorithm on a rectified stereo pair.
            % Note that the method is not constant, thus you should not use
            % the same cv.StereoBM instance from within different threads
            % simultaneously.
            %
            % See also: cv.StereoBM.StereoBM
            %
            disparity = StereoBM_(this.id, 'compute', left, right);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.StereoBM.empty
            %
            StereoBM_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %       (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.StereoBM.clear
            %
            b = StereoBM_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier.
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.StereoBM.save, cv.StereoBM.load
            %
            name = StereoBM_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file.
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.StereoBM.load
            %
            StereoBM_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string.
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.StereoBM.save
            %
            StereoBM_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.PreFilterCap(this)
            value = StereoBM_(this.id, 'get', 'PreFilterCap');
        end
        function set.PreFilterCap(this, value)
            StereoBM_(this.id, 'set', 'PreFilterCap', value);
        end

        function value = get.PreFilterSize(this)
            value = StereoBM_(this.id, 'get', 'PreFilterSize');
        end
        function set.PreFilterSize(this, value)
            StereoBM_(this.id, 'set', 'PreFilterSize', value);
        end

        function value = get.PreFilterType(this)
            value = StereoBM_(this.id, 'get', 'PreFilterType');
        end
        function set.PreFilterType(this, value)
            StereoBM_(this.id, 'set', 'PreFilterType', value);
        end

        function value = get.ROI1(this)
            value = StereoBM_(this.id, 'get', 'ROI1');
        end
        function set.ROI1(this, value)
            StereoBM_(this.id, 'set', 'ROI1', value);
        end

        function value = get.ROI2(this)
            value = StereoBM_(this.id, 'get', 'ROI2');
        end
        function set.ROI2(this, value)
            StereoBM_(this.id, 'set', 'ROI2', value);
        end

        function value = get.SmallerBlockSize(this)
            value = StereoBM_(this.id, 'get', 'SmallerBlockSize');
        end
        function set.SmallerBlockSize(this, value)
            StereoBM_(this.id, 'set', 'SmallerBlockSize', value);
        end

        function value = get.TextureThreshold(this)
            value = StereoBM_(this.id, 'get', 'TextureThreshold');
        end
        function set.TextureThreshold(this, value)
            StereoBM_(this.id, 'set', 'TextureThreshold', value);
        end

        function value = get.UniquenessRatio(this)
            value = StereoBM_(this.id, 'get', 'UniquenessRatio');
        end
        function set.UniquenessRatio(this, value)
            StereoBM_(this.id, 'set', 'UniquenessRatio', value);
        end

        function value = get.BlockSize(this)
            value = StereoBM_(this.id, 'get', 'BlockSize');
        end
        function set.BlockSize(this, value)
            StereoBM_(this.id, 'set', 'BlockSize', value);
        end

        function value = get.Disp12MaxDiff(this)
            value = StereoBM_(this.id, 'get', 'Disp12MaxDiff');
        end
        function set.Disp12MaxDiff(this, value)
            StereoBM_(this.id, 'set', 'Disp12MaxDiff', value);
        end

        function value = get.MinDisparity(this)
            value = StereoBM_(this.id, 'get', 'MinDisparity');
        end
        function set.MinDisparity(this, value)
            StereoBM_(this.id, 'set', 'MinDisparity', value);
        end

        function value = get.NumDisparities(this)
            value = StereoBM_(this.id, 'get', 'NumDisparities');
        end
        function set.NumDisparities(this, value)
            StereoBM_(this.id, 'set', 'NumDisparities', value);
        end

        function value = get.SpeckleRange(this)
            value = StereoBM_(this.id, 'get', 'SpeckleRange');
        end
        function set.SpeckleRange(this, value)
            StereoBM_(this.id, 'set', 'SpeckleRange', value);
        end

        function value = get.SpeckleWindowSize(this)
            value = StereoBM_(this.id, 'get', 'SpeckleWindowSize');
        end
        function set.SpeckleWindowSize(this, value)
            StereoBM_(this.id, 'set', 'SpeckleWindowSize', value);
        end
    end
end
