classdef RetinaFastToneMapping < handle
    %RETINAFASTTONEMAPPING  Class with tone mapping algorithm of Meylan et al. (2007)
    %
    % High Dynamic Range (HDR >8bit images) tone mapping to (conversion to
    % 8bit) use case of the retina.
    %
    % This algorithm is already implemented in thre Retina class
    % (cv.Retina.applyFastToneMapping) but used it does not require all the
    % retina model to be allocated. This allows a light memory use for low
    % memory devices (smartphones, etc.). As a summary, these are the model
    % properties:
    %
    % - 2 stages of local luminance adaptation with a different local
    %   neighborhood for each.
    % - first stage models the retina photorecetors local luminance adaptation
    % - second stage models th ganglion cells local information adaptation
    % - compared to the initial publication, this class uses spatio-temporal
    %   low pass filters instead of spatial only filters. this can help noise
    %   robustness and temporal stability for video sequence use cases.
    %
    % For more information, read to the following papers: [Meylan2007] and
    % [Benoit2010]. Regarding spatio-temporal filter and the bigger retina
    % model: [Herault2010].
    %
    % ## References
    % [Meylan2007]:
    % > Meylan L., Alleysson D., and Susstrunk S., "A Model of Retinal Local
    % > Adaptation for the Tone Mapping of Color Filter Array Images", Journal
    % > of Optical Society of America, A, Vol. 24, N. 9, September, 1st, 2007,
    % > pp. 2807-2816
    %
    % [Benoit2010]:
    % > Benoit A., Caplier A., Durette B., Herault, J.; "Using Human Visual
    % > System Modeling For Bio-inspired Low Level Image Processing", Elsevier,
    % > Computer Vision and Image Understanding 114 (2010), pp. 758-773,
    % > [DOI](http://dx.doi.org/10.1016/j.cviu.2010.01.011)
    %
    % [Herault2010]:
    % > Jeanny Herault; "Vision: Images, Signals and Neural Networks: Models
    % > of Neural Processing in Visual Perception" (Progress in Neural
    % > Processing), ISBN: 9814273686. WAPI (Tower ID): 113266891.
    %
    % See also: cv.Retina
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = RetinaFastToneMapping(inputSize)
            %RETINAFASTTONEMAPPING  Constructor
            %
            %     obj = cv.RetinaFastToneMapping(inputSize)
            %
            % ## Input
            % * __inputSize__ input image size `[w,h]`.
            %
            % See also: cv.RetinaFastToneMapping.applyFastToneMapping
            %
            this.id = RetinaFastToneMapping_(0, 'new', inputSize);
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.RetinaFastToneMapping
            %
            if isempty(this.id), return; end
            RetinaFastToneMapping_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.RetinaFastToneMapping.empty,
            %  cv.RetinaFastToneMapping.load
            %
            RetinaFastToneMapping_(this.id, 'clear');
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
            % See also: cv.RetinaFastToneMapping.clear,
            %  cv.RetinaFastToneMapping.load
            %
            b = RetinaFastToneMapping_(this.id, 'empty');
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
            % See also: cv.RetinaFastToneMapping.load
            %
            RetinaFastToneMapping_(this.id, 'save', filename);
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
            % See also: cv.RetinaFastToneMapping.save
            %
            RetinaFastToneMapping_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.RetinaFastToneMapping.save,
            %  cv.RetinaFastToneMapping.load
            %
            name = RetinaFastToneMapping_(this.id, 'getDefaultName');
        end
    end

    %% RetinaFastToneMapping
    methods
        function setup(this, varargin)
            %SETUP  Updates tone mapping behaviors by adjusing the local luminance computation area
            %
            %     obj.setup('OptionName',optionValue, ...)
            %
            % ## Options
            % * __PhotoreceptorsNeighborhoodRadius__ the first stage local
            %   adaptation area. default 3.0
            % * __GanglioncellsNeighborhoodRadius__ the second stage local
            %   adaptation area. default 1.0
            % * __MeanLuminanceModulatorK__ the factor applied to modulate the
            %   mean Luminance information (default is 1, see reference paper).
            %   default 1.0
            %
            % See also: cv.RetinaFastToneMapping.applyFastToneMapping
            %
            RetinaFastToneMapping_(this.id, 'setup', varargin{:});
        end

        function outputToneMappedImage = applyFastToneMapping(this, inputImage)
            %APPLYFASTTONEMAPPING  Applies a luminance correction (initially High Dynamic Range (HDR) tone mapping)
            %
            %     outputToneMappedImage = obj.applyFastToneMapping(inputImage)
            %
            % ## Input
            % * __inputImage__ the input image to process RGB or gray levels.
            %
            % ## Output
            % * __outputToneMappedImage__ the output tone mapped image.
            %
            % Using only the 2 local adaptation stages of the retina
            % parvocellular channel: photoreceptors level and ganlion cells
            % level. Spatio temporal filtering is applied but limited to
            % temporal smoothing and eventually high frequencies attenuation.
            % This is a lighter method than the one available using the
            % regular cv.Retina.run method. It is then faster but it does not
            % include complete temporal filtering nor retina spectral
            % whitening. Then, it can have a more limited effect on images
            % with a very high dynamic range. This is an adptation of the
            % original still image HDR tone mapping algorithm of David
            % Alleyson, Sabine Susstruck and Laurence Meylan's work, please
            % cite [Meylan2007].
            %
            % See also: cv.RetinaFastToneMapping.setup
            %
            outputToneMappedImage = RetinaFastToneMapping_(this.id, 'applyFastToneMapping', inputImage);
        end
    end

end
