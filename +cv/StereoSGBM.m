classdef StereoSGBM < handle
    %STEREOSGBM  Class for computing stereo correspondence using the semi-global block matching algorithm
    %
    % # Usage
    %
    %    bm = cv.StereoSGBM('MinDisparity',0,...);
    %    disparity = bm.compute(left, right);
    %
    % The class implements the modified H. Hirschmuller algorithm HH08 that
    % differs from the original one as follows:
    %
    % By default, the algorithm is single-pass, which means that you
    % consider only 5 directions instead of 8. Set fullDP=true to run the
    % full variant of the algorithm but beware that it may consume a lot
    % of memory.
    % 
    % The algorithm matches blocks, not individual pixels. Though, setting
    % SADWindowSize=1 reduces the blocks to single pixels.
    %
    % Mutual information cost function is not implemented. Instead, a
    % simpler Birchfield-Tomasi sub-pixel metric from BT96 is used. Though,
    % the color images are supported as well.
    % 
    % Some pre- and post- processing steps from K. Konolige algorithm
    % are included, for example: pre-filtering
    % (CV\_STEREO\_BM\_XSOBEL type) and post-filtering (uniqueness check,
    % quadratic interpolation and speckle filtering).
    %
    % See also cv.StereoSGBM.StereoSGBM  cv.StereoSGBM.init cv.StereoSGBM.compute
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = StereoSGBM(varargin)
            %STEREOSGBM  Constructs StereoSGBM
            %
            %    bm = cv.StereoSGBM
            %    bm = cv.StereoSGBM('OptionName', optionValue, ...)
            %
            %
            % ## Options
            % * __MinDisparity__ Minimum possible disparity value.
            %        Normally, it is zero but sometimes rectification
            %        algorithms can shift images, so this parameter needs
            %        to be adjusted accordingly. default 0
            % * __NumDisparities__ Maximum disparity minus minimum
            %        disparity. The value is always greater than zero. In
            %        the current implementation, this parameter must be
            %        divisible by 16. default 64
            % * __SADWindowSize__ Matched block size. It must be an odd
            %        number >=1 . Normally, it should be somewhere in the
            %        3..11 range. default 7
            % * __P1__ The first parameter controlling the disparity
            %        smoothness. See P2. default 0.
            % * __P2__ The second parameter controlling the disparity
            %        smoothness. The larger the values are, the smoother
            %        the disparity is. P1 is the penalty on the disparity
            %        change by plus or minus 1 between neighbor pixels. P2
            %        is the penalty on the disparity change by more than 1
            %        between neighbor pixels. The algorithm requires P2 >
            %        P1. default 0.
            % * __Disp12MaxDiff__ Maximum allowed difference (in integer
            %        pixel units) in the left-right disparity check. Set
            %        it to a non-positive value to disable the check.
            %        default 0
            % * __PreFilterCap__ Truncation value for the prefiltered image
            %        pixels. The algorithm first computes x-derivative at
            %        each pixel and clips its value by [-preFilterCap,
            %        preFilterCap] interval. The result values are passed
            %        to the Birchfield-Tomasi pixel cost function. default
            %        0
            % * __UniquenessRatio__ Margin in percentage by which the best
            %        (minimum) computed cost function value should "win"
            %        the second best value to consider the found match
            %        correct. Normally, a value within the 5-15 range is
            %        good enough. default 0
            % * __SpeckleWindowSize__ Maximum size of smooth disparity
            %        regions to consider their noise speckles and
            %        invalidate. Set it to 0 to disable speckle filtering.
            %        Otherwise, set it somewhere in the 50-200 range.
            %        default 0
            % * __SpeckleRange__ Maximum disparity variation within each
            %        connected component. If you do speckle filtering, set
            %        the parameter to a positive value, multiple of 16.
            %        Normally, 16 or 32 is good enough. default 0
            % * __FullDP__ Set it to true to run the full-scale two-pass
            %        dynamic programming algorithm. It will consume
            %        O(W * H * numDisparities) bytes, which is large for
            %        640x480 stereo and huge for HD-size pictures. By
            %        default, it is set to false.
            %
            % See also cv.StereoSGBM
            %
            this.id = StereoSGBM_(varargin{:});
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.StereoSGBM
            %
            StereoSGBM_(this.id, 'delete');
        end
        
        function disparity = compute(this, left, right, varargin)
            %COMPUTE  
            %
            %    disparity = bm.compute(left, right)
            %
            % ## Input
            % * __left__ Left 8-bit single-channel or 3-channel image.
            % * __right__ Right image of the same size and the same type as
            %        the left one.
            %
            % ## Output
            % * __disparity__ Output disparity map. It is a 16-bit signed
            %        single-channel image of the same size as the input
            %        image. It contains disparity values scaled by 16. So,
            %        to get the floating-point disparity map, you need to
            %        divide each disp element by 16.
            %
            % The method executes the SGBM algorithm on a rectified stereo
            % pair. See stereo_match.cpp OpenCV sample on how to prepare
            % images and call the method.
            %
            % See also cv.StereoSGBM
            %
            disparity = StereoSGBM_(this.id, 'compute', left, right, varargin{:});
        end
    end
    
end
