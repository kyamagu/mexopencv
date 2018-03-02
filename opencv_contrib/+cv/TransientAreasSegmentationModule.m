classdef TransientAreasSegmentationModule < handle
    %TRANSIENTAREASSEGMENTATIONMODULE  Class which provides a transient/moving areas segmentation module
    %
    % A transient areas (spatio-temporal events) segmentation tool to use at
    % the output of the Retina.
    %
    % Perform a locally adapted segmentation by using the retina magno input
    % data Based on Alexandre BENOIT thesis:
    % "Le systeme visuel humain au secours de la vision par ordinateur"
    %
    % Three spatio temporal filters are used:
    %
    % - a first one which filters the noise and local variations of the input
    %   motion energy
    % - a second (more powerfull low pass spatial filter) which gives the
    %   neighborhood motion energy the segmentation consists in the comparison
    %   of these both outputs, if the local motion energy is higher to the
    %   neighborhood motion energy, then the area is considered as moving and
    %   is segmented
    % - a stronger third low pass filter helps decision by providing a smooth
    %   information about the "motion context" in a wider area
    %
    % **Use**: extract areas that present spatio-temporal changes.
    % It should be used at the output of the cv.Retina.getMagnoRAW output that
    % enhances spatio-temporal changes.
    %
    % See also: cv.Retina
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = TransientAreasSegmentationModule(inputSize)
            %TRANSIENTAREASSEGMENTATIONMODULE  Allocator
            %
            %     obj = cv.TransientAreasSegmentationModule(inputSize)
            %
            % ## Input
            % * __inputSize__ size of the images input to segment `[w,h]`
            %   (output will be the same size).
            %
            % See also: cv.TransientAreasSegmentationModule.run
            %
            this.id = TransientAreasSegmentationModule_(0, 'new', inputSize);
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.TransientAreasSegmentationModule
            %
            if isempty(this.id), return; end
            TransientAreasSegmentationModule_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.TransientAreasSegmentationModule.empty,
            %  cv.TransientAreasSegmentationModule.load
            %
            TransientAreasSegmentationModule_(this.id, 'clear');
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
            % See also: cv.TransientAreasSegmentationModule.clear,
            %  cv.TransientAreasSegmentationModule.load
            %
            b = TransientAreasSegmentationModule_(this.id, 'empty');
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
            % See also: cv.TransientAreasSegmentationModule.load
            %
            TransientAreasSegmentationModule_(this.id, 'save', filename);
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
            % See also: cv.TransientAreasSegmentationModule.save
            %
            TransientAreasSegmentationModule_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.TransientAreasSegmentationModule.save,
            %  cv.TransientAreasSegmentationModule.load
            %
            name = TransientAreasSegmentationModule_(this.id, 'getDefaultName');
        end
    end

    %% TransientAreasSegmentationModule
    methods
        function sz = getSize(this)
            %GETSIZE  Return the size of the manage input and output images
            %
            %     sz = obj.getSize()
            %
            % ## Output
            % * __sz__ image size `[w,h]`.
            %
            % See also: cv.TransientAreasSegmentationModule.TransientAreasSegmentationModule
            %
            sz = TransientAreasSegmentationModule_(this.id, 'getSize');
        end

        function setup(this, segmentationParameterFile, varargin)
            %SETUP  Try to open an XML segmentation parameters file to adjust current segmentation instance setup
            %
            %     obj.setup(segmentationParameterFile)
            %     obj.setup(segmentationParameterFile, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __segmentationParameterFile__ the parameters filename.
            %
            % ## Options
            % * __ApplyDefaultSetupOnFailure__ set to true if an error must be
            %   thrown on error. default true
            %
            % If the xml file does not exist, then default setup is applied.
            % Warning: Exceptions are thrown if read XML file is not valid.
            %
            % See also: cv.TransientAreasSegmentationModule.setupParameters,
            %  cv.TransientAreasSegmentationModule.write
            %
            TransientAreasSegmentationModule_(this.id, 'setup', segmentationParameterFile, varargin{:});
        end

        function setupParameters(this, varargin)
            %SETUPPARAMETERS  Pass segmentation parameters to adjust current segmentation instance setup
            %
            %     obj.setupParameters('OptionName',optionValue, ...)
            %
            % ## Options
            % * __ThresholdON__ default 100
            % * __ThresholdOFF__ default 100
            % * __LocalEnergyTemporalConstant__ the time constant of the first
            %   order low pass filter, use it to cut high temporal frequencies
            %   (noise or fast motion), unit is frames, typical value is 0.5
            %   frame. default 0.5
            % * __LocalEnergySpatialConstant__ the spatial constant of the
            %   first order low pass filter, use it to cut high spatial
            %   frequencies (noise or thick contours), unit is pixels, typical
            %   value is 5 pixel. default 5
            % * __NeighborhoodEnergyTemporalConstant__ local neighborhood
            %   energy filtering parameters: the aim is to get information
            %   about the energy neighborhood to perform a center surround
            %   energy analysis. default 1
            % * __NeighborhoodEnergySpatialConstant__ see
            %   `NeighborhoodEnergyTemporalConstant`. default 15
            % * __ContextEnergyTemporalConstant__ context neighborhood energy
            %   filtering parameters: the aim is to get information about the
            %   energy on a wide neighborhood area to filtered out local
            %   effects. default 1
            % * __ContextEnergySpatialConstant__ see
            %   `ContextEnergyTemporalConstant`. default 75
            %
            % Sets new parameter structure that stores the transient events
            % detector setup parameters.
            %
            % See also: cv.TransientAreasSegmentationModule.setup
            %
            TransientAreasSegmentationModule_(this.id, 'setupParameters', varargin{:});
        end

        function params = getParameters(this)
            %GETPARAMETERS  Return the current parameters setup
            %
            %     params = obj.getParameters()
            %
            % ## Output
            % * __params__ the current parameters setup.
            %
            % See also: cv.TransientAreasSegmentationModule.setupParameters,
            %  cv.TransientAreasSegmentationModule.printSetup
            %
            params = TransientAreasSegmentationModule_(this.id, 'getParameters');
        end

        function str = printSetup(this)
            %PRINTSETUP  Parameters setup display method
            %
            %     str = obj.printSetup()
            %
            % ## Output
            % * __str__ a string which contains formatted parameters
            %   information.
            %
            % See also: cv.TransientAreasSegmentationModule.getParameters
            %
            str = TransientAreasSegmentationModule_(this.id, 'printSetup');
        end

        function varargout = write(this, fs)
            %WRITE  Write xml/yml formatted parameters information
            %
            %     obj.write(fs)
            %     str = obj.write(fs)
            %
            % ## Input
            % * __fs__ the filename of the xml file that will be open and
            %   writen with formatted parameters information.
            %
            % ## Output
            % * __str__ optional output. If requested, the parameters are
            %   persisted to a string in memory instead of writing to disk.
            %
            % See also: cv.TransientAreasSegmentationModule.setup
            %
            [varargout{1:nargout}] = TransientAreasSegmentationModule_(this.id, 'write', fs);
        end

        function run(this, inputToSegment)
            %RUN  Main processing method
            %
            %     obj.run(inputToSegment)
            %     obj.run(inputToSegment, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __inputToSegment__ the image to process, it must match the
            %   instance buffer size.
            %
            % ## Options
            % * __ChannelIndex__ the channel to process in case of
            %   multichannel images (0-based index). default 0
            %
            % Get result using
            % cv.TransientAreasSegmentationModule.getSegmentationPicture
            % method.
            %
            % See also: cv.TransientAreasSegmentationModule.getSegmentationPicture
            %
            TransientAreasSegmentationModule_(this.id, 'run', inputToSegment);
        end

        function transientAreas = getSegmentationPicture(this)
            %GETSEGMENTATIONPICTURE  Access function
            %
            %     transientAreas = obj.getSegmentationPicture()
            %
            % ## Output
            % * __transientAreas__ the last segmentation result: a boolean
            %   picture which is resampled between 0 and 255 for a display
            %   purpose.
            %
            % See also: cv.TransientAreasSegmentationModule.run
            %
            transientAreas = TransientAreasSegmentationModule_(this.id, 'getSegmentationPicture');
        end

        function clearAllBuffers(this)
            %CLEARALLBUFFERS  Cleans all the buffers of the instance
            %
            %     obj.clearAllBuffers()
            %
            % See also: cv.TransientAreasSegmentationModule.run
            %
            TransientAreasSegmentationModule_(this.id, 'clearAllBuffers');
        end
    end

end
