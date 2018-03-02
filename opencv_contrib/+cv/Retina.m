classdef Retina < handle
    %RETINA  A biological retina model for image spatio-temporal noise and luminance changes enhancement
    %
    % Class which allows the Gipsa/Listic Labs model to be used with OpenCV.
    %
    % This retina model allows spatio-temporal image processing (applied on
    % still images, video sequences).
    %
    % As a summary, these are the retina model properties:
    %
    % - It applies a spectral whithening (mid-frequency details enhancement)
    % - high frequency spatio-temporal noise reduction
    % - low frequency luminance to be reduced (luminance range compression)
    % - local logarithmic luminance compression allows details to be enhanced
    %   in low light conditions
    %
    % **USE**: this model can be used basically for spatio-temporal video
    % effects but also for:
    %
    % - using the `getParvo` method output matrix: texture analysis with
    %   enhanced signal to noise ratio and enhanced details robust against
    %   input images luminance ranges
    % - using the `getMagno` method output matrix: motion analysis also with
    %   the previously cited properties
    %
    % For more information, refer to the following papers [Benoit2010] and
    % [Herault2010].
    %
    % ## Retina class overview
    %
    % ### Introduction
    %
    % This class provides the main controls of the Gipsa/Listic labs human
    % retina model. This is a non separable spatio-temporal filter modelling
    % the two main retina information channels:
    %
    % - foveal vision for detailed color vision: the parvocellular pathway.
    % - peripheral vision for sensitive transient signals detection (motion
    %   and events): the magnocellular pathway.
    %
    % This model originates from Jeanny Herault work [Herault2010]. It has
    % been involved in Alexandre Benoit phd and his current research
    % [Benoit2010], [Benoit2014]. He currently maintains this module within
    % OpenCV. It includes the work of other Jeanny's phd student such as
    % [Chaix2007] and the log polar transformations of Barthelemy Durette
    % described in Jeanny's book.
    %
    % More into details here is an overview of the retina properties that are
    % implemented here:
    %
    % Regarding luminance and details enhancement:
    %
    % - local logarithmic luminance compression (at the entry point by
    %   photoreceptors and at the output by ganglion cells).
    % - spectral whitening at the Outer Plexiform Layer level (photoreceptors
    %   and horizontal cells spatio-temporal filtering).
    %
    % The former behavior compresses luminance range and allows very bright
    % areas and very dark ones to be visible on the same picture with lots of
    % details. The latter reduces low frequency luminance energy (mean
    % luminance) and enhances mid-frequencies (details). Applied all together,
    % retina well prepares visual signals prior high level analysis. Those
    % properties are really interesting with videos where light changes are
    % dramatically reduced with an interesting temporal consistency.
    %
    % Regarding noise filtering :
    %
    % - high frequency spatial and temporal noise is filtered out. Both
    %   outputs Parvo and Magno pathways benefit from this. Noise reduction
    %   benefits from the non separable spatio-temporal filtering.
    % - at the Parvo output, static textures are enhanced and noise is
    %   filtered (on videos, temporal noise is nicely removed). However, as
    %   human behaviors, moving textures are smoothed. Then, moving object
    %   details can be only enhanced  if the retina tracks it and keeps it
    %   static from its point of view.
    % - at Magno output, it allows a cleaner detection of events (motion,
    %   changes) with reduced noise errors even in difficult lighting
    %   conditions. As a compromise, the Magno output is a low spatial
    %   frequency signal and allows events' blobs to be reliably extracted
    %   (check the cv.TransientAreasSegmentationModule module for that).
    %
    % ### Use
    %
    % This model can be used as a preprocessing stage in the aim of:
    %
    % - performing texture analysis with enhanced signal to noise ratio and
    %   enhanced details which are robust against input images luminance
    %   ranges (check out the parvocellular retina channel output, by using
    %   the provided `getParvo` methods)
    % - performing motion analysis that is also taking advantage of the
    %   previously cited properties (check out the magnocellular retina
    %   channel output, by using the provided `getMagno` methods)
    % - general image/video sequence description using either one or both
    %   channels. An example of the use of Retina in a Bag of Words approach
    %   is given in [Benoit2014].
    %
    % Note:
    %
    % - For ease of use in computer vision applications, the two retina
    %   channels are applied on all the input images. This does not follow the
    %   real retina topology but it is practical from an image processing
    %   point of view. If retina mapping (foveal and parafoveal vision) is
    %   required, use the log sampling capabilities proposed within the class.
    % - Please do not hesitate to contribute by extending the retina
    %   description, code, use cases for complementary explanations and
    %   demonstrations.
    %
    % ### Use case illustrations
    %
    % #### Image preprocessing using the Parvocellular pathway (parvo retina output)
    %
    % As a preliminary presentation, let's start with a visual example. We
    % propose to apply the filter on a low quality color jpeg image with
    % backlight problems. Here is the considered input...
    % *"Well,i could see more with my eyes than what i captured with my camera..."*
    %
    % ![image](https://docs.opencv.org/3.3.1/retinaInput.jpg)
    %
    % Below, the retina foveal model applied on the entire image with default
    % parameters. Details are enforced whatever the local luminance is. Here
    % there contours are strongly enforced but the noise level is kept low.
    % Halo effects are voluntary visible with this configuration. See
    % parameters discussion below and increase `HorizontalCellsGain` near 1 to
    % remove them.
    %
    % ![image](https://docs.opencv.org/3.3.1/retinaOutput_default.jpg)
    %
    % Below, a second retina foveal model output applied on the entire image
    % with a parameters setup focused on naturalness perception.
    % *"Hey, i now recognize my cat, looking at the mountains at the end of the day!"*.
    % Here contours are enforced, luminance is corrected but halos are avoided
    % with this configuration. The backlight effect is corrected and highlight
    % details are still preserved. Then, even on a low quality jpeg image, if
    % some luminance's information remains, the retina is able to reconstruct
    % a proper visual signal. Such configuration is also useful for High
    % Dynamic Range (HDR) images compression to 8bit images as discussed in
    % [Benoit2010] and in the demonstration codes discussed below. As shown at
    % the end of the page, parameter changes from defaults are:
    %
    % - `HorizontalCellsGain = 0.3`
    % - `PhotoreceptorsLocalAdaptationSensitivity = GanglioncellsSensitivity = 0.89`.
    %
    % ![image](https://docs.opencv.org/3.3.1/retinaOutput_realistic.jpg)
    %
    % As observed in this preliminary demo, the retina can be settled up with
    % various parameters, by default, as shown on the figure above, the retina
    % strongly reduces mean luminance energy and enforces all details of the
    % visual scene. Luminance energy and halo effects can be modulated
    % (exaggerated to cancelled as shown on the two examples). In order to use
    % your own parameters, you can use at least one time the cv.Retina.write
    % method which will write a proper XML file with all default parameters.
    % Then, tweak it on your own and reload them at any time using method
    % cv.Retina.setup. These methods update a `RetinaParameters` member
    % structure that is described hereafter. XML parameters file samples are
    % shown at the end of the page.
    %
    % #### Tone mapping processing capability using the Parvocellular pathway (parvo retina output)
    %
    % This retina model naturally handles luminance range compression. Local
    % adaptation stages and spectral whitening contribute to luminance range
    % compression. In addition, high frequency noise that often corrupts tone
    % mapped images is removed at early stages of the process thus leading to
    % natural perception and noise free tone mapping.
    %
    % Compared to the demos shown above, setup differences are the following
    % ones:
    %
    % * load HDR images (OpenEXR format is supported by OpenCV) and cut
    %   histogram borders at ~5% and 95% to eliminate salt&pepper like pixel's
    %   corruption.
    % * apply retina with default parameters along with the following changes
    %   (generic parameters used for the presented illustrations of the
    %   section):
    %   * `HorizontalCellsGain=0.4` (the main change compared to the default
    %     configuration: it strongly reduces halo effects)
    %   * `PhotoreceptorsLocalAdaptationSensitivity=0.99` (a little higher
    %     than default value to enforce local adaptation)
    %   * `GanglionCellsSensitivity=0.95` (also slightly higher than default
    %     for local adaptation enforcement)
    % * get the parvo output using the cv.Retina.getParvo method.
    %
    % Have a look at the end of this page to see how to specify these
    % parameters in a configuration file.
    %
    % The following two illustrations show the effect of such configuration on
    % 2 image samples.
    %
    % - HDR image tone mapping example with generic parameters.
    %   Original image comes from [OpenEXR](http://openexr.com/) samples
    %   (`openexr-images-1.7.0/ScanLines/CandleGlass.exr`)
    %
    %   ![image](https://docs.opencv.org/3.3.1/HDRtoneMapping_candleSample.jpg)
    %
    % - HDR image tone mapping example with the same generic parameters.
    %   Original image comes from
    %   [memorial.exr](http://www.pauldebevec.com/Research/HDR/memorial.exr)
    %
    %   ![image](https://docs.opencv.org/3.3.1/HDRtoneMapping_memorialSample.jpg)
    %
    % #### Motion and event detection using the Magnocellular pathway (magno retina output)
    %
    % Spatio-temporal events can be easily detected using *magno* output of
    % the retina (use the cv.Retina.getMagno method). Its energy linearly
    % increases with motion speed.
    %
    % An event blob detector is proposed with the
    % cv.TransientAreasSegmentationModule class also provided in the
    % bioinspired module. The basic idea is to detect local energy drops with
    % regard of the neighborhood and then to apply a threshold. Such process
    % has been used in a bag of words description of videos on the TRECVid
    % challenge [Benoit2014] and only allows video frames description on
    % transient areas.
    %
    % We present here some illustrations of the retina outputs on some
    % examples taken from [CDNET](http://changedetection.net/) with RGB and
    % thermal videos.
    %
    % NOTE: here, we use the default retina setup that generates halos around
    % strong edges. Note that temporal constants allow a temporal effect to be
    % visible on moting objects (useful for still image illustrations of a
    % video). Halos can be removed by increasing retina Hcells gain while
    % temporal effects can be reduced by decreasing temporal constant values.
    % Also take into account that the two retina outputs are rescaled in range
    % `[0:255]` such that magno output can show a lot of "noise" when nothing
    % moves while drawing it. However, its energy remains low if you retrieve
    % it using cv.Retina.getMagnoRAW getter instead.
    %
    % - Retina processing on RGB image sequence: example from
    %   [CDNET](http://changedetection.net/) (baseline/PETS2006).
    %   Parvo enforces static signals but smooths moving persons since they do
    %   not remain static from its point of view.
    %   Magno channel highligths moving persons, observe the energy mapping on
    %   the one on top, partly behind a dark glass.
    %
    %   ![image](https://docs.opencv.org/3.3.1/VideoDemo_RGB_PETS2006.jpg)
    %
    % - Retina processing on gray levels image sequence: example from
    %   [CDNET](http://changedetection.net/) (thermal/park).
    %   On such grayscale images, parvo channel enforces contrasts while mango
    %   strongly reacts on moving pedestrians
    %
    %   ![image](https://docs.opencv.org/3.3.1/VideoDemo_thermal_park.jpg)
    %
    % ### Literature
    %
    % For more information, refer to the following papers:
    %
    % - Model description: [Benoit2010]
    % - Model use in a Bag of Words approach: [Benoit2014]
    % - Please have a look at the reference work of Jeanny Herault that you
    %   can read in his book: [Herault2010]
    %
    % This retina filter code includes the research contributions of
    % phd/research collegues from which code has been redrawn by the author:
    %
    % - take a look at the `retinacolor.hpp` module to discover Brice Chaix
    %   de Lavarene phD color mosaicing/demosaicing and his reference paper
    %   [Chaix2007]
    %
    % - take a look at `imagelogpolprojection.hpp` to discover retina spatial
    %   log sampling which originates from Barthelemy Durette phd with Jeanny
    %   Herault. A Retina / V1 cortex projection is also proposed and
    %   originates from Jeanny's discussions. More information in the above
    %   cited Jeanny Heraults's book.
    %
    % - Meylan et al. work on HDR tone mapping that is implemented as a
    %   specific method within the model [Meylan2007]
    %
    % ## Retina programming interfaces
    %
    % The proposed class allows the [Gipsa](http://www.gipsa-lab.inpg.fr)
    % (preliminary work) / [Listic](http://www.listic.univ-savoie.fr) labs
    % retina model to be used. It can be applied on still images, images
    % sequences and video sequences.
    %
    % ### Setting up Retina
    %
    % #### Managing the configuration file
    %
    % When using the cv.Retina.write and cv.Retina.load methods, you create or
    % load a XML file that stores Retina configuration.
    %
    % The default configuration is presented below.
    %
    % ```xml
    % <?xml version="1.0"?>
    % <opencv_storage>
    % <OPLandIPLparvo>
    %     <colorMode>1</colorMode>
    %     <normaliseOutput>1</normaliseOutput>
    %     <photoreceptorsLocalAdaptationSensitivity>7.5e-01</photoreceptorsLocalAdaptationSensitivity>
    %     <photoreceptorsTemporalConstant>9.0e-01</photoreceptorsTemporalConstant>
    %     <photoreceptorsSpatialConstant>5.7e-01</photoreceptorsSpatialConstant>
    %     <horizontalCellsGain>0.01</horizontalCellsGain>
    %     <hcellsTemporalConstant>0.5</hcellsTemporalConstant>
    %     <hcellsSpatialConstant>7.</hcellsSpatialConstant>
    %     <ganglionCellsSensitivity>7.5e-01</ganglionCellsSensitivity>
    % </OPLandIPLparvo>
    % <IPLmagno>
    %     <normaliseOutput>1</normaliseOutput>
    %     <parasolCells_beta>0.</parasolCells_beta>
    %     <parasolCells_tau>0.</parasolCells_tau>
    %     <parasolCells_k>7.</parasolCells_k>
    %     <amacrinCellsTemporalCutFrequency>2.0e+00</amacrinCellsTemporalCutFrequency>
    %     <V0CompressionParameter>9.5e-01</V0CompressionParameter>
    %     <localAdaptintegration_tau>0.</localAdaptintegration_tau>
    %     <localAdaptintegration_k>7.</localAdaptintegration_k>
    % </IPLmagno>
    % </opencv_storage>
    % ```
    %
    % Here are some words about all those parameters, tweak them as you wish
    % to amplify or moderate retina effects (contours enforcement, halos
    % effects, motion sensitivity, motion blurring, etc.)
    %
    % #### Basic parameters
    %
    % The simplest parameters are as follows:
    %
    % * __ColorMode__: let the retina process color information (if 1) or gray
    %   scale images (if 0). In that last case, only the first channels of the
    %   input will be processed.
    % * __NormaliseOutput__: each channel has such parameter: if the value is
    %   set to 1, then the considered channel's output is rescaled between 0
    %   and 255. Be aware at this case of the Magnocellular output level
    %   (motion/transient channel detection). Residual noise will also be
    %   rescaled!
    %
    % **Note**: using color requires color channels multiplexing/demultipexing
    % which also demands more processing. You can expect much faster processing
    % using gray levels: it would require around 30 product per pixel for all
    % of the retina processes and it has recently been parallelized for
    % multicore architectures.
    %
    % #### Photo-receptors parameters
    %
    % The following parameters act on the entry point of the retina
    % (photo-receptors) and has impact on all of the following processes.
    % These sensors are low pass spatio-temporal filters that smooth temporal
    % and spatial data and also adjust their sensitivity to local luminance,
    % thus, leads to improving details extraction and high frequency noise
    % canceling.
    %
    % * __PhotoreceptorsLocalAdaptationSensitivity__ between 0 and 1. Values
    %   close to 1 allow high luminance log compression's effect at the
    %   photo-receptors level. Values closer to 0 provide a more linear
    %   sensitivity. Increased alone, it can burn the *Parvo (details channel)*
    %   output image. If adjusted in collaboration with
    %   `GanglionCellsSensitivity`, images can be very contrasted whatever the
    %   local luminance there is at the cost of a naturalness decrease.
    % * __PhotoreceptorsTemporalConstant__ this setups the temporal constant
    %   of the low pass filter effect at the entry of the retina. High value
    %   leads to strong temporal smoothing effect: moving objects are blurred
    %   and can disappear while static object are favored. But when starting
    %   the retina processing, stable state is reached later.
    % * __PhotoreceptorsSpatialConstant__ specifies the spatial constant
    %   related to photo-receptors' lowpass filter's effect. Those parameters
    %   specify the minimum value of the spatial signal period allowed in what
    %   follows. Typically, this filter should cut high frequency noise. On
    %   the other hand, a 0 value cuts none of the noise while higher values
    %   start to cut high spatial frequencies, and progressively lower
    %   frequencies... Be aware to not go to high levels if you want to see
    %   some details of the input images! A good compromise for color images
    %   is a 0.53 value since such choice won't affect too much the color
    %   spectrum. Higher values would lead to gray and blurred output images.
    %
    % #### Horizontal cells parameters
    %
    % This parameter set tunes the neural network connected to the
    % photo-receptors, the horizontal cells. It modulates photo-receptors
    % sensitivity and completes the processing for final spectral whitening
    % (part of the spatial band pass effect thus favoring visual details
    % enhancement).
    %
    % * __HorizontalCellsGain__ here is a critical parameter! If you are not
    %   interested with the mean luminance and want just to focus on details
    %   enhancement, then, set this parameterto zero. However, if you want to
    %   keep some environment luminance's data, let some low spatial
    %   frequencies pass into the system and set a higher value (<1).
    % * __HCellsTemporalConstant__ similar to photo-receptors, this parameter
    %   acts on the temporal constant of a low pass temporal filter that
    %   smooths input data. Here, a high value generates a high retina after
    %   effect while a lower value makes the retina more reactive. This value
    %   should be lower than `PhotoreceptorsTemporalConstant` to limit strong
    %   retina after effects.
    % * __HCellsSpatialConstant__ is the spatial constant of these cells
    %   filter's low pass one. It specifies the lowest spatial frequency
    %   allowed in what follows. Visually, a high value leads to very low
    %   spatial frequencies processing and leads to salient halo effects.
    %   Lower values reduce this effect but has the limit of not go lower than
    %   the value of `PhotoreceptorsSpatialConstant`. Those 2 parameters
    %   actually specify the spatial band-pass of the retina.
    %
    % **NOTE**: Once the processing managed by the previous parameters is done,
    % input data is cleaned from noise and luminance is already partly
    % enhanced. The following parameters act on the last processing stages of
    % the two outing retina signals.
    %
    % #### Parvo (details channel) dedicated parameter
    %
    % * __GanglionCellsSensitivity__ specifies the strength of the final local
    %   adaptation occurring at the output of this details' dedicated channel.
    %   Parameter values remain between 0 and 1. Low value tend to give a
    %   linear response while higher values enforce the remaining low
    %   contrasted areas.
    %
    % **Note**: this parameter can correct eventual burned images by favoring
    % low energetic details of the visual scene, even in bright areas.
    %
    % #### IPL Magno (motion/transient channel) parameters
    %
    % Once image's information are cleaned, this channel acts as a high pass
    % temporal filter that selects only the signals related to transient
    % signals (events, motion, etc.). A low pass spatial filter smooths
    % extracted transient data while a final logarithmic compression enhances
    % low transient events thus enhancing event sensitivity.
    %
    % * __ParasolCellsBeta__ generally set to zero, can be considered as an
    %   amplifier gain at the entry point of this processing stage. Generally
    %   set to 0.
    % * __ParasolCellsTau__ the temporal smoothing effect that can be added
    % * __ParasolCellsK__ the spatial constant of the spatial filtering
    %   effect, set it at a high value to favor low spatial frequency signals
    %   that are lower subject for residual noise.
    % * __AmacrinCellsTemporalCutFrequency__ specifies the temporal constant
    %   of the high pass filter. High values let slow transient events to be
    %   selected.
    % * __V0CompressionParameter__ specifies the strength of the log
    %   compression. Similar behaviors to previous description but here
    %   enforces sensitivity of transient events.
    % * __LocalAdaptintegrationTau__ generally set to 0, has no real use
    %   actually in here.
    % * __LocalAdaptintegrationK__ specifies the size of the area on which
    %   local adaptation is performed. Low values lead to short range local
    %   adaptation (higher sensitivity to noise), high values secure log
    %   compression.
    %
    % ### Demos and experiments
    %
    % #### First time experiments
    %
    % Here are some code snippets to shortly show how to use Retina with
    % default parameters (with halo effects). Next section redirects to more
    % complete demos provided with the main retina class.
    %
    % Here is presented how to process a webcam stream with the following
    % steps:
    %
    % - load a frist input image to get its size
    % - allocate a retina instance with appropriate input size
    % - loop over grabbed frames:
    %   - grab a new frame
    %   - run on a frame
    %   - call the two output getters
    %   - display retina outputs
    %
    % See `retina_demo.m` MATLAB sample.
    %
    % #### More complete demos
    %
    % Note: Complementary to the following examples, have a look at the Retina
    % tutorial in the tutorial/contrib section for complementary explanations.
    %
    % ## References
    % [Benoit2010]:
    % > Benoit A., Caplier A., Durette B., Herault, J.; "Using Human Visual
    % > System Modeling For Bio-inspired Low Level Image Processing", Elsevier,
    % > Computer Vision and Image Understanding 114 (2010), pp. 758-773,
    % > [DOI](http://dx.doi.org/10.1016/j.cviu.2010.01.011)
    %
    % [Benoit2014]:
    % > Strat S.T., Benoit A., Lambert P.; "Retina enhanced bag of words
    % > descriptors for video classification". In Proceedings of the 22nd
    % > European Signal Processing Conference (EUSIPCO), 2014, pp. 1307-1311.
    %
    % [Herault2010]:
    % > Jeanny Herault; "Vision: Images, Signals and Neural Networks: Models
    % > of Neural Processing in Visual Perception" (Progress in Neural
    % > Processing), ISBN: 9814273686. WAPI (Tower ID): 113266891.
    %
    % [Chaix2007]:
    % > B. Chaix de Lavarene, D. Alleysson, B. Durette, J. Herault (2007).
    % > "Efficient demosaicing through recursive filtering". IEEE
    % > International Conference on Image Processing ICIP 2007.
    %
    % [Meylan2007]:
    % > Meylan L., Alleysson D., and Susstrunk S., "A Model of Retinal Local
    % > Adaptation for the Tone Mapping of Color Filter Array Images", Journal
    % > of Optical Society of America, A, Vol. 24, N. 9, September, 1st, 2007,
    % > pp. 2807-2816
    %
    % See also: cv.RetinaFastToneMapping, cv.TransientAreasSegmentationModule
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = Retina(inputSize, varargin)
            %RETINA  Constructor from standardized interface to create a Retina instance
            %
            %     obj = cv.Retina(inputSize)
            %     obj = cv.Retina(inputSize, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __inputSize__ the input frame size `[w,h]`.
            %
            % ## Options
            % * __ColorMode__ the chosen processing mode: with or without
            %   color processing. default true
            % * __ColorSamplingMethod__ specifies which kind of color sampling
            %   will be used, default 'Bayer'. One of:
            %   * __Random__ each pixel position is either R, G or B in a
            %     random choice
            %   * __Diagonal__ color sampling is RGBRGBRGB...,
            %     line 2 BRGBRGBRG..., line 3 GBRGBRGBR...
            %   * __Bayer__ standard bayer sampling
            % * __UseRetinaLogSampling__ activate retina log sampling. If true,
            %   the 2 following parameters can be used. default false
            % * __ReductionFactor__ only useful if param
            %   `UseRetinaLogSampling=true`, specifies the reduction factor of
            %   the output frame (as the center (fovea) is high resolution and
            %   corners can be underscaled, then a reduction of the output is
            %   allowed without precision leak). default 1.0
            % * __SamplingStrength__ only useful if param
            %   `UseRetinaLogSampling=true`, specifies the strength of the log
            %   scale that is applied. default 10.0
            %
            % See also: cv.Retina.run
            %
            this.id = Retina_(0, 'new', inputSize, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Retina
            %
            if isempty(this.id), return; end
            Retina_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.Retina.empty, cv.Retina.load
            %
            Retina_(this.id, 'clear');
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
            % See also: cv.Retina.clear, cv.Retina.load
            %
            b = Retina_(this.id, 'empty');
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
            % See also: cv.Retina.load
            %
            Retina_(this.id, 'save', filename);
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
            % See also: cv.Retina.save
            %
            Retina_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.Retina.save, cv.Retina.load
            %
            name = Retina_(this.id, 'getDefaultName');
        end
    end

    %% Retina
    methods
        function sz = getInputSize(this)
            %GETINPUTSIZE  Retreive retina input buffer size
            %
            %     sz = obj.getInputSize()
            %
            % ## Output
            % * __sz__ the retina input buffer size
            %
            % See also: cv.Retina.getOutputSize
            %
            sz = Retina_(this.id, 'getInputSize');
        end

        function sz = getOutputSize(this)
            %GETOUTPUTSIZE  Retreive retina output buffer size that can be different from the input if a spatial log transformation is applied
            %
            %     sz = obj.getOutputSize()
            %
            % ## Output
            % * __sz__ the retina output buffer size
            %
            % See also: cv.Retina.getInputSize
            %
            sz = Retina_(this.id, 'getOutputSize');
        end

        function setup(this, retinaParameterFile, varargin)
            %SETUP  Try to open an XML retina parameters file to adjust current retina instance setup
            %
            %     obj.setup(retinaParameterFile)
            %     obj.setup(retinaParameterFile, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __retinaParameterFile__ the parameters filename.
            %
            % ## Options
            % * __ApplyDefaultSetupOnFailure__ set to true if an error must be
            %   thrown on error. default true
            %
            % If the xml file does not exist, then default setup is applied.
            % Warning: Exceptions are thrown if read XML file is not valid.
            %
            % You can retrieve the current parameters structure using the
            % method cv.Retina.getParameters and update it before running
            % method cv.Retina.setupParameters.
            %
            % See also: cv.Retina.setupParameters, cv.Retina.write
            %
            Retina_(this.id, 'setup', retinaParameterFile, varargin{:});
        end

        function setupParameters(this, varargin)
            %SETUPPARAMETERS  Pass retina parameters to adjust current retina instance setup
            %
            %     obj.setupParameters('OptionName',optionValue, ...)
            %
            % ## Options
            % * __OPLandIplParvo__ Outer Plexiform Layer (OPL) and Inner
            %   Plexiform Layer Parvocellular (IplParvo) parameters.
            % * __IplMagno__ Inner Plexiform Layer Magnocellular channel
            %   (IplMagno).
            %
            % ### `OPLandIplParvo` options
            % See cv.Retina.setupOPLandIPLParvoChannel options.
            %
            % ### `IplMagno` options
            % See cv.Retina.setupIPLMagnoChannel options.
            %
            % Specify retina model parameters structure, with the new target
            % configuration.
            %
            % For better clarity, check explenations on the comments of
            % methods `setupOPLandIPLParvoChannel` and `setupIPLMagnoChannel`.
            %
            % Here is the default configuration file of the retina module. It
            % gives results such as the first retina output shown on the top
            % of this page.
            %
            % ```xml
            % <?xml version="1.0"?>
            % <opencv_storage>
            % <OPLandIPLparvo>
            %     <colorMode>1</colorMode>
            %     <normaliseOutput>1</normaliseOutput>
            %     <photoreceptorsLocalAdaptationSensitivity>7.5e-01</photoreceptorsLocalAdaptationSensitivity>
            %     <photoreceptorsTemporalConstant>9.0e-01</photoreceptorsTemporalConstant>
            %     <photoreceptorsSpatialConstant>5.3e-01</photoreceptorsSpatialConstant>
            %     <horizontalCellsGain>0.01</horizontalCellsGain>
            %     <hcellsTemporalConstant>0.5</hcellsTemporalConstant>
            %     <hcellsSpatialConstant>7.</hcellsSpatialConstant>
            %     <ganglionCellsSensitivity>7.5e-01</ganglionCellsSensitivity>
            % </OPLandIPLparvo>
            % <IPLmagno>
            %     <normaliseOutput>1</normaliseOutput>
            %     <parasolCells_beta>0.</parasolCells_beta>
            %     <parasolCells_tau>0.</parasolCells_tau>
            %     <parasolCells_k>7.</parasolCells_k>
            %     <amacrinCellsTemporalCutFrequency>2.0e+00</amacrinCellsTemporalCutFrequency>
            %     <V0CompressionParameter>9.5e-01</V0CompressionParameter>
            %     <localAdaptintegration_tau>0.</localAdaptintegration_tau>
            %     <localAdaptintegration_k>7.</localAdaptintegration_k>
            % </IPLmagno>
            % </opencv_storage>
            % ```
            %
            % Here is the "realistic" setup used to obtain the second retina
            % output shown on the top of this page.
            %
            % ```xml
            % <?xml version="1.0"?>
            % <opencv_storage>
            % <OPLandIPLparvo>
            %     <colorMode>1</colorMode>
            %     <normaliseOutput>1</normaliseOutput>
            %     <photoreceptorsLocalAdaptationSensitivity>8.9e-01</photoreceptorsLocalAdaptationSensitivity>
            %     <photoreceptorsTemporalConstant>9.0e-01</photoreceptorsTemporalConstant>
            %     <photoreceptorsSpatialConstant>5.3e-01</photoreceptorsSpatialConstant>
            %     <horizontalCellsGain>0.3</horizontalCellsGain>
            %     <hcellsTemporalConstant>0.5</hcellsTemporalConstant>
            %     <hcellsSpatialConstant>7.</hcellsSpatialConstant>
            %     <ganglionCellsSensitivity>8.9e-01</ganglionCellsSensitivity>
            % </OPLandIPLparvo>
            % <IPLmagno>
            %     <normaliseOutput>1</normaliseOutput>
            %     <parasolCells_beta>0.</parasolCells_beta>
            %     <parasolCells_tau>0.</parasolCells_tau>
            %     <parasolCells_k>7.</parasolCells_k>
            %     <amacrinCellsTemporalCutFrequency>2.0e+00</amacrinCellsTemporalCutFrequency>
            %     <V0CompressionParameter>9.5e-01</V0CompressionParameter>
            %     <localAdaptintegration_tau>0.</localAdaptintegration_tau>
            %     <localAdaptintegration_k>7.</localAdaptintegration_k>
            % </IPLmagno>
            % </opencv_storage>
            % ```
            %
            % See also: cv.Retina.setup, cv.Retina.setupOPLandIPLParvoChannel,
            %  cv.Retina.setupIPLMagnoChannel
            %
            Retina_(this.id, 'setupParameters', varargin{:});
        end

        function setupOPLandIPLParvoChannel(this, varargin)
            %SETUPOPLANDIPLPARVOCHANNEL  Setup the OPL and IPL parvo channels (see biologocal model)
            %
            %     obj.setupOPLandIPLParvoChannel('OptionName',optionValue, ...)
            %
            % ## Options
            % * __ColorMode__ specifies if (true) color is processed of not
            %   (false) to then processing gray level image. default true
            % * __NormaliseOutput__ specifies if (true) output is rescaled
            %   between 0 and 255 of not (false). default true
            % * __PhotoreceptorsLocalAdaptationSensitivity__ the photoreceptors
            %   sensitivity renage is 0-1 (more log compression effect when
            %   value increases). default 0.7
            % * __PhotoreceptorsTemporalConstant__ the time constant of the
            %   first order low pass filter of the photoreceptors, use it to
            %   cut high temporal frequencies (noise or fast motion), unit is
            %   frames, typical value is 1 frame. default 0.5
            % * __PhotoreceptorsSpatialConstant__ the spatial constant of the
            %   first order low pass filter of the photoreceptors, use it to
            %   cut high spatial frequencies (noise or thick contours), unit
            %   is pixels, typical value is 1 pixel. default 0.53
            % * __HorizontalCellsGain__ gain of the horizontal cells network,
            %   if 0, then the mean value of the output is zero, if the
            %   parameter is near 1, then, the luminance is not filtered and
            %   is still reachable at the output, typicall value is 0.
            %   default 0.0
            % * __HCellsTemporalConstant__ the time constant of the first
            %   order low pass filter of the horizontal cells, use it to cut
            %   low temporal frequencies (local luminance variations), unit is
            %   frames, typical value is 1 frame, as the photoreceptors.
            %   default 1.0
            % * __HCellsSpatialConstant__ the spatial constant of the first
            %   order low pass filter of the horizontal cells, use it to cut
            %   low spatial frequencies (local luminance), unit is pixels,
            %   typical value is 5 pixel, this value is also used for local
            %   contrast computing when computing the local contrast
            %   adaptation at the ganglion cells level (Inner Plexiform Layer
            %   parvocellular channel model). default 7.0
            % * __GanglionCellsSensitivity__ the compression strengh of the
            %   ganglion cells local adaptation output, set a value between
            %   0.6 and 1 for best results, a high value increases more the
            %   low value sensitivity and the output saturates faster,
            %   recommended value: 0.7. default 0.7
            %
            % OPL is referred as Outer Plexiform Layer of the retina, it
            % allows the spatio-temporal filtering which withens the spectrum
            % and reduces spatio-temporal noise while attenuating global
            % luminance (low frequency energy) IPL parvo is the OPL next
            % processing stage, it refers to a part of the Inner Plexiform
            % layer of the retina, it allows high contours sensitivity in
            % foveal vision. See reference papers for more information. For
            % more information, please have a look at the paper [Benoit2010].
            %
            % See also: cv.Retina.setupIPLMagnoChannel
            %
            Retina_(this.id, 'setupOPLandIPLParvoChannel', varargin{:});
        end

        function setupIPLMagnoChannel(this, varargin)
            %SETUPIPLMAGNOCHANNEL  Set parameters values for the Inner Plexiform Layer (IPL) magnocellular channel
            %
            %     obj.setupIPLMagnoChannel('OptionName',optionValue, ...)
            %
            % ## Options
            % * __NormaliseOutput__ specifies if (true) output is rescaled
            %   between 0 and 255 of not (false). default true
            % * __ParasolCellsBeta__ the low pass filter gain used for local
            %   contrast adaptation at the IPL level of the retina (for
            %   ganglion cells local adaptation), typical value is 0.
            %   default 0.0
            % * __ParasolCellsTau__ the low pass filter time constant used for
            %   local contrast adaptation at the IPL level of the retina (for
            %   ganglion cells local adaptation), unit is frame, typical value
            %   is 0 (immediate response). default 0.0
            % * __ParasolCellsK__ the low pass filter spatial constant used
            %   for local contrast adaptation at the IPL level of the retina
            %   (for ganglion cells local adaptation), unit is pixels, typical
            %   value is 5. default 7.0
            % * __AmacrinCellsTemporalCutFrequency__ the time constant of the
            %   first order high pass fiter of the magnocellular way (motion
            %   information channel), unit is frames, typical value is 1.2.
            %   default 1.2
            % * __V0CompressionParameter__ the compression strengh of the
            %   ganglion cells local adaptation output, set a value between
            %   0.6 and 1 for best results, a high value increases more the
            %   low value sensitivity and the output saturates faster,
            %   recommended value: 0.95. default 0.95
            % * __LocalAdaptintegrationTau__ specifies the temporal constant
            %   of the low pas filter involved in the computation of the local
            %   "motion mean" for the local adaptation computation. default 0.0
            % * __LocalAdaptintegrationK__ specifies the spatial constant of
            %   the low pas filter involved in the computation of the local
            %   "motion mean" for the local adaptation computation. default 7.0
            %
            % This channel processes signals output from OPL processing stage
            % in peripheral vision, it allows motion information enhancement.
            % It is decorrelated from the details channel. See reference
            % papers for more details.
            %
            % See also: cv.Retina.setupOPLandIPLParvoChannel
            %
            Retina_(this.id, 'setupIPLMagnoChannel', varargin{:});
        end

        function params = getParameters(this)
            %GETPARAMETERS  Retrieve the current retina parameters values in a structure
            %
            %     params = obj.getParameters()
            %
            % ## Output
            % * __params__ the current parameters setup.
            %
            % See also: cv.Retina.setupParameters, cv.Retina.printSetup
            %
            params = Retina_(this.id, 'getParameters');
        end

        function str = printSetup(this)
            %PRINTSETUP  Outputs a string showing the used parameters setup
            %
            %     str = obj.printSetup()
            %
            % ## Output
            % * __str__ a string which contains formatted parameters
            %   information.
            %
            % See also: cv.Retina.getParameters
            %
            str = Retina_(this.id, 'printSetup');
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
            % See also: cv.Retina.setup
            %
            [varargout{1:nargout}] = Retina_(this.id, 'write', fs);
        end

        function run(this, inputImage)
            %RUN  Method which allows retina to be applied on an input image
            %
            %     obj.run(inputImage)
            %
            % ## Input
            % * __inputImage__ the input image to be processed, can be gray
            %   level or BGR coded in any format (from 8bit to 16bits).
            %
            % After run, encapsulated retina module is ready to deliver its
            % outputs using dedicated acccessors, see `getParvo` and
            % `getMagno` methods.
            %
            % See also: cv.Retina.getParvo, cv.Retina.getMagno
            %
            if true
                %HACK: temp fix to get around an issue when OpenCL is enabled
                val = cv.Utils.useOptimized();
                cv.Utils.setUseOptimized(false);
                cObj = onCleanup(@() cv.Utils.setUseOptimized(val));
            end
            Retina_(this.id, 'run', inputImage);
        end

        function outputToneMappedImage = applyFastToneMapping(this, inputImage)
            %APPLYFASTTONEMAPPING  Method which processes an image in the aim to correct its luminance correct backlight problems, enhance details in shadows
            %
            %     outputToneMappedImage = obj.applyFastToneMapping(inputImage)
            %
            % ## Input
            % * __inputImage__ the input image to process (should be coded in
            %   float format `single`: 1/3/4-channels, the 4th channel won't
            %   be considered).
            %
            % ## Output
            % * __outputToneMappedImage__ the output 8bit/channel tone mapped
            %   image (`uint8` with 1/3-channels format).
            %
            % This method is designed to perform High Dynamic Range image tone
            % mapping (compress >8bit/pixel images to 8bit/pixel). This is a
            % simplified version of the Retina Parvocellular model (simplified
            % version of the `run`/`getParvo` methods call) since it does not
            % include the spatio-temporal filter modelling the Outer Plexiform
            % Layer of the retina that performs spectral whitening and many
            % other stuff. However, it works great for tone mapping and in a
            % faster way.
            %
            % Check the demos and experiments section to see examples and the
            % way to perform tone mapping using the original retina model and
            % the method.
            %
            % See also: cv.RetinaFastToneMapping
            %
            outputToneMappedImage = Retina_(this.id, 'applyFastToneMapping', inputImage);
        end

        function parvo = getParvo(this)
            %GETPARVO  Accessor of the details channel of the retina (models foveal vision)
            %
            %     parvo = obj.getParvo()
            %
            % ## Output
            % * __parvo__ the output buffer, format can be:
            %   * a matrix, this output is rescaled for standard 8bits image
            %     processing use in OpenCV
            %   * RAW methods actually return a 1D matrix (encoding is
            %     `R1, R2, ..., Rn, G1, G2, ..., Gn, B1, B2, ..., Bn`), this
            %     output is the original retina filter model output, without
            %     any quantification or rescaling.
            %
            % Warning, `getParvoRAW` methods return buffers that are not
            % rescaled within range [0;255] while the non RAW method allows a
            % normalized matrix to be retrieved.
            %
            % See also: cv.Retina.getParvoRAW
            %
            parvo = Retina_(this.id, 'getParvo');
        end

        function parvo = getParvoRAW(this)
            %GETPARVORAW  Accessor of the details channel of the retina (models foveal vision)
            %
            %     parvo = obj.getParvoRAW()
            %
            % ## Output
            % * __parvo__ the output buffer, format can be:
            %   * a matrix, this output is rescaled for standard 8bits image
            %     processing use in OpenCV
            %   * RAW methods actually return a 1D matrix (encoding is
            %     `R1, R2, ..., Rn, G1, G2, ..., Gn, B1, B2, ..., Bn`), this
            %     output is the original retina filter model output, without
            %     any quantification or rescaling.
            %
            % Warning, `getParvoRAW` methods return buffers that are not
            % rescaled within range [0;255] while the non RAW method allows a
            % normalized matrix to be retrieved.
            %
            % See also: cv.Retina.getParvo
            %
            parvo = Retina_(this.id, 'getParvoRAW');
        end

        function magno = getMagno(this)
            %GETMAGNO  Accessor of the motion channel of the retina (models peripheral vision)
            %
            %     magno = obj.getMagno()
            %
            % ## Output
            % * __magno__ the output buffer, format can be:
            %   * a matrix, this output is rescaled for standard 8bits image
            %     processing use in OpenCV
            %   * RAW methods actually return a 1D matrix (encoding is
            %     `M1, M2, ..., Mn`), this output is the original retina filter
            %     model output, without any quantification or rescaling.
            %
            % Warning, `getMagnoRAW` methods return buffers that are not
            % rescaled within range [0;255] while the non RAW method allows a
            % normalized matrix to be retrieved.
            %
            % See also: cv.Retina.getMagnoRAW
            %
            magno = Retina_(this.id, 'getMagno');
        end

        function magno = getMagnoRAW(this)
            %GETMAGNORAW  Accessor of the motion channel of the retina (models peripheral vision)
            %
            %     magno = obj.getMagnoRAW()
            %
            % ## Output
            % * __magno__ the output buffer, format can be:
            %   * a matrix, this output is rescaled for standard 8bits image
            %     processing use in OpenCV
            %   * RAW methods actually return a 1D matrix (encoding is
            %     `M1, M2, ..., Mn`), this output is the original retina filter
            %     model output, without any quantification or rescaling.
            %
            % Warning, `getMagnoRAW` methods return buffers that are not
            % rescaled within range [0;255] while the non RAW method allows a
            % normalized matrix to be retrieved.
            %
            % See also: cv.Retina.getMagno
            %
            magno = Retina_(this.id, 'getMagnoRAW');
        end

        function setColorSaturation(this, varargin)
            %SETCOLORSATURATION  Activate color saturation as the final step of the color demultiplexing process
            %
            %     obj.setColorSaturation('OptionName',optionValue, ...)
            %
            % ## Options
            % * __SaturateColors__ boolean that activates color saturation (if
            %   true) or desactivate (if false). default true
            % * __ColorSaturationValue__ the saturation factor: a simple
            %   factor applied on the chrominance buffers. default 4.0
            %
            % This saturation is a sigmoide function applied to each channel
            % of the demultiplexed image.
            %
            % See also: cv.Retina.run
            %
            Retina_(this.id, 'setColorSaturation', varargin{:});
        end

        function clearBuffers(this)
            %CLEARBUFFERS  Clears all retina buffers
            %
            %     obj.clearBuffers()
            %
            % (equivalent to opening the eyes after a long period of eye
            % close) whatchout the temporal transition occuring just after
            % this method call.
            %
            % See also: cv.Retina.run
            %
            Retina_(this.id, 'clearBuffers');
        end

        function activateMovingContoursProcessing(this, activate)
            %ACTIVATEMOVINGCONTOURSPROCESSING  Activate/desactivate the Magnocellular pathway processing (motion information extraction)
            %
            %     obj.activateMovingContoursProcessing(activate)
            %
            % ## Input
            % * __activate__ true if Magnocellular output should be activated,
            %   false if not. If activated, the Magnocellular output can be
            %   retrieved using the cv.Retina.getMagno method.
            %
            % By default, it is activated.
            %
            % See also: cv.Retina.activateContoursProcessing
            %
            Retina_(this.id, 'activateMovingContoursProcessing', activate);
        end

        function activateContoursProcessing(this, activate)
            %ACTIVATECONTOURSPROCESSING  Activate/desactivate the Parvocellular pathway processing (contours information extraction)
            %
            %     obj.activateContoursProcessing(activate)
            %
            % ## Input
            % * __activate__ true if Parvocellular (contours information
            %   extraction) output should be activated, false if not. If
            %   activated, the Parvocellular output can be retrieved using the
            %   cv.Retina.getParvo method.
            %
            % By default, it is activated.
            %
            % See also: cv.Retina.activateMovingContoursProcessing
            %
            Retina_(this.id, 'activateContoursProcessing', activate);
        end
    end

end
