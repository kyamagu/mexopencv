classdef MergeRobertson < handle
    %MERGEROBERTSON  Merge exposure sequence to a single image
    %
    % The resulting HDR image is calculated as weighted average of the
    % exposures considering exposure values and camera response.
    %
    % For more information see [RB99].
    %
    % ## References
    % [RB99]:
    % > Mark A Robertson, Sean Borman, and Robert L Stevenson.
    % > "Dynamic range improvement through multiple exposures".
    % > In Image Processing, 1999. ICIP 99. Proceedings. 1999 International
    % > Conference on, volume 3, pages 159-163. IEEE, 1999.
    %
    % See also: cv.MergeDebevec, cv.MergeMertens, makehdr
    %

    properties (SetAccess = private)
        id % Object ID
    end

    %% MergeRobertson
    methods
        function this = MergeRobertson()
            %MERGEROBERTSON  Creates MergeRobertson object
            %
            %    obj = cv.MergeRobertson()
            %
            % See also: cv.MergeRobertson.process
            %
            this.id = MergeRobertson_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.MergeRobertson
            %
            MergeRobertson_(this.id, 'delete');
        end
    end

    %% MergeExposures
    methods
        function dst = process(this, src, times, varargin)
            %PROCESS  Merges images
            %
            %    dst = obj.process(src, times)
            %    dst = obj.process(src, times, response)
            %
            % ## Input
            % * __src__ vector of input images, all of the same size and
            %       `uint8` type.
            % * __times__ vector of exposure time values for each image.
            % * __response__ 256x1xCN `single` matrix with inverse camera
            %       response function (CRF) for each pixel value, it should
            %       have the same number of channels as images `src{i}`.
            %
            % ## Output
            % * __dst__ result image, same size as `src{i}` and `single` type.
            %
            % The function has a short version, that doesn't take the extra
            % `response` argument.
            %
            % See also: cv.MergeRobertson.MergeRobertson
            %
            dst = MergeRobertson_(this.id, 'process', src, times, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.MergeRobertson.empty, cv.MergeRobertson.load
            %
            MergeRobertson_(this.id, 'clear');
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
            % See also: cv.MergeRobertson.clear, cv.MergeRobertson.load
            %
            b = MergeRobertson_(this.id, 'empty');
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
            % See also: cv.MergeRobertson.save, cv.MergeRobertson.load
            %
            name = MergeRobertson_(this.id, 'getDefaultName');
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
            % See also: cv.MergeRobertson.load
            %
            MergeRobertson_(this.id, 'save', filename);
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
            % See also: cv.MergeRobertson.save
            %
            MergeRobertson_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
