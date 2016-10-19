%% OpenEXR images HDR Retina tone mapping demo
% High Dynamic Range retina tone mapping with the help of the Gipsa/Listic's
% retina.
%
% Retina demonstration for High Dynamic Range compression (tone-mapping):
% demonstrates the use of wrapper class of the Gipsa/Listic Labs retina model.
%
% This retina model allows spatio-temporal image processing (applied on a
% still image).
%
% This demo focuses demonstration of the dynamic compression capabilities of
% the model. The main application is tone mapping of HDR images (i.e. see on a
% 8bit display a more than 8bits coded (up to 16bits) image with details in
% high and low luminance ranges.
%
% The retina model still have the following properties:
%
% * It applies a spectral whithening (mid-frequency details enhancement)
% * high frequency spatio-temporal noise reduction
% * low frequency luminance to be reduced (luminance range compression)
% * local logarithmic luminance compression allows details to be enhanced in
%   low light conditions
%
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/bioinspired/samples/cpp/OpenEXRimages_HDR_Retina_toneMapping.cpp>
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/bioinspired/samples/cpp/OpenEXRimages_HDR_Retina_toneMapping_video.cpp>
%

function varargout = retina_hdr_tonemapping_demo_gui()
    % options structure
    opts = struct();
    opts.fname = fullfile(mexopencv.root(),'test','memorial.hdr');
    opts.useLogSampling = false;               % retina log sampling processing
    opts.fastMethod = false;                   % fast method (no spectral whithning), adaptation of Meylan&al 2008 method
    opts.histogramClippingValue = 0;           % histogram edges clipping limit
    opts.colorSaturationFactor = 3;            % Color saturation
    opts.retinaHcellsGain = 40;                % Hcells gain
    opts.localAdaptation_photoreceptors = 197; % Ph sensitivity
    opts.localAdaptation_Gcells = 190;         % Gcells sensitivity

    % load HDR image, and create retina object
    [inputImage, gammaTransformedImage] = loadImage(opts);
    sz = [size(inputImage,2) size(inputImage,1)];
    retina = createRetina(sz, opts);

    % create the UI, and trigger default start
    h = buildGUI(inputImage, retina, opts);
    set(h.img(1), 'CData',inputImage)
    set(h.img(2), 'CData',gammaTransformedImage)
    onChange([], [], h, retina, opts);
    drawnow

    if nargout > 1, varargout{1} = h; end
    if nargout > 2, varargout{2} = retina; end
end

function [inputImage, gammaTransformedImage] = loadImage(opts)
    %LOADIMAGE  load HDR image

    % load retina input image
    inputImage = cv.imread(opts.fname, 'Flags',-1);
    assert(~isempty(inputImage), 'could not load image');
    fprintf('=> image size (w,h) = %d,%d\n', ...
        size(inputImage,2), size(inputImage,1));

    % rescale between 0 and 1
    inputImage = cv.normalize(inputImage, ...
        'Alpha',0, 'Beta',1, 'NormType','MinMax');

    % apply gamma curve
    gammaTransformedImage = inputImage .^ (1/5);
end

function retina = createRetina(sz, opts)
    %CREATERETINA  create retina instance

    if ~opts.useLogSampling
        % allocate "classical" retina
        props = {};
    else
        % activate log sampling
        % (favour foveal vision and subsamples peripheral vision)
        props = {'UseRetinaLogSampling',true, 'ReductionFactor',2.0};
    end

    %TODO
    if false && opts.fastMethod
        % create a fast retina tone mapper (Meyla&al algorithm)
        retina = cv.RetinaFastToneMapping(sz);
        retina.setup(...
            'PhotoreceptorsNeighborhoodRadius',3, ...
            'GanglioncellsNeighborhoodRadius',1.5, ...
            'MeanLuminanceModulatorK',1);
    else
        % create a retina instance with default parameters setup
        retina = cv.Retina(sz, props{:});

        % desactivate Magnocellular pathway processing
        % (motion information extraction) since it is not usefull here
        retina.activateMovingContoursProcessing(false);
    end
end

function outputMat = rescaleGrayLevelMat(inputMat, histClipLimit)
    %RESCALEGRAYLEVELMAT  get the gray level map of the input image and rescale it to the range [0-255]

    % adjust output matrix wrt the input size but single channel
    disp('Input image rescaling with histogram edges cutting')
    disp('(in order to eliminate bad pixels in HDR image creation):');

    % rescale between 0-255, keeping floating point values
    outputMat = cv.normalize(inputMat, ...
        'Alpha',0, 'Beta',255, 'NormType','MinMax');

    % extract a 8bit image that will be used for histogram edge cut
    if size(outputMat,3) == 1
        intGrayImage = uint8(outputMat);
    else
        intGrayImage = cv.cvtColor(uint8(outputMat), 'RGB2GRAY');
    end

    % get histogram density probability in order to cut values under/above
    % edges limits (here 5-95%)... usefull for HDR pixel errors cancellation
    histSize = 256;
    hist = cv.calcHist(intGrayImage, linspace(0,255,histSize));
    % normalize histogram so that its sum equals 1
    hist = cv.normalize(hist, ...
        'Alpha',1, 'Beta',0, 'NormType','L1', 'DType','single');

    % compute density probability
    denseProb = cumsum(hist);
    histLowerLimit = find(denseProb >= histClipLimit, 1, 'first');
    histUpperLimit = find(denseProb >= (1-histClipLimit), 1, 'first');

    % deduce min and max admitted gray levels
    minInputValue = histLowerLimit/histSize*255;
    maxInputValue = histUpperLimit/histSize*255;
    if true
        disp('=> Histogram limits')
        fprintf('\t%g%% index = %d\n', histClipLimit*100, histLowerLimit);
        fprintf('\t\tnormalizedHist value = %g\n', denseProb(histLowerLimit));
        fprintf('\t\tinput gray level = %g\n', minInputValue);
        fprintf('\t%g%% index = %d\n', (1-histClipLimit)*100, histUpperLimit);
        fprintf('\t\tnormalizedHist value = %g\n', denseProb(histUpperLimit));
        fprintf('\t\tinput gray level = %g\n', maxInputValue);
        %drawPlot(hist, histLowerLimit, histUpperLimit)
    end

    % rescale image range [minInputValue-maxInputValue] to [0-255]
    outputMat = outputMat - minInputValue;
    outputMat = outputMat * 255.0/(maxInputValue-minInputValue);
    % cut original histogram and back project to original image
    outputMat = cv.threshold(outputMat, 255, ...
        'MaxValue',255, 'Type','Trunc');   % clips values above 255
    outputMat = cv.threshold(outputMat, 0, ...
        'MaxValue',0, 'Type','ToZero');    % clips values under 0

    outputMat = cv.normalize(outputMat, ...
        'Alpha',0, 'Beta',255, 'NormType','MinMax');
end

function curveImg = drawPlot(curve, lowerLimit, upperLimit)
    %DRAWPLOT  simple procedure for 1D curve tracing

    curveImg = 255 * ones([200 size(curve,1)], 'uint8');  % white background
    curveNormalized = cv.normalize(curveImg, ...
        'Alpha',0, 'Beta',200, 'NormType','MinMax', 'DType','single');

    binW = round(size(curveImg,2) / size(curve,1));
    for i=1:size(curve,1)
        curveImg = cv.rectangle(curveImg, ...
            [(i-1)*binW, size(curveImg,1)], ...
            [i*binW, size(curveImg,1) - round(curveNormalized(i))], ...
            'Color',[0 0 0], 'Thickness','Filled');
    end
    curveImg = cv.rectangle(curveImg, ...
        [0, 0], [lowerLimit*binW, 200], ...
        'Color',[128 128 128], 'Thickness','Filled');
    curveImg = cv.rectangle(curveImg, ...
        [size(curveImg,2), 0], [upperLimit*binW, 200], ...
        'Color',[128 128 128], 'Thickness','Filled');
end

function onType(~, e, h, retina, opts)
    %ONTYPE  Event handler for key press on figure

    % handle keys
    switch e.Key
        case {'q', 'escape'}
            disp('Exiting ...')
            close(h.fig)

        case 'h'
            helpdlg({
                'Hot keys:'
                'ESC - quit the program'
                'h - this help dialog'
                'c - clear all retina buffers (open your eyes)'
            });

        case 'c'
            retina.clearBuffers();
            onChange([], [], h, retina, opts);
    end
end

function onChange(~, ~, h, retina, opts)
    %ONCHANGE  Event handler for UI controls

    % retrieve current values from UI controls
    opts.histogramClippingValue         = round(get(h.slid(1), 'Value'));
    opts.colorSaturationFactor          = round(get(h.slid(2), 'Value'));
    opts.retinaHcellsGain               = round(get(h.slid(3), 'Value'));
    opts.localAdaptation_photoreceptors = round(get(h.slid(4), 'Value'));
    opts.localAdaptation_Gcells         = round(get(h.slid(5), 'Value'));
    set(h.txt(1), 'String',sprintf('hist edges clip limit: %3d', opts.histogramClippingValue));
    set(h.txt(2), 'String',sprintf('Color saturation: %3d',      opts.colorSaturationFactor));
    set(h.txt(3), 'String',sprintf('Hcells gain: %3d',           opts.retinaHcellsGain));
    set(h.txt(4), 'String',sprintf('Ph sensitivity: %3d',        opts.localAdaptation_photoreceptors));
    set(h.txt(5), 'String',sprintf('Gcells sensitivity: %3d',    opts.localAdaptation_Gcells));

    % apply new parameters
    imgRescaled = rescaleGrayLevelMat(h.src, ...
        opts.histogramClippingValue/100);
    retina.setColorSaturation('SaturateColors',true, ...
        'ColorSaturationValue',opts.colorSaturationFactor);
    retina.setupOPLandIPLParvoChannel(...
        'PhotoreceptorsLocalAdaptationSensitivity',opts.localAdaptation_photoreceptors/200, ...
        'PhotoreceptorsSpatialConstant',0.43, ...
        'HorizontalCellsGain',opts.retinaHcellsGain, ...
        'GanglionCellsSensitivity',opts.localAdaptation_Gcells/200);

    % run retina filter
    if ~opts.fastMethod
        % run and retrieve retina output
        retina.run(imgRescaled);
        out = retina.getParvo();
    else
        % apply the simplified hdr tone mapping method
        out = retina.applyFastToneMapping(imgRescaled);
    end

    % display results
    set(h.img(3), 'CData',imgRescaled./255)
    set(h.img(4), 'CData',out)
    drawnow
end

function h = buildGUI(img, retina, opts)
    %BUILDGUI  Creates the UI

    % fit to screen
    sz = [size(img,1) size(img,2)];
    ss = get(0, 'ScreenSize');
    sz = min([ss(4)-190 ss(3)./4] ./ sz) .* sz;

    % store input image
    h = struct();
    h.src = img;

    % build the user interface (no resizing to keep it simple)
    h.fig = figure('Name','Retina HDR Tonemapping Demo', ...
        'NumberTitle','off', 'Menubar','none', 'Resize','off', ...
        'Position',[200 200 sz(2)*4 sz(1)+105+20+5+35-1]);
    if ~mexopencv.isOctave()
        %HACK: not implemented in Octave
        movegui(h.fig, 'center');
    end
    titles = {
        {'EXR original', '(linear rescaling)'}
        {'EXR w/ basic processing', '(gamma correction)'}
        {'Retina input', '(w/ clipped histogram)'}
    };
    if ~opts.fastMethod
        titles{4} = {'Retina tonemapping output', 'Parvocellular pathway'};
    else
        titles{4} = {'Retina tonemapping output', 'fast tone mapping'};
    end
    for i=1:4
        h.ax(i) = axes('Parent',h.fig, 'Units','pixels', ...
            'Position',[sz(2)*(i-1)+1 105+20+5 sz(2) sz(1)]);
        if ~mexopencv.isOctave()
            h.img(i) = imshow(img, 'Parent',h.ax(i));
        else
            %HACK: https://savannah.gnu.org/bugs/index.php?45473
            axes(h.ax(i)); h.img(i) = imshow(img);
        end
        title(titles{i}, 'FontSize',10)
    end
    props = {'FontSize',11, 'HorizontalAlignment','right'};
    h.txt(1) = uicontrol('Parent',h.fig, 'Style','text', props{:}, ...
        'Position',[5 5 170 20], ...
        'String',sprintf('hist edges clip limit: %3d', opts.histogramClippingValue));
    h.txt(2) = uicontrol('Parent',h.fig, 'Style','text', props{:}, ...
        'Position',[5 30 170 20], ...
        'String',sprintf('Color saturation: %3d', opts.colorSaturationFactor));
    h.txt(3) = uicontrol('Parent',h.fig, 'Style','text', props{:}, ...
        'Position',[5 55 170 20], ...
        'String',sprintf('Hcells gain: %3d', opts.retinaHcellsGain));
    h.txt(4) = uicontrol('Parent',h.fig, 'Style','text', props{:}, ...
        'Position',[5 80 170 20], ...
        'String',sprintf('Ph sensitivity: %3d', opts.localAdaptation_photoreceptors));
    h.txt(5) = uicontrol('Parent',h.fig, 'Style','text', props{:}, ...
        'Position',[5 105 170 20], ...
        'String',sprintf('Gcells sensitivity: %3d', opts.localAdaptation_Gcells));
    h.slid(1) = uicontrol('Parent',h.fig, 'Style','slider', ...
        'Value',opts.histogramClippingValue, 'Min',0, 'Max',50, 'SliderStep',[1 10]./(50-0), ...
        'Position',[175 5 sz(2)*4-175-20 20]);
    h.slid(2) = uicontrol('Parent',h.fig, 'Style','slider', ...
        'Value',opts.colorSaturationFactor, 'Min',0, 'Max',5, 'SliderStep',[1 10]./(5-0), ...
        'Position',[175 30 sz(2)*4-175-20 20]);
    h.slid(3) = uicontrol('Parent',h.fig, 'Style','slider', ...
        'Value',opts.retinaHcellsGain, 'Min',0, 'Max',100, 'SliderStep',[1 10]./(100-0), ...
        'Position',[175 55 sz(2)*4-175-20 20]);
    h.slid(4) = uicontrol('Parent',h.fig, 'Style','slider', ...
        'Value',opts.localAdaptation_photoreceptors, 'Min',0, 'Max',200, 'SliderStep',[1 10]./(200-0), ...
        'Position',[175 80 sz(2)*4-175-20 20]);
    h.slid(5) = uicontrol('Parent',h.fig, 'Style','slider', ...
        'Value',opts.localAdaptation_Gcells, 'Min',0, 'Max',200, 'SliderStep',[1 10]./(200-0), ...
        'Position',[175 105 sz(2)*4-175-20 20]);

    % hook event handlers
    props = {'Interruptible','off', 'BusyAction','cancel'};
    set(h.fig, 'WindowKeyPressFcn',{@onType, h, retina, opts}, props{:});
    set(h.slid, 'Callback',{@onChange, h, retina, opts}, props{:});
end
