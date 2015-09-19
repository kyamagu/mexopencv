classdef StereoSGBM < handle
    %STEREOSGBM  Class for computing stereo correspondence using the semi-global block matching algorithm
    %
    % The class implements the modified H. Hirschmuller algorithm [HH08] that
    % differs from the original one as follows:
    %
    % * By default, the algorithm is single-pass, which means that you
    %   consider only 5 directions instead of 8. Set `Mode='HH'` in the
    %   contructor to run the full variant of the algorithm but beware that it
    %   may consume a lot of memory.
    %
    % * The algorithm matches blocks, not individual pixels. Though, setting
    %   `BlockSize=1` reduces the blocks to single pixels.
    %
    % * Mutual information cost function is not implemented. Instead, a
    %   simpler Birchfield-Tomasi sub-pixel metric from [BT96] is used.
    %   Though, the color images are supported as well.
    %
    % * Some pre- and post- processing steps from K. Konolige algorithm
    %   cv.StereoBM are included, for example: pre-filtering (`XSobel` type)
    %   and post-filtering (uniqueness check, quadratic interpolation and
    %   speckle filtering).
    %
    % ## Usage
    %
    %    bm = cv.StereoSGBM('MinDisparity',0, ...);
    %    bm.BlockSize = ...;
    %    disparity = bm.compute(left, right);
    %
    % ## References
    % [HH08]:
    % > Heiko Hirschmuller. "Stereo processing by semiglobal matching and
    % > mutual information". Pattern Analysis and Machine Intelligence, IEEE
    % > Transactions on, 30(2):328-341, 2008.
    %
    % [BT96]:
    % > Stan Birchfield and Carlo Tomasi. "A pixel dissimilarity measure that
    % > is insensitive to image sampling". Pattern Analysis and Machine
    % > Intelligence, IEEE Transactions on, 20(4):401-406, 1998.
    %
    % See also: cv.StereoSGBM.StereoSGBM, cv.StereoSGBM.compute, cv.StereoBM,
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
        % Matched block size, default 7
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
        % cv.validateDisparity, default 0
        Disp12MaxDiff

        % Truncation value for prefiltering image pixels, default 0
        PreFilterCap
        % uniqueness ratio, default 0
        UniquenessRatio
        % first parameter controlling the disparity smoothness, default 0
        P1
        % second parameter controlling the disparity smoothness, default 0
        P2
        % one of 'SGBM' (default) or 'HH' (runs the full-scale two-pass
        % dynamic programming algorithm).
        Mode
    end

    methods
        function this = StereoSGBM(varargin)
            %STEREOSGBM  Creates StereoSGBM object
            %
            %    bm = cv.StereoSGBM()
            %    bm = cv.StereoSGBM('OptionName', optionValue, ...)
            %
            % ## Options
            % * __MinDisparity__ Minimum possible disparity value. Normally,
            %       it is zero but sometimes rectification algorithms can
            %       shift images, so this parameter needs to be adjusted
            %       accordingly. default 0
            % * __NumDisparities__ Maximum disparity minus minimum disparity.
            %       The value is always greater than zero. In the current
            %       implementation, this parameter must be divisible by 16.
            %       default 64
            % * __BlockSize__ Matched block size. It must be an odd number
            %       >=1. Normally, it should be somewhere in the 3..11 range.
            %       default 7
            % * __P1__ The first parameter controlling the disparity
            %       smoothness. See `P2`. default 0 (which uses 2).
            % * __P2__ The second parameter controlling the disparity
            %       smoothness. The larger the values are, the smoother the
            %       disparity is. `P1` is the penalty on the disparity change
            %       by plus or minus 1 between neighbor pixels. `P2` is the
            %       penalty on the disparity change by more than 1 between
            %       neighbor pixels. The algorithm requires `P2 > P1`.
            %       (Reasonably good `P1` and `P2` values are like
            %       `8*number_of_image_channels*BlockSize*BlockSize` and
            %       `32*number_of_image_channels*BlockSize*BlockSize`
            %       respectively). default 0 (which uses `max(5,P1+1)`).
            % * __Disp12MaxDiff__ Maximum allowed difference (in integer pixel
            %       units) in the left-right disparity check. Set it to a
            %       non-positive value to disable the check. default 0
            % * __PreFilterCap__ Truncation value for the prefiltered image
            %       pixels. The algorithm first computes x-derivative at each
            %       pixel and clips its value by `[-PreFilterCap,PreFilterCap]`
            %       interval. The result values are passed to the
            %       Birchfield-Tomasi pixel cost function. default 0
            % * __UniquenessRatio__ Margin in percentage by which the best
            %       (minimum) computed cost function value should "win" the
            %       second best value to consider the found match correct.
            %       Normally, a value within the 5-15 range is good enough.
            %       A negative value uses 10. default 0
            % * __SpeckleWindowSize__ Maximum size of smooth disparity regions
            %       to consider their noise speckles and invalidate. Set it to
            %       0 to disable speckle filtering. Otherwise, set it
            %       somewhere in the 50-200 range. default 0
            % * __SpeckleRange__ Maximum disparity variation within each
            %       connected component. If you do speckle filtering, set the
            %       parameter to a positive value, it will be implicitly
            %       multiplied by 16. Normally, 1 or 2 is good enough.
            %       default 0
            % * __Mode__ Set it to 'HH' to run the full-scale two-pass dynamic
            %       programming algorithm. It will consume
            %       `O(W * H * NumDisparities)` bytes, which is large for
            %       640x480 stereo and huge for HD-size pictures. By default,
            %       it is set to 'SGBM'.
            %
            % See also: cv.StereoSGBM.compute
            %
            this.id = StereoSGBM_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.StereoSGBM
            %
            StereoSGBM_(this.id, 'delete');
        end

        function disparity = compute(this, left, right)
            %COMPUTE  Computes disparity map for the specified stereo pair
            %
            %    disparity = bm.compute(left, right)
            %
            % ## Input
            % * __left__ Left 8-bit single-channel or 3-channel image.
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
            % The method executes the SGBM algorithm on a rectified stereo
            % pair.
            %
            % See also: cv.StereoSGBM.StereoSGBM
            %
            disparity = StereoSGBM_(this.id, 'compute', left, right);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.StereoSGBM.empty
            %
            StereoSGBM_(this.id, 'clear');
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
            % See also: cv.StereoSGBM.clear
            %
            b = StereoSGBM_(this.id, 'empty');
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
            % See also: cv.StereoSGBM.save, cv.StereoSGBM.load
            %
            name = StereoSGBM_(this.id, 'getDefaultName');
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
            % See also: cv.StereoSGBM.load
            %
            StereoSGBM_(this.id, 'save', filename);
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
            % See also: cv.StereoSGBM.save
            %
            StereoSGBM_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Mode(this)
            value = StereoSGBM_(this.id, 'get', 'Mode');
        end
        function set.Mode(this, value)
            StereoSGBM_(this.id, 'set', 'Mode', value);
        end

        function value = get.P1(this)
            value = StereoSGBM_(this.id, 'get', 'P1');
        end
        function set.P1(this, value)
            StereoSGBM_(this.id, 'set', 'P1', value);
        end

        function value = get.P2(this)
            value = StereoSGBM_(this.id, 'get', 'P2');
        end
        function set.P2(this, value)
            StereoSGBM_(this.id, 'set', 'P2', value);
        end

        function value = get.PreFilterCap(this)
            value = StereoSGBM_(this.id, 'get', 'PreFilterCap');
        end
        function set.PreFilterCap(this, value)
            StereoSGBM_(this.id, 'set', 'PreFilterCap', value);
        end

        function value = get.UniquenessRatio(this)
            value = StereoSGBM_(this.id, 'get', 'UniquenessRatio');
        end
        function set.UniquenessRatio(this, value)
            StereoSGBM_(this.id, 'set', 'UniquenessRatio', value);
        end

        function value = get.BlockSize(this)
            value = StereoSGBM_(this.id, 'get', 'BlockSize');
        end
        function set.BlockSize(this, value)
            StereoSGBM_(this.id, 'set', 'BlockSize', value);
        end

        function value = get.Disp12MaxDiff(this)
            value = StereoSGBM_(this.id, 'get', 'Disp12MaxDiff');
        end
        function set.Disp12MaxDiff(this, value)
            StereoSGBM_(this.id, 'set', 'Disp12MaxDiff', value);
        end

        function value = get.MinDisparity(this)
            value = StereoSGBM_(this.id, 'get', 'MinDisparity');
        end
        function set.MinDisparity(this, value)
            StereoSGBM_(this.id, 'set', 'MinDisparity', value);
        end

        function value = get.NumDisparities(this)
            value = StereoSGBM_(this.id, 'get', 'NumDisparities');
        end
        function set.NumDisparities(this, value)
            StereoSGBM_(this.id, 'set', 'NumDisparities', value);
        end

        function value = get.SpeckleRange(this)
            value = StereoSGBM_(this.id, 'get', 'SpeckleRange');
        end
        function set.SpeckleRange(this, value)
            StereoSGBM_(this.id, 'set', 'SpeckleRange', value);
        end

        function value = get.SpeckleWindowSize(this)
            value = StereoSGBM_(this.id, 'get', 'SpeckleWindowSize');
        end
        function set.SpeckleWindowSize(this, value)
            StereoSGBM_(this.id, 'set', 'SpeckleWindowSize', value);
        end
    end
end
