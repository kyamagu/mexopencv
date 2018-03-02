classdef AdaptiveManifoldFilter < handle
    %ADAPTIVEMANIFOLDFILTER  Interface for Adaptive Manifold Filter realizations
    %
    % For more details about this filter see [Gastal12] and References.
    %
    % Below listed optional parameters which may be set up:
    %
    % * `SigmaS = 16.0` Spatial standard deviation.
    % * `SigmaR = 0.2` Color space standard deviation.
    % * `TreeHeight = -1` Height of the manifold tree
    %   (default = -1 : automatically computed).
    % * `PCAIterations = 1` Number of iterations to compute the eigenvector.
    % * `AdjustOutliers = false` Specify adjust outliers using Eq. 9 or not.
    % * `UseRNG = true` Specify use random number generator to compute
    %   eigenvector or not.
    %
    % ## References
    % [Gastal12]:
    % > Eduardo SL Gastal and Manuel M Oliveira. "Adaptive manifolds for
    % > real-time high-dimensional filtering". ACM Transactions on Graphics
    % > (TOG), 31(4):33, 2012.
    %
    % See also: cv.AdaptiveManifoldFilter.AdaptiveManifoldFilter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Spatial standard deviation.
        SigmaS
        % Color space standard deviation.
        SigmaR
        % Height of the manifold tree.
        TreeHeight
        % Number of iterations to compute the eigenvector.
        PCAIterations
        % Specify adjust outliers using Eq. 9 or not.
        AdjustOutliers
        % Specify use random number generator to compute eigenvector or not.
        UseRNG
    end

    methods
        function this = AdaptiveManifoldFilter(varargin)
            %ADAPTIVEMANIFOLDFILTER  Factory method, create instance of AdaptiveManifoldFilter and produce some initialization routines
            %
            %     obj = cv.AdaptiveManifoldFilter()
            %     obj = cv.AdaptiveManifoldFilter('OptionName',optionValue, ...)
            %
            % ## Options
            % * __SigmaS__ spatial standard deviation. default 16.0
            % * __SigmaR__ color space standard deviation, it is similar to
            %   the sigma in the color space into cv.bilateralFilter.
            %   default 0.2
            % * __AdjustOutliers__ optional, specify perform outliers adjust
            %   operation or not, (Eq. 9) in the original paper. default false
            %
            % For more details about Adaptive Manifold Filter parameters, see
            % the original article [Gastal12].
            %
            % ### Note
            % Joint images with `uint8` and `uint16` depth converted to images
            % with `single` depth and [0; 1] color range before processing.
            % Hence color space `SigmaR` must be in [0; 1] range, unlike same
            % sigmas in cv.bilateralFilter and cv.DTFilter.dtFilter functions.
            %
            % See also: cv.AdaptiveManifoldFilter.filter
            %
            this.id = AdaptiveManifoldFilter_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.AdaptiveManifoldFilter
            %
            if isempty(this.id), return; end
            AdaptiveManifoldFilter_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.AdaptiveManifoldFilter.empty,
            %  cv.AdaptiveManifoldFilter.load
            %
            AdaptiveManifoldFilter_(this.id, 'clear');
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
            % See also: cv.AdaptiveManifoldFilter.clear,
            %  cv.AdaptiveManifoldFilter.load
            %
            b = AdaptiveManifoldFilter_(this.id, 'empty');
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
            % See also: cv.AdaptiveManifoldFilter.load
            %
            AdaptiveManifoldFilter_(this.id, 'save', filename);
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
            % See also: cv.AdaptiveManifoldFilter.save
            %
            AdaptiveManifoldFilter_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.AdaptiveManifoldFilter.save,
            %  cv.AdaptiveManifoldFilter.load
            %
            name = AdaptiveManifoldFilter_(this.id, 'getDefaultName');
        end
    end

    %% AdaptiveManifoldFilter
    methods
        function collectGarbage(this)
            %COLLECTGARBAGE  Collect garbage
            %
            %     obj.collectGarbage()
            %
            % See also: cv.AdaptiveManifoldFilter
            %
            AdaptiveManifoldFilter_(this.id, 'collectGarbage');
        end

        function dst = filter(this, src, varargin)
            %FILTER  Apply high-dimensional filtering using adaptive manifolds
            %
            %     dst = obj.filter(src)
            %     dst = obj.filter(src, joint)
            %
            % ## Input
            % * __src__ filtering image with any numbers of channels.
            % * __joint__ optional joint (also called as guided) image with
            %   any numbers of channels.
            %
            % ## Output
            % * __dst__ output image.
            %
            % See also: cv.AdaptiveManifoldFilter.amFilter
            %
            dst = AdaptiveManifoldFilter_(this.id, 'filter', src, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.SigmaS(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'SigmaS');
        end
        function set.SigmaS(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'SigmaS', value);
        end

        function value = get.SigmaR(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'SigmaR');
        end
        function set.SigmaR(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'SigmaR', value);
        end

        function value = get.TreeHeight(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'TreeHeight');
        end
        function set.TreeHeight(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'TreeHeight', value);
        end

        function value = get.PCAIterations(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'PCAIterations');
        end
        function set.PCAIterations(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'PCAIterations', value);
        end

        function value = get.AdjustOutliers(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'AdjustOutliers');
        end
        function set.AdjustOutliers(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'AdjustOutliers', value);
        end

        function value = get.UseRNG(this)
            value = AdaptiveManifoldFilter_(this.id, 'get', 'UseRNG');
        end
        function set.UseRNG(this, value)
            AdaptiveManifoldFilter_(this.id, 'set', 'UseRNG', value);
        end
    end

    methods (Static)
        function dst = amFilter(src, joint, varargin)
            %AMFILTER  Simple one-line Adaptive Manifold Filter call
            %
            %     dst = cv.AdaptiveManifoldFilter.amFilter(src, joint)
            %     dst = cv.AdaptiveManifoldFilter.amFilter(src, joint, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ filtering image with any numbers of channels.
            % * __joint__ joint (also called as guided) image or array of
            %   images with any numbers of channels.
            %
            % ## Output
            % * __dst__ output image.
            %
            % ## Options
            % * __SigmaS__ spatial standard deviation. default 16.0
            % * __SigmaR__ color space standard deviation, it is similar to
            %   the sigma in the color space into cv.bilateralFilter.
            %   default 0.2
            % * __AdjustOutliers__ optional, specify perform outliers adjust
            %   operation or not, (Eq. 9) in the original paper. default false
            %
            % ### Note
            % Joint images with `uint8` and `uint16` depth converted to images
            % with `single` depth and [0; 1] color range before processing.
            % Hence color space `SigmaR` must be in [0; 1] range, unlike same
            % sigmas in cv.bilateralFilter and cv.DTFilter.dtFilter functions.
            %
            % See also: cv.AdaptiveManifoldFilter.filter, cv.bilateralFilter,
            %  cv.DTFilter.dtFilter, cv.GuidedFilter.guidedFilter
            %
            dst = AdaptiveManifoldFilter_(0, 'amFilter', src, joint, varargin{:});
        end
    end

end
