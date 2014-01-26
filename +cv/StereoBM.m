classdef StereoBM < handle
    %STEREOBM  Class for computing stereo correspondence using the block matching algorithm
    %
    % # Usage
    %
    %    bm = cv.StereoBM('Preset', 'Basic', 'NDisparities', 0);
    %    disparity = bm.compute(left, right);
    %
    % See also cv.StereoBM.StereoBM  cv.StereoBM.init cv.StereoBM.compute
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = StereoBM(varargin)
            %STEREOBM  Constructs StereoBM
            %
            %    bm = cv.StereoBM
            %    bm = cv.StereoBM(...)
            %
            % The constructor optionally takes the argument of init method.
            %
            % See also cv.StereoBM cv.StereoBM.init
            %
            this.id = StereoBM_();
            if nargin>0, this.init(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.StereoBM
            %
            StereoBM_(this.id, 'delete');
        end
        
        function init(this, varargin)
            %INIT  
            %
            %    bm.init('OptionName', optionValue, ...)
            %
            %
            % ## Options
            % * __Preset__ specifies the whole set of algorithm parameters,
            %        one of: 'Basic', 'FishEye', 'Narrow'. After
            %        constructing the class, you can override any
            %        parameters set by the preset.
            % * __NDisparities__ the disparity search range. For each pixel
            %        algorithm will find the best disparity from 0 (default
            %        minimum disparity) to ndisparities. The search range
            %        can then be shifted by changing the minimum disparity.
            %        default 0.
            % * __SADWindowSize__ the linear size of the blocks compared by
            %        the algorithm. The size should be odd (as the block is
            %        centered at the current pixel). Larger block size
            %        implies smoother, though less accurate disparity map.
            %        Smaller block size gives more detailed disparity map,
            %        but there is higher chance for algorithm to find a
            %        wrong correspondence. default 21. 
            %
            % See also cv.StereoBM cv.StereoBM.compute
            %
            StereoBM_(this.id, 'init', varargin{:});
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
            % * __disparity__ Output disparity map. It has the same size as
            %        the input images. When disptype==CV_16S, the map is a
            %        16-bit signed single-channel image, containing
            %        disparity values scaled by 16. To get the true
            %        disparity values from such fixed-point representation,
            %        you will need to divide each disp element by 16.
            %
            % The method executes the BM algorithm on a rectified stereo
            % pair. See the stereo_match.cpp OpenCV sample on how to
            % prepare images and call the method. Note that the method is
            % not constant, thus you should not use the same cv.StereoBM
            % instance from within different threads simultaneously.
            %
            % See also cv.StereoBM cv.StereoBM.init
            %
            disparity = StereoBM_(this.id, 'compute', left, right, varargin{:});
        end
    end
    
end
