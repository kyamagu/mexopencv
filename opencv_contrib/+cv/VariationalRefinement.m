classdef VariationalRefinement < handle
    %VARIATIONALREFINEMENT  Variational optical flow refinement
    %
    % This class implements variational refinement of the input flow field,
    % i.e. it uses input flow to initialize the minimization of the following
    % functional:
    %
    %     E(U) = integral_{Omega}(delta * Psi(E_I) + gamma * Psi(E_G) + alpha * Psi(E_S))
    %
    % where `E_I`, `E_G`, `E_S` are color constancy, gradient constancy and
    % smoothness terms respectively. `Psi(s^2) = sqrt(s^2 + epsilon^2)` is a
    % robust penalizer to limit the influence of outliers. A complete
    % formulation and a description of the minimization procedure can be found
    % in [Brox2004].
    %
    % ## References
    % [Brox2004]:
    % > Thomas Brox, Andres Bruhn, Nils Papenberg, and Joachim Weickert.
    % > "High accuracy optical flow estimation based on a theory for warping".
    % > In Computer Vision-ECCV 2004, pages 25-36. Springer, 2004.
    %
    % See also: cv.VariationalRefinement.calc
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Number of outer (fixed-point) iterations in the minimization
        % procedure. default 5
        FixedPointIterations
        % Number of inner successive over-relaxation (SOR) iterations in the
        % minimization procedure to solve the respective linear system.
        % default 5
        SorIterations
        % Relaxation factor in SOR. default 1.6
        Omega
        % Weight of the smoothness term. default 20.0
        Alpha
        % Weight of the color constancy term. default 5.0
        Delta
        % Weight of the gradient constancy term. default 10.0
        Gamma
    end

    %% Constructor/destructor
    methods
        function this = VariationalRefinement()
            %VARIATIONALREFINEMENT  Creates an instance of VariationalRefinement
            %
            %     obj = cv.VariationalRefinement()
            %
            % See also: cv.VariationalRefinement.calc
            %
            this.id = VariationalRefinement_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.VariationalRefinement
            %
            if isempty(this.id), return; end
            VariationalRefinement_(this.id, 'delete');
        end
    end

    %% DenseOpticalFlow
    methods
        function flow = calc(this, I0, I1, varargin)
            %CALC  Calculates an optical flow
            %
            %     flow = obj.calc(I0, I1)
            %     flow = obj.calc(I0, I1, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __I0__ first 8-bit single-channel input image.
            % * __I1__ second input image of the same size and the same type
            %   as `I0`.
            %
            % ## Output
            % * __flow__ computed flow image that has the same size as `I0`
            %   and type `single` (2-channels).
            %
            % ## Options
            % * __InitialFlow__ specify the initial flow. Not set by default.
            %
            % See also: cv.VariationalRefinement
            %
            flow = VariationalRefinement_(this.id, 'calc', I0, I1, varargin{:});
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Releases all inner buffers
            %
            %     obj.collectGarbage()
            %
            VariationalRefinement_(this.id, 'collectGarbage');
        end
    end

    %% VariationalRefinement
    methods
        function [flow_u, flow_v] = calcUV(this, I0, I1, varargin)
            %CALCUV  calc function overload to handle separate horizontal (u) and vertical (v) flow components (to avoid extra splits/merges)
            %
            %     [flow_u, flow_v] = obj.calcUV(I0, I1)
            %     [flow_u, flow_v] = obj.calcUV(I0, I1, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __I0__ first 8-bit single-channel input image.
            % * __I1__ second input image of the same size and the same type
            %   as `I0`.
            %
            % ## Output
            % * **flow_u** computed horizontal flow image that has the same
            %   size as `I0` and type `single` (1-channel1).
            % * **flow_v** computed vertical flow image that has the same size
            %   as `I0` and type `single` (1-channel1).
            %
            % ## Options
            % * __InitialFlowU__ specify initial U-flow. Not set by default.
            % * __InitialFlowV__ specify initial V-flow. Not set by default.
            %
            % Note that `flow(:,:,1)==flow_u`, and `flow(:,:,2)==flow_v`.
            %
            % See also: cv.VariationalRefinement.calc
            %
            [flow_u, flow_v] = VariationalRefinement_(this.id, 'calcUV', I0, I1, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.VariationalRefinement.empty
            %
            VariationalRefinement_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.VariationalRefinement.clear
            %
            b = VariationalRefinement_(this.id, 'empty');
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
            % See also: cv.VariationalRefinement.save, cv.VariationalRefinement.load
            %
            name = VariationalRefinement_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.VariationalRefinement.load
            %
            VariationalRefinement_(this.id, 'save', filename);
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
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.VariationalRefinement.save
            %
            VariationalRefinement_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.FixedPointIterations(this)
            value = VariationalRefinement_(this.id, 'get', 'FixedPointIterations');
        end
        function set.FixedPointIterations(this, value)
            VariationalRefinement_(this.id, 'set', 'FixedPointIterations', value);
        end

        function value = get.SorIterations(this)
            value = VariationalRefinement_(this.id, 'get', 'SorIterations');
        end
        function set.SorIterations(this, value)
            VariationalRefinement_(this.id, 'set', 'SorIterations', value);
        end

        function value = get.Omega(this)
            value = VariationalRefinement_(this.id, 'get', 'Omega');
        end
        function set.Omega(this, value)
            VariationalRefinement_(this.id, 'set', 'Omega', value);
        end

        function value = get.Alpha(this)
            value = VariationalRefinement_(this.id, 'get', 'Alpha');
        end
        function set.Alpha(this, value)
            VariationalRefinement_(this.id, 'set', 'Alpha', value);
        end

        function value = get.Delta(this)
            value = VariationalRefinement_(this.id, 'get', 'Delta');
        end
        function set.Delta(this, value)
            VariationalRefinement_(this.id, 'set', 'Delta', value);
        end

        function value = get.Gamma(this)
            value = VariationalRefinement_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            VariationalRefinement_(this.id, 'set', 'Gamma', value);
        end
    end

end
