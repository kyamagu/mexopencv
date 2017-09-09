classdef SparsePyrLKOpticalFlow < handle
    %SPARSEPYRLKOPTICALFLOW  Class used for calculating a sparse optical flow
    %
    % The class can calculate an optical flow for a sparse feature set using
    % the iterative Lucas-Kanade method with pyramids.
    %
    % See also: cv.SparsePyrLKOpticalFlow.calc, cv.calcOpticalFlowPyrLK
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % default [21,21]
        WinSize
        % default 3
        MaxLevel
        % default `struct('type','Count+EPS', 'maxCount',30, 'epsilon',0.01)`
        TermCriteria
        % default 0
        Flags
        % default 1e-4
        MinEigThreshold
    end

    %% Constructor/destructor
    methods
        function this = SparsePyrLKOpticalFlow()
            %SPARSEPYRLKOPTICALFLOW  Creates instance of SparsePyrLKOpticalFlow
            %
            %     obj = cv.SparsePyrLKOpticalFlow()
            %
            % See also: cv.SparsePyrLKOpticalFlow.calc
            %
            this.id = SparsePyrLKOpticalFlow_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SparsePyrLKOpticalFlow
            %
            if isempty(this.id), return; end
            SparsePyrLKOpticalFlow_(this.id, 'delete');
        end
    end

    %% SparseOpticalFlow
    methods
        function varargout = calc(this, prevImg, nextImg, prevPts, varargin)
            %CALC  Calculates a sparse optical flow
            %
            %     nextPts = obj.calc(prevImg, nextImg, prevPts)
            %     [nextPts, status, err] = obj.calc(...)
            %     [...] = obj.calc(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __prevImg__ First input image.
            % * __nextImg__ Second input image of the same size and the same
            %   type as `prevImg`.
            % * __prevPts__ Vector of 2D points for which the flow needs to be
            %   found.
            %
            % ## Output
            % * __nextPts__ Output vector of 2D points containing the
            %   calculated new positions of input features in the second image.
            % * __status__ Output status vector. Each element of the vector is
            %   set to 1 if the flow for the corresponding features has been
            %   found. Otherwise, it is set to 0.
            % * __err__ Optional output vector that contains error response
            %   for each point (inverse confidence).
            %
            % ## Options
            % * __InitialFlow__ Vector of 2D points to be used for the initial
            %   estimate of `nextPts`. Not set by default.
            %
            % See also: cv.SparsePyrLKOpticalFlow, cv.calcOpticalFlowPyrLK
            %
            [varargout{1:nargout}] = SparsePyrLKOpticalFlow_(this.id, 'calc', prevImg, nextImg, prevPts, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SparsePyrLKOpticalFlow.empty
            %
            SparsePyrLKOpticalFlow_(this.id, 'clear');
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
            % See also: cv.SparsePyrLKOpticalFlow.clear
            %
            b = SparsePyrLKOpticalFlow_(this.id, 'empty');
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
            % See also: cv.SparsePyrLKOpticalFlow.save, cv.SparsePyrLKOpticalFlow.load
            %
            name = SparsePyrLKOpticalFlow_(this.id, 'getDefaultName');
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
            % See also: cv.SparsePyrLKOpticalFlow.load
            %
            SparsePyrLKOpticalFlow_(this.id, 'save', filename);
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
            % See also: cv.SparsePyrLKOpticalFlow.save
            %
            SparsePyrLKOpticalFlow_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.WinSize(this)
            value = SparsePyrLKOpticalFlow_(this.id, 'get', 'WinSize');
        end
        function set.WinSize(this)
            SparsePyrLKOpticalFlow_(this.id, 'set', 'WinSize', value);
        end

        function value = get.MaxLevel(this)
            value = SparsePyrLKOpticalFlow_(this.id, 'get', 'MaxLevel');
        end
        function set.MaxLevel(this)
            SparsePyrLKOpticalFlow_(this.id, 'set', 'MaxLevel', value);
        end

        function value = get.TermCriteria(this)
            value = SparsePyrLKOpticalFlow_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this)
            SparsePyrLKOpticalFlow_(this.id, 'set', 'TermCriteria', value);
        end

        function value = get.Flags(this)
            value = SparsePyrLKOpticalFlow_(this.id, 'get', 'Flags');
        end
        function set.Flags(this)
            SparsePyrLKOpticalFlow_(this.id, 'set', 'Flags', value);
        end

        function value = get.MinEigThreshold(this)
            value = SparsePyrLKOpticalFlow_(this.id, 'get', 'MinEigThreshold');
        end
        function set.MinEigThreshold(this)
            SparsePyrLKOpticalFlow_(this.id, 'set', 'MinEigThreshold', value);
        end
    end

end
