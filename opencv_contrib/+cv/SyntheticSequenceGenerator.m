classdef SyntheticSequenceGenerator < handle
    %SYNTHETICSEQUENCEGENERATOR  Synthetic frame sequence generator for testing background subtraction algorithms
    %
    % It will generate the moving object on top of the background.
    % It will apply some distortion to the background to make the test more
    % complex.
    %
    % See also: cv.BackgroundSubtractorLSBP, cv.BackgroundSubtractorGSOC
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% SyntheticSequenceGenerator
    methods
        function this = SyntheticSequenceGenerator(background, object, varargin)
            %SYNTHETICSEQUENCEGENERATOR  Creates an instance of SyntheticSequenceGenerator
            %
            %     obj = cv.SyntheticSequenceGenerator(background, object)
            %     obj = cv.SyntheticSequenceGenerator(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __background__ Background image for object.
            % * __object__ Object image which will move slowly over the
            %   background.
            %
            % ## Options
            % * __Amplitude__ Amplitude of wave distortion applied to
            %   background. default 2.0
            % * __Wavelength__ Length of waves in distortion applied to
            %   background. default 20.0
            % * __Wavespeed__ How fast waves will move. default 0.2
            % * __Objspeed__ How fast object will fly over background.
            %   default 6.0
            %
            % See also: cv.SyntheticSequenceGenerator.getNextFrame
            %
            this.id = SyntheticSequenceGenerator_(0, 'new', background, object, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SyntheticSequenceGenerator
            %
            if isempty(this.id), return; end
            SyntheticSequenceGenerator_(this.id, 'delete');
        end

        function [frame, gtMask] = getNextFrame(this)
            %GETNEXTFRAME  Obtain the next frame in the sequence
            %
            %     [frame, gtMask] = obj.getNextFrame()
            %
            % ## Output
            % * __frame__ Output frame.
            % * __gtMask__ Output ground-truth (reference) segmentation mask
            %   object/background.
            %
            [frame, gtMask] = SyntheticSequenceGenerator_(this.id, 'getNextFrame');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SyntheticSequenceGenerator.empty,
            %  cv.SyntheticSequenceGenerator.load
            %
            SyntheticSequenceGenerator_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.SyntheticSequenceGenerator.clear,
            %  cv.SyntheticSequenceGenerator.load
            %
            b = SyntheticSequenceGenerator_(this.id, 'empty');
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
            % See also: cv.SyntheticSequenceGenerator.save,
            %  cv.SyntheticSequenceGenerator.load
            %
            name = SyntheticSequenceGenerator_(this.id, 'getDefaultName');
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
            % See also: cv.SyntheticSequenceGenerator.load
            %
            SyntheticSequenceGenerator_(this.id, 'save', filename);
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
            % See also: cv.SyntheticSequenceGenerator.save
            %
            SyntheticSequenceGenerator_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
