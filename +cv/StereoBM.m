classdef StereoBM < handle
    %STEREOBM  Class for computing stereo correspondence using the block matching algorithm
    %
    % # Usage
    %
    %    bm = cv.StereoBM('NumDisparities', 0);
    %    disparity = bm.compute(left, right);
    %
    % See also cv.StereoBM.StereoBM cv.StereoBM.compute cv.StereoSGBM
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        PreFilterCap
        PreFilterSize
        PreFilterType
        ROI1
        ROI2
        SmallerBlockSize
        TextureThreshold
        UniquenessRatio
        BlockSize
        Disp12MaxDiff
        MinDisparity
        NumDisparities
        SpeckleRange
        SpeckleWindowSize
    end

    methods
        function this = StereoBM(varargin)
            %STEREOBM  Constructs StereoBM
            %
            %    bm = cv.StereoBM()
            %    bm = cv.StereoBM('OptionName', optionValue, ...)
            %
            % ## Options
            % * __NumDisparities__ the disparity search range. For each pixel
            %        algorithm will find the best disparity from 0 (default
            %        minimum disparity) to `numDisparities`. The search range
            %        can then be shifted by changing the minimum disparity.
            %        default 0.
            % * __BlockSize__ the linear size of the blocks compared by
            %        the algorithm. The size should be odd (as the block is
            %        centered at the current pixel). Larger block size
            %        implies smoother, though less accurate disparity map.
            %        Smaller block size gives more detailed disparity map,
            %        but there is higher chance for algorithm to find a
            %        wrong correspondence. default 21. 
            %
            % The function create cv.StereoBM object. You can then call
            % cv.StereoBM.compute() to compute disparity for a specific
            % stereo pair.
            %
            % See also cv.StereoBM
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
            %COMPUTE  Computes disparity map for the specified stereo pair.
            %
            %    disparity = bm.compute(left, right)
            %
            % ## Input
            % * __left__ Left 8-bit single-channel or 3-channel image.
            % * __right__ Right image of the same size and the same type as
            %        the left one.
            %
            % ## Output
            % * __disparity__ Output disparity map. It has the same size as the
            %        input images. Some algorithms, like cv.StereoBM or cv.StereoSGBM
            %        compute 16-bit fixed-point disparity map (where each
            %        disparity value has 4 fractional bits), whereas other
            %        algorithms output 32-bit floating-point disparity map.
            %
            % The method executes the BM algorithm on a rectified stereo
            % pair. See the stereo_match.cpp OpenCV sample on how to
            % prepare images and call the method. Note that the method is
            % not constant, thus you should not use the same cv.StereoBM
            % instance from within different threads simultaneously.
            %
            % See also cv.StereoBM
            %
            disparity = StereoBM_(this.id, 'compute', left, right);
        end
    end

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
