classdef BackgroundSubtractorMOG < handle
    %BACKGROUNDSUBTRACTORMOG  Gaussian Mixture-based Backbround/Foreground Segmentation Algorithm
    %
    % The class implements the algorithm described in:
    %
    % P. KadewTraKuPong and R. Bowden,
    % An improved adaptive background mixture model for real-time tracking with
    % shadow detection, Proc. 2nd European Workshp on Advanced Video-Based
    % Surveillance Systems, 2001.
    %
    % http://personal.ee.surrey.ac.uk/Personal/R.Bowden/publications/avbs01/avbs01.pdf
    %
    % See also cv.BackgroundSubtractorMOG.BackgroundSubtractorMOG
    % cv.BackgroundSubtractorMOG.apply
    % cv.BackgroundSubtractorMOG.getBackgroundImage
    %
    
    properties (SetAccess = private)
        id % Object id
    end
    
    properties (Dependent)
    	frameSize       %
    	nframes         %
    	history         %
    	nmixtures       %
    	varThreshold    %
    	backgroundRatio %
    	noiseSigma      %
    end
    
    methods
        function this = BackgroundSubtractorMOG(varargin)
            %BACKGROUNDSUBTRACTORMOG  BackgroundSubtractorMOG constructor
            %
            %    bs = cv.BackgroundSubtractorMOG()
            %    bs = cv.BackgroundSubtractorMOG(history, nmixtures, backgroundRatio, 'OptionName', optionValue, ...)
            %
            % Input:
            %    history: Length of the history.
            %    nmixtures: Number of Gaussian mixtures.
            %    backgroundRatio: Background ratio.
            % Options:
            %    'NoiseSigma': Noise strength.
            %
            % Default constructor sets all parameters to default values.
            %
            % See also cv.BackgroundSubtractorMOG
            %
            this.id = BackgroundSubtractorMOG_(0, 'new', varargin{:});
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BackgroundSubtractorMOG
            %
            BackgroundSubtractorMOG_(this.id, 'delete');
        end
        
        function fgmask = apply(this, im, varargin)
            %APPLY  Computes a foreground mask
            %
            %    fgmask = bs.apply(im, 'OptionName', optionValue, ...)
            %
            % Input:
            %     im: Next video frame.
            % Output:
            %     results: The output foreground mask as an 8-bit binary image.
            % Options:
            %     'LearningRate': default 0.
            %
            % See also cv.BackgroundSubtractorMOG
            %
            fgmask = BackgroundSubtractorMOG_(this.id, 'apply', im, varargin{:});
        end
        
        function im = getBackgroundImage(this)
            %GETBACKGROUNDIMAGE  Computes a foreground mask
            %
            %    im = bs.getBackgroundImage()
            %
            % Output:
            %     im: The output background image.
            %
            % See also cv.BackgroundSubtractorMOG
            %
            im = BackgroundSubtractorMOG_(this.id, 'getBackgroundImage');
        end
        
        function value = get.frameSize(this)
        	value = BackgroundSubtractorMOG_(this.id, 'frameSize');
        end
        
        function set.frameSize(this, value)
        	BackgroundSubtractorMOG_(this.id, 'frameSize', value);
        end
        
        function value = get.nframes(this)
        	value = BackgroundSubtractorMOG_(this.id, 'nframes');
        end
        
        function set.nframes(this, value)
        	BackgroundSubtractorMOG_(this.id, 'nframes', value);
        end
        
        function value = get.history(this)
        	value = BackgroundSubtractorMOG_(this.id, 'history');
        end
        
        function set.history(this, value)
        	BackgroundSubtractorMOG_(this.id, 'history', value);
        end
        
        function value = get.nmixtures(this)
        	value = BackgroundSubtractorMOG_(this.id, 'nmixtures');
        end
        
        function set.nmixtures(this, value)
        	BackgroundSubtractorMOG_(this.id, 'nmixtures', value);
        end
        
        function value = get.varThreshold(this)
        	value = BackgroundSubtractorMOG_(this.id, 'varThreshold');
        end
        
        function set.varThreshold(this, value)
        	BackgroundSubtractorMOG_(this.id, 'varThreshold', value);
        end
        
        function value = get.backgroundRatio(this)
        	value = BackgroundSubtractorMOG_(this.id, 'backgroundRatio');
        end
        
        function set.backgroundRatio(this, value)
        	BackgroundSubtractorMOG_(this.id, 'backgroundRatio', value);
        end
        
        function value = get.noiseSigma(this)
        	value = BackgroundSubtractorMOG_(this.id, 'noiseSigma');
        end
        
        function set.noiseSigma(this, value)
        	BackgroundSubtractorMOG_(this.id, 'noiseSigma', value);
        end
    end
    
end
