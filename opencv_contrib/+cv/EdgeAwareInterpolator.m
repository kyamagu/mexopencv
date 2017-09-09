classdef EdgeAwareInterpolator < handle
    %EDGEAWAREINTERPOLATOR  Sparse match interpolation algorithm
    %
    % Sparse match interpolation algorithm based on modified locally-weighted
    % affine estimator from [Revaud2015] and Fast Global Smoother as
    % post-processing filter.
    %
    % The filter interface takes sparse matches as an input and produces a
    % dense per-pixel matching (optical flow) as an output.
    %
    % ## References
    % [Revaud2015]:
    % > Jerome Revaud, Philippe Weinzaepfel, Zaid Harchaoui, and Cordelia
    % > Schmid. "Epicflow: Edge-preserving interpolation of correspondences
    % > for optical flow". In IEEE Conference on Computer Vision and Pattern
    % > Recognition (CVPR), pages 1164-1172, 2015.
    %
    % See also: cv.EdgeAwareInterpolator.EdgeAwareInterpolator
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % K is a number of nearest-neighbor matches considered, when fitting a
        % locally affine model.
        %
        % Usually it should be around 128. However, lower values would make
        % the interpolation noticeably faster.
        K
        % Sigma is a parameter defining how fast the weights decrease in the
        % locally-weighted affine fitting.
        %
        % Higher values can help preserve fine details, lower values can help
        % to get rid of noise in the output flow.
        Sigma
        % Lambda is a parameter defining the weight of the edge-aware term in
        % geodesic distance.
        %
        % Should be in the range of 0 to 1000.
        Lambda
        % Sets whether the cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter
        % post-processing is employed.
        %
        % It is turned on by default.
        UsePostProcessing
        % Sets the respective
        % cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter parameter.
        FGSLambda
        % Sets the respective
        % cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter parameter.
        FGSSigma
    end

    methods
        function this = EdgeAwareInterpolator()
            %EDGEAWAREINTERPOLATOR  Factory method that creates an instance of EdgeAwareInterpolator
            %
            %     obj = cv.EdgeAwareInterpolator()
            %
            % See also: cv.EdgeAwareInterpolator.interpolate
            %
            this.id = EdgeAwareInterpolator_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.EdgeAwareInterpolator
            %
            if isempty(this.id), return; end
            EdgeAwareInterpolator_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.EdgeAwareInterpolator.empty,
            %  cv.EdgeAwareInterpolator.load
            %
            EdgeAwareInterpolator_(this.id, 'clear');
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
            % See also: cv.EdgeAwareInterpolator.clear,
            %  cv.EdgeAwareInterpolator.load
            %
            b = EdgeAwareInterpolator_(this.id, 'empty');
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
            % See also: cv.EdgeAwareInterpolator.load
            %
            EdgeAwareInterpolator_(this.id, 'save', filename);
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
            % See also: cv.EdgeAwareInterpolator.save
            %
            EdgeAwareInterpolator_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.EdgeAwareInterpolator.save,
            %  cv.EdgeAwareInterpolator.load
            %
            name = EdgeAwareInterpolator_(this.id, 'getDefaultName');
        end
    end

    %% SparseMatchInterpolator
    methods
        function dense_flow = interpolate(this, from_image, from_points, to_image, to_points)
            %INTERPOLATE  Interpolate input sparse matches
            %
            %     dense_flow = obj.interpolate(from_image, from_points, to_image, to_points)
            %
            % ## Input
            % * **from_image** first of the two matched images, 8-bit
            %   single-channel or three-channel.
            % * **from_points** points of the `from_image` for which there are
            %   correspondences in the `to_image` (a cell array of 2-element
            %   float vectors `{[x,y],..}`, size shouldn't exceed 32767).
            % * **to_image** second of the two matched images, 8-bit
            %   single-channel or three-channel.
            % * **to_points** points in the `to_image` corresponding to
            %   `from_points` (a cell array of 2-element float vectors
            %   `{[x,y],..}`, size shouldn't exceed 32767).
            %
            % ## Output
            % * **dense_flow** output dense matching (two-channel `single`
            %   image).
            %
            % See also: cv.EdgeAwareInterpolator.EdgeAwareInterpolator
            %
            dense_flow = EdgeAwareInterpolator_(this.id, 'interpolate', ...
                from_image, from_points, to_image, to_points);
        end
    end

    %% Getters/Setters
    methods
        function value = get.K(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'K');
        end
        function set.K(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'K', value);
        end

        function value = get.Sigma(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'Sigma');
        end
        function set.Sigma(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'Sigma', value);
        end

        function value = get.Lambda(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'Lambda');
        end
        function set.Lambda(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'Lambda', value);
        end

        function value = get.UsePostProcessing(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'UsePostProcessing');
        end
        function set.UsePostProcessing(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'UsePostProcessing', value);
        end

        function value = get.FGSLambda(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'FGSLambda');
        end
        function set.FGSLambda(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'FGSLambda', value);
        end

        function value = get.FGSSigma(this)
            value = EdgeAwareInterpolator_(this.id, 'get', 'FGSSigma');
        end
        function set.FGSSigma(this, value)
            EdgeAwareInterpolator_(this.id, 'set', 'FGSSigma', value);
        end
    end

end
