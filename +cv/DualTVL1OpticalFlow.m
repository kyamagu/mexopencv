classdef DualTVL1OpticalFlow < handle
    %DUALTVL1OPTICALFLOW  "Dual TV L1" Optical Flow Algorithm
    %
    % The class implements the "Dual TV L1" optical flow algorithm described
    % in [Zach2007] and [Javier2012]. Here are important members of the class
    % that control the algorithm, which you can set after constructing the
    % class instance:
    %
    % * member double `Tau` Time step of the numerical scheme.
    % * member double `Lambda` Weight parameter for the data term, attachment
    %   parameter. This is the most relevant parameter, which determines the
    %   smoothness of the output. The smaller this parameter is, the smoother
    %   the solutions we obtain. It depends on the range of motions of the
    %   images, so its value should be adapted to each image sequence.
    % * member double `Theta` Weight parameter for `(u - v)^2`, tightness
    %   parameter. It serves as a link between the attachment and the
    %   regularization terms. In theory, it should have a small value in order
    %   to maintain both parts in correspondence. The method is stable for a
    %   large range of values of this parameter.
    % * member int `ScalesNumber` Number of scales used to create the pyramid
    %   of images.
    % * member int `WarpingsNumber` Number of warpings per scale. Represents
    %   the number of times that `I1(x+u0)` and `grad(I1(x+u0))` are computed
    %   per scale. This is a parameter that assures the stability of the
    %   method. It also affects the running time, so it is a compromise
    %   between speed and accuracy.
    % * member double `Epsilon` Stopping criterion threshold used in the
    %   numerical scheme, which is a trade-off between precision and running
    %   time. A small value will yield more accurate solutions at the expense
    %   of a slower convergence.
    % * member int `OuterIterations` Stopping criterion iterations number used
    %   in the numerical scheme.
    %
    % ## References
    % [Zach2007]:
    % > Christopher Zach, Thomas Pock, and Horst Bischof.
    % > "A Duality Based Approach for Realtime TV-L1 Optical Flow".
    % > In Pattern Recognition, pages 214-223. Springer, 2007.
    %
    % [Javier2012]:
    % > Javier Sanchez Perez, Enric Meinhardt-Llopis, and Gabriele Facciolo.
    % > "TV-L1 Optical Flow Estimation". 2012.
    %
    % See also: cv.DualTVL1OpticalFlow.DualTVL1OpticalFlow,
    %  cv.calcOpticalFlowFarneback
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % Time step of the numerical scheme. default 0.25
        Tau
        % Weight parameter for the data term, attachment parameter.
        % default 0.15
        Lambda
        % Weight parameter for `(u - v)^2`, tightness parameter. default 0.3
        Theta
        % Number of scales used to create the pyramid of images. default 5
        ScalesNumber
        % Number of warpings per scale. default 5
        WarpingsNumber
        % Stopping criterion threshold used in the numerical scheme, which is
        % a trade-off between precision and running time. default 0.01
        Epsilon
        % Coefficient for additional illumination variation term. default 0.0
        Gamma
        % Inner iterations (between outlier filtering) used in the numerical
        % scheme. default 30
        InnerIterations
        % Outer iterations (number of inner loops) used in the numerical
        % scheme. default 10
        OuterIterations
        % Use initial flow. default false
        UseInitialFlow
        % Median filter kernel size (1 = no filter) (3 or 5). default 5
        MedianFiltering
        % Step between scales (`<1`). default 0.8
        ScaleStep
    end

    %% DenseOpticalFlow
    methods
        function this = DualTVL1OpticalFlow()
            %DUALTVL1OPTICALFLOW  Creates instance of DenseOpticalFlow
            %
            %    obj = cv.DualTVL1OpticalFlow()
            %
            % See also: cv.DualTVL1OpticalFlow.calc
            %
            this.id = DualTVL1OpticalFlow_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.DualTVL1OpticalFlow
            %
            DualTVL1OpticalFlow_(this.id, 'delete');
        end

        function flow = calc(this, I0, I1, varargin)
            %CALL  Calculates an optical flow
            %
            %    flow = obj.calc(I0, I1)
            %    flow = obj.calc(I0, I1, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __I0__ first 8-bit single-channel input image.
            % * __I1__ second input image of the same size and the same type
            %       as `I0`.
            %
            % ## Output
            % * __flow__ computed flow image that has the same size as `I0`
            %       and type `single` (2-channels).
            %
            % ## Options
            % * __InitialFlow__ specify the initial flow. Not set by default.
            %
            % See also: cv.DualTVL1OpticalFlow
            %
            flow = DualTVL1OpticalFlow_(this.id, 'calc', I0, I1, varargin{:});
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Releases all inner buffers
            %
            %    obj.collectGarbage()
            %
            DualTVL1OpticalFlow_(this.id, 'collectGarbage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.DualTVL1OpticalFlow.empty
            %
            DualTVL1OpticalFlow_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty.
            %
            %    obj.empty()
            %
            % (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.DualTVL1OpticalFlow.clear
            %
            b = DualTVL1OpticalFlow_(this.id, 'empty');
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
            % See also: cv.DualTVL1OpticalFlow.save, cv.DualTVL1OpticalFlow.load
            %
            name = DualTVL1OpticalFlow_(this.id, 'getDefaultName');
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
            % See also: cv.DualTVL1OpticalFlow.load
            %
            DualTVL1OpticalFlow_(this.id, 'save', filename);
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
            % See also: cv.DualTVL1OpticalFlow.save
            %
            DualTVL1OpticalFlow_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Epsilon(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'Epsilon');
        end
        function set.Epsilon(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'Epsilon', value);
        end

        function value = get.Gamma(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'Gamma', value);
        end

        function value = get.InnerIterations(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'InnerIterations');
        end
        function set.InnerIterations(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'InnerIterations', value);
        end

        function value = get.Lambda(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'Lambda');
        end
        function set.Lambda(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'Lambda', value);
        end

        function value = get.MedianFiltering(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'MedianFiltering');
        end
        function set.MedianFiltering(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'MedianFiltering', value);
        end

        function value = get.OuterIterations(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'OuterIterations');
        end
        function set.OuterIterations(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'OuterIterations', value);
        end

        function value = get.ScalesNumber(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'ScalesNumber');
        end
        function set.ScalesNumber(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'ScalesNumber', value);
        end

        function value = get.ScaleStep(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'ScaleStep');
        end
        function set.ScaleStep(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'ScaleStep', value);
        end

        function value = get.Tau(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'Tau');
        end
        function set.Tau(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'Tau', value);
        end

        function value = get.Theta(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'Theta');
        end
        function set.Theta(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'Theta', value);
        end

        function value = get.UseInitialFlow(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'UseInitialFlow');
        end
        function set.UseInitialFlow(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'UseInitialFlow', value);
        end

        function value = get.WarpingsNumber(this)
            value = DualTVL1OpticalFlow_(this.id, 'get', 'WarpingsNumber');
        end
        function set.WarpingsNumber(this, value)
            DualTVL1OpticalFlow_(this.id, 'set', 'WarpingsNumber', value);
        end
    end

end
