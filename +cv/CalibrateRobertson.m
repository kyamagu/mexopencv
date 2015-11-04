classdef CalibrateRobertson < handle
    %CALIBRATEROBERTSON  Camera Response Calibration algorithm
    %
    % Inverse camera response function is extracted for each brightness value
    % by minimizing an objective function as linear system. This algorithm
    % uses all image pixels.
    %
    % For more information see [RB99].
    %
    % ## References
    % [RB99]:
    % > Mark A Robertson, Sean Borman, and Robert L Stevenson.
    % > "Dynamic range improvement through multiple exposures". In Image
    % > Processing, 1999. ICIP 99. Proceedings. 1999 International Conference
    % > on, volume 3, pages 159-163. IEEE, 1999.
    %
    % See also: cv.CalibrateDebevec
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % maximal number of Gauss-Seidel solver iterations.
        MaxIter
        % target difference between results of two successive steps of the
        % minimization.
        Threshold
    end

    %% CalibrateRobertson
    methods
        function this = CalibrateRobertson(varargin)
            %CALIBRATEROBERTSON  Creates CalibrateRobertson object
            %
            %    obj = cv.CalibrateRobertson()
            %    obj = cv.CalibrateRobertson('OptionName',optionValue, ...)
            %
            % ## Options
            % * __MaxIter__ default 30
            % * __Threshold__ default 0.01
            %
            % See also: cv.CalibrateRobertson.process
            %
            this.id = CalibrateRobertson_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.CalibrateRobertson
            %
            CalibrateRobertson_(this.id, 'delete');
        end

        function radiance = getRadiance(this)
            %GETRADIANCE  Get Radiance matrix
            %
            %    radiance = obj.getRadiance()
            %
            % ## Output
            % * __radiance__ radiance matrix, same size as input images and
            %       `single` type.
            %
            radiance = CalibrateRobertson_(this.id, 'getRadiance');
        end
    end

    %% CalibrateCRF
    methods
        function dst = process(this, src, times)
            %PROCESS  Recovers inverse camera response
            %
            %    dst = obj.process(src, times)
            %
            % ## Input
            % * __src__ cell array of input images, all of the same size and
            %       `uint8` type.
            % * __times__ vector of exposure time values for each image.
            %
            % ## Output
            % * __dst__ 256x1xCN `single` matrix with inverse camera response
            %       function. It has the same number of channels as images
            %       `src{i}`.
            %
            % See also: cv.CalibrateRobertson.CalibrateRobertson
            %
            dst = CalibrateRobertson_(this.id, 'process', src, times);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.CalibrateRobertson.empty, cv.CalibrateRobertson.load
            %
            CalibrateRobertson_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.CalibrateRobertson.clear, cv.CalibrateRobertson.load
            %
            b = CalibrateRobertson_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.CalibrateRobertson.save, cv.CalibrateRobertson.load
            %
            name = CalibrateRobertson_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.CalibrateRobertson.load
            %
            CalibrateRobertson_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
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
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.CalibrateRobertson.save
            %
            CalibrateRobertson_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MaxIter(this)
            value = CalibrateRobertson_(this.id, 'get', 'MaxIter');
        end
        function set.MaxIter(this, value)
            CalibrateRobertson_(this.id, 'set', 'MaxIter', value);
        end

        function value = get.Threshold(this)
            value = CalibrateRobertson_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            CalibrateRobertson_(this.id, 'set', 'Threshold', value);
        end
    end

end
