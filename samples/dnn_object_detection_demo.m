%% DNN Object Detection
%
% This sample uses Single-Shot Detector (SSD) or You Only Look Once (YOLO) to
% detect objects on image (produces bounding boxes and corresponding labels).
%
% * <https://arxiv.org/abs/1311.2524 R-CNN>
% * <https://arxiv.org/abs/1504.08083 Fast R-CNN>
% * <https://arxiv.org/abs/1506.01497 Faster R-CNN>
% * <https://arxiv.org/abs/1512.02325 SSD>
% * <https://arxiv.org/abs/1506.02640 YOLO>
% * <https://arxiv.org/abs/1612.08242 YOLOv2>
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/ssd_object_detection.cpp>
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/ssd_mobilenet_object_detection.cpp>
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/mobilenet_ssd_python.py>
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/mobilenet_ssd_accuracy.py>
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/yolo_object_detection.cpp>
%

function dnn_object_detection_demo(im, name, crop, min_conf)
    % input image (BGR channel order)
    if nargin < 1 || isempty(im)
        im = fullfile(mexopencv.root(), 'test', 'rgb.jpg');
    end
    img = cv.imread(im, 'Color',true, 'FlipChannels',false);

    % import pretrained model
    if nargin < 2, name = 'MobileNetSSD'; end
    fprintf('Load model...   '); tic;
    switch lower(name)
        case 'vggnetssd'
            % PASCAL VOC or ImageNet ILSVRC 2016
            [net, labels, blobOpts] = VGGNetSSD('VOC');
        case 'mobilenetssd'
            % PASCAL VOC or Microsoft COCO
            [net, labels, blobOpts] = MobileNetSSD('VOC');
        case 'yolo'
            % PASCAL VOC or Microsoft COCO
            [net, labels, blobOpts] = YOLO('VOC', true);
        otherwise
            error('Unrecognized model %s', name)
    end
    toc;
    assert(~net.empty(), 'Failed to read network %s', name);

    % feed image to network
    if nargin < 3, crop = false; end
    blobOpts = ['Crop',crop, blobOpts];
    opts = parseBlobOpts(blobOpts{:});
    blob = cv.Net.blobFromImages(img, blobOpts{:});
    net.setInput(blob);

    % run forward pass
    fprintf('Forward pass... '); tic;
    detections = net.forward();
    toc;

    % prepare output image
    if opts.Crop
        % center cropped as fed to network
        out = cropImage(img, opts);
    else
        if false
            % resized image (squashed) as fed to network
            out = imageFromBlob(blob, opts);
        else
            % unmodified original image
            out = img;
        end
    end
    out = flip(out, 3);  % BGR to RGB

    % build detections struct (adjust relative bounding boxes to image size)
    detections = processOutput(detections, name, [size(out,2) size(out,1)]);

    % filter-out weak detections according to a minimum confidence threshold
    if nargin < 4, min_conf = 0.2; end
    detections = detections([detections.confidence] >= min_conf);

    % localization: show bounding boxes
    for i=1:numel(detections)
        d = detections(i);
        idx = find([labels.id] == d.class_id, 1, 'first');
        if isempty(idx), continue; end
        out = insertAnnotation(out, d.rect, ...
            sprintf('%s: %.2f', labels(idx).name, d.confidence), ...
            'Color',labels(idx).color, 'TextColor',[255 255 255], ...
            'Thickness',2, 'FontScale',0.3);
        fprintf('Image %d: (%3.0f%%) %11s at [%3d %3d %3d %3d]\n', ...
            d.img_id, d.confidence*100, labels(idx).name, d.rect);
    end
    imshow(out), title('Object Detection')
end

% --- Helper functions ---

function dname = get_dnn_dir(dname)
    %GET_DNN_DIR  Path to model files, and show where to get them if missing

    dname = fullfile(mexopencv.root(), 'test', 'dnn', dname);
    b = isdir(dname);
    if ~b
        % display help of calling function
        % (assumed to be a local function in current file)
        st = dbstack(1);
        help([mfilename() filemarker() st(1).name])
    end
    assert(b, 'Missing model: %s', dname);
end

function labels = readLabelsColors(labelsFile, addBG)
    if nargin < 2, addBG = false; end
    fid = fopen(labelsFile, 'rt');
    C = textscan(fid, '%s %d %d %d', 'CollectOutput',true);
    fclose(fid);
    name = C{1};
    color = uint8(C{2});
    if addBG
        name = ['background'; name];
        color = [0 0 0; color];
    end
    id = 0:(numel(name) - 1);  % first label 0 corresponds to background
    labels = struct('id',num2cell(id(:),2), 'name',name, 'color',num2cell(color,2));
end

function labels = readLabels(labelsFile, addBG)
    if nargin < 2, addBG = true; end
    fid = fopen(labelsFile, 'rt');
    C = textscan(fid, '%s');
    fclose(fid);
    name = C{1};
    if addBG
        name = ['background'; name];
    end
    id = 0:(numel(name) - 1);  % first label 0 corresponds to background
    color = uint8([0 0 0; 255 * lines(numel(name)-1)]);
    labels = struct('id',num2cell(id(:),2), 'name',name, 'color',num2cell(color,2));
end

function labels = readLabelsProtoTxt(labelsFile, addBG)
    if nargin < 2, addBG = true; end
    % item {
    %  name: "abc"
    %  label: 123  OR  id: 123
    %  display_name: "xyz"
    % }
    fid = fopen(labelsFile, 'rt');
    C = textscan(fid, '%*s %*c\n %*s %*q\n %*s %d\n %*s %q\n %*c');
    fclose(fid);
    id = C{1};
    name = C{2};
    if addBG
        id = [0; id];
        name = ['background'; name];
    end
    color = uint8([0 0 0; 255 * lines(numel(name)-1)]);
    labels = struct('id',num2cell(id,2), 'name',name, 'color',num2cell(color,2));
    [~,ord] = sort(id);
    labels = labels(ord);
end

function opts = parseBlobOpts(varargin)
    p = inputParser();
    p.addParameter('ScaleFactor', 1.0);
    p.addParameter('Size', [0 0]);   % [w,h]
    p.addParameter('Mean', [0 0 0]); % [r,g,b]
    p.addParameter('SwapRB', true);
    p.addParameter('Crop', true);
    p.parse(varargin{:});
    opts = p.Results;
end

function img = imageFromBlob(blob, opts)
    img = permute(blob, [3 4 2 1]); % NCHW -> HWCN
    img = img / opts.ScaleFactor;
    if false && opts.SwapRB
        opts.Mean([1 3]) = opts.Mean([3 1]);
    end
    img = bsxfun(@plus, img, reshape(opts.Mean, 1, 1, []));
    img = uint8(round(img));
end

function img = cropImage(img, opts)
    % https://github.com/opencv/opencv/blob/3.3.1/modules/dnn/src/dnn.cpp#L95-L176
    imgSz = [size(img,2) size(img,1)];
    if ~isequal(imgSz, opts.Size)
        if opts.Crop
            % resize (preserving aspect-ratio) with center-cropping
            sf = max(opts.Size ./ imgSz);
            img = cv.resize(img, sf, sf);
            imgSz = [size(img,2) size(img,1)];
            r = [fix((imgSz - opts.Size)/2) opts.Size];
            img = cv.Rect.crop(img, r);
        else
            % direct resize (stretched) without cropping
            img = cv.resize(img, opts.Size);
        end
    end
end

function detections = processOutput(output, name, sz)
    isYOLO = strcmpi(name, 'yolo');
    if isYOLO
        % YOLO output is already ndetections-by-25-by-1-by-1
        % (20+5 for VOC, 80+5 for COCO)
    else
        % SSD output is 1-by-1-by-ndetections-by-7
        output = permute(output, [3 4 2 1]);
    end
    num = size(output,1);

    % note: bounding boxes returned are percentages relative to image size
    detections = struct('img_id',[], 'class_id',[], 'confidence',[], 'rect',[]);
    detections = repmat(detections, num, 1);
    for i=1:num
        if isYOLO
            % (center_x, center_y, width, height, unused_t0, probability_for_each_class[20])
            rrect = struct('center',output(i,1:2) .* sz, ...
                'size',output(i,3:4) .* sz, 'angle',0);
            detections(i).rect = cv.RotatedRect.boundingRect(rrect);
            [detections(i).confidence, detections(i).class_id] = max(output(i,6:end));
            detections(i).img_id = 0;
        else
            % (img_id, class_id, confidence, xLeftBottom, yLeftBottom, xRightTop, yRightTop)
            detections(i).img_id = output(i,1);
            detections(i).class_id = output(i,2);
            detections(i).confidence = output(i,3);
            detections(i).rect = round(cv.Rect.from2points(...
                output(i,4:5) .* sz, output(i,6:7) .* sz));
        end
    end
end

function img = insertAnnotation(img, rect, str, varargin)
    % See also: insertObjectAnnotation, insertShape, insertText
    p = inputParser();
    p.addParameter('Alpha', 0.6);
    p.addParameter('Thickness', 1);
    p.addParameter('Color', [255 255 0]);
    p.addParameter('TextColor', [0 0 0]);
    p.addParameter('FontFace', 'HersheySimplex');
    p.addParameter('FontScale', 0.4);
    p.addParameter('AntiAlias', true);
    p.addParameter('Shape', 'rectangle');
    p.parse(varargin{:});
    opts = p.Results;
    opts.Shape = validatestring(opts.Shape, {'rectangle','circle'});
    thick = 1;

    [sz,b] = cv.getTextSize(str, 'Thickness',thick, ...
        'FontFace',opts.FontFace, 'FontScale',opts.FontScale);
    txt_rect = [rect(1), rect(2)-sz(2)-b, sz(1), sz(2)+b];
    txt_orig = [rect(1), rect(2)-b];

    if opts.AntiAlias
        alias = {'LineType','AA'};
    else
        alias = {'LineType',8};
    end

    overlay = img;
    if strcmp(opts.Shape, 'rectangle')
        overlay = cv.rectangle(overlay, rect, ...
            'Color',opts.Color, 'Thickness',opts.Thickness, alias{:});
    else
        c = rect(1:2) + rect(3:4)/2;
        r = max(rect(3:4)/2);
        overlay = cv.circle(overlay, c, r, ...
            'Color',opts.Color, 'Thickness',opts.Thickness, alias{:});
    end
    overlay = cv.rectangle(overlay, txt_rect, ...
        'Color',opts.Color, 'Thickness','Filled', alias{:});
    if opts.Thickness > 1
        overlay = cv.rectangle(overlay, txt_rect, ...
            'Color',opts.Color, 'Thickness',opts.Thickness, alias{:});
    end
    overlay = cv.putText(overlay, str, txt_orig, ...
        'FontFace',opts.FontFace, 'FontScale',opts.FontScale, ...
        'Color',opts.TextColor, 'Thickness',thick, alias{:});

    img = cv.addWeighted(img,1-opts.Alpha, overlay,opts.Alpha, 0);
end

% --- Pretrained models ---
% See also: https://github.com/opencv/opencv_extra/blob/3.3.1/testdata/dnn/download_models.py

function [net, labels, blobOpts] = VGGNetSSD(imageset)
    %VGGNETSSD  Single Shot MultiBox Detector, VGGNet-SSD
    %
    % homepage = https://github.com/weiliu89/caffe/tree/ssd
    %
    % # SSD300 (VGG16) PASCAL VOC 07+12 [Caffe]
    %
    % ## Model + Weights
    %
    % file = test/dnn/VGGNetSSD/VOC/deploy.prototxt
    % file = test/dnn/VGGNetSSD/VOC/VGG_VOC0712_SSD_300x300_iter_120000.caffemodel
    % url  = https://drive.google.com/open?id=0BzKzrI_SkD1_WVVTSmQxU0dVRzA
    % hash = 3ba17aa493f045cd5e7452b93f159a383635b614
    % size = 93.0 MB
    %
    % ## Classes
    %
    % file = test/dnn/VGGNetSSD/VOC/pascal-classes.txt
    % url  = https://github.com/opencv/opencv/raw/3.3.1/samples/data/dnn/pascal-classes.txt
    %
    % # SSD300 (VGG16) ILSVRC 2016 [Caffe]
    %
    % ## Model + Weights
    %
    % file = test/dnn/VGGNetSSD/ILSVRC/deploy.prototxt
    % file = test/dnn/VGGNetSSD/ILSVRC/VGG_ILSVRC2016_SSD_300x300_iter_440000.caffemodel
    % url  = https://drive.google.com/open?id=0BzKzrI_SkD1_a2NKQ2d1d043VXM
    % hash = f77a8cac14e73a6b053fea51521ecea418ef2bf1
    % size = 178 MB
    %
    % ## Classes
    %
    % file = test/dnn/VGGNetSSD/ILSVRC/labelmap_ilsvrc_det.prototxt
    % url  = https://github.com/weiliu89/caffe/raw/ssd/data/ILSVRC2016/labelmap_ilsvrc_det.prototxt
    % hash = 2f052e8260efb8eeca1ff6a64ce56d4e71b4a8f8
    %

    % (VOC: 20 classes, ILSVRC: 200 classes, http://image-net.org/challenges/LSVRC/2016/browse-det-synsets)
    imageset = validatestring(imageset, {'VOC', 'ILSVRC'});
    dname = get_dnn_dir(fullfile('VGGNetSSD', imageset));
    blobOpts = {'SwapRB',false, 'Size',[300 300], 'Mean',[104 117 123]};
    if strcmp(imageset, 'VOC')
        net = cv.Net('Caffe', ...
            fullfile(dname, 'deploy.prototxt'), ...
            fullfile(dname, 'VGG_VOC0712_SSD_300x300_iter_120000.caffemodel'));
        labels = readLabelsColors(fullfile(dname, 'pascal-classes.txt'), false);
    else
        net = cv.Net('Caffe', ...
            fullfile(dname, 'ssd_vgg16.prototxt'), ...
            fullfile(dname, 'VGG_ILSVRC2016_SSD_300x300_iter_440000.caffemodel'));
        labels = readLabelsProtoTxt(fullfile(dname, 'labelmap_ilsvrc_det.prototxt'), false);
    end
end

function [net, labels, blobOpts] = MobileNetSSD(imageset)
    %MOBILENETSSD  Single-Shot Detector, MobileNet-SSD
    %
    % # A Caffe implementation of MobileNet-SSD, PASCAL VOC 07+12 [Caffe]
    %
    % homepage = https://github.com/chuanqi305/MobileNet-SSD
    %
    % ## Model
    %
    % file = test/dnn/MobileNetSSD/MobileNetSSD_deploy.prototxt
    % url  = https://github.com/chuanqi305/MobileNet-SSD/raw/master/MobileNetSSD_deploy.prototxt
    % hash = d77c9cf09619470d49b82a9dd18704813a2043cd
    %
    % ## Weights
    %
    % file = test/dnn/MobileNetSSD/MobileNetSSD_deploy.caffemodel
    % url  = https://drive.google.com/open?id=0B3gersZ2cHIxRm5PMWRoTkdHdHc
    % hash = 994d30a8afaa9e754d17d2373b2d62a7dfbaaf7a
    % size = 22.0 MB
    %
    % ## Classes
    %
    % file = test/dnn/MobileNetSSD/pascal-classes.txt
    % url  = https://github.com/opencv/opencv/raw/3.3.1/samples/data/dnn/pascal-classes.txt
    %
    % # MobileNet-SSD, trained on COCO dataset [TensorFlow]
    %
    % homepage = https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md
    %
    % ## Model
    %
    % file = test/dnn/MobileNetSSD_COCO/ssd_mobilenet_v1_coco.pbtxt
    % url  = https://github.com/opencv/opencv_extra/raw/3.3.1/testdata/dnn/ssd_mobilenet_v1_coco.pbtxt
    % hash = f58916645baac2511f521332fbd574a71b8f80bf
    %
    % ## Weights
    %
    % file = test/dnn/MobileNetSSD_COCO/frozen_inference_graph.pb
    % url  = http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_coco_11_06_2017.tar.gz
    % hash = a88a18cca9fe4f9e496d73b8548bfd157ad286e2
    % size = 122 MB
    %
    % ## Classes
    %
    % file = test/dnn/MobileNetSSD_COCO/mscoco_label_map.pbtxt
    % url  = https://github.com/tensorflow/models/blob/master/research/object_detection/data/mscoco_label_map.pbtxt
    %

    % Caffe model trained on VOC (20 classes), TensorFlow trained on COCO (80 classes)
    imageset = validatestring(imageset, {'VOC', 'COCO'});
    dname = get_dnn_dir(fullfile('MobileNetSSD', imageset));
    blobOpts = {'Size',[300 300], 'Mean',[127.5 127.5 127.5], 'ScaleFactor',1/127.5};
    if strcmp(imageset, 'VOC')
        net = cv.Net('Caffe', ...
            fullfile(dname, 'MobileNetSSD_deploy.prototxt'), ...
            fullfile(dname, 'MobileNetSSD_deploy.caffemodel'));
        labels = readLabelsColors(fullfile(dname, 'pascal-classes.txt'), false);
        blobOpts = ['SwapRB',false, blobOpts];
    else
        %TODO: sometimes crashes from OpenCL execution path, workaround:
        % cv.Utils.setUseOptimized(false); net.setPreferableTarget('CPU');
        net = cv.Net('Tensorflow', ...
            fullfile(dname, 'frozen_inference_graph.pb'), ...
            fullfile(dname, 'ssd_mobilenet_v1_coco.pbtxt'));
        labels = readLabelsProtoTxt(fullfile(dname, 'mscoco_label_map.pbtxt'), true);
        blobOpts = ['SwapRB',true, blobOpts];
    end
end

function [net, labels, blobOpts] = YOLO(imageset, isTiny)
    %YOLO  You Only Look Once, YOLO v2 [Darknet]
    %
    % homepage = https://pjreddie.com/darknet/yolo/
    %
    % # Tiny YOLO (COCO)
    %
    % ## Model
    %
    % file = test/dnn/YOLO/tiny-yolo.cfg
    % url  = https://github.com/pjreddie/darknet/raw/master/cfg/tiny-yolo.cfg
    % hash = 8d281f1f80162e44d4af5d0911bfdf5667f8f20d
    %
    % ## Weights
    %
    % file = test/dnn/YOLO/tiny-yolo.weights
    % url  = https://pjreddie.com/media/files/tiny-yolo.weights
    % hash = b6c3ba64aa71af2fa78f964ce68e509ed0e75383
    % size = 42.8 MB
    %
    % # Tiny YOLO (VOC)
    %
    % ## Model
    %
    % file = test/dnn/YOLO/tiny-yolo-voc.cfg
    % url  = https://github.com/pjreddie/darknet/raw/master/cfg/tiny-yolo-voc.cfg
    % hash = d26e2408ce4e20136278411760ba904d744fe5b5
    %
    % ## Weights
    %
    % file = test/dnn/YOLO/tiny-yolo-voc.weights
    % url  = https://pjreddie.com/media/files/tiny-yolo-voc.weights
    % hash = 24b4bd049fc4fa5f5e95f684a8967e65c625dff9
    % size = 60.5 MB
    %
    % # YOLO (COCO)
    %
    % ## Model
    %
    % file = test/dnn/YOLO/yolo.cfg
    % url  = https://github.com/pjreddie/darknet/raw/master/cfg/yolo.cfg
    % hash = 6ee14a8b854ce37c55ef4f9def90303a7cb53906
    %
    % ## Weights
    %
    % file = test/dnn/YOLO/yolo.weights
    % url  = https://pjreddie.com/media/files/yolo.weights
    % hash = a2248b25c50307b4e2ba298473e05396e79df9d1
    % size = 194 MB
    %
    % # YOLO (VOC)
    %
    % ## Model
    %
    % file = test/dnn/YOLO/yolo-voc.cfg
    % url  = https://github.com/pjreddie/darknet/raw/master/cfg/yolo-voc.cfg
    % hash = 0150a4b4f018955aa98f2e38ef29ba2104ba74ea
    %
    % ## Weights
    %
    % file = test/dnn/YOLO/yolo-voc.weights
    % url  = https://pjreddie.com/media/files/yolo-voc.weights
    % hash = 1cc1a7f8ad12d563d85b76e9de025dc28ac397bb
    % size = 193 MB
    %
    % # Classes
    %
    % file = test/dnn/YOLO/coco.names
    % url  = https://github.com/pjreddie/darknet/raw/master/data/coco.names
    %
    % file = test/dnn/YOLO/voc.names
    % url  = https://github.com/pjreddie/darknet/raw/master/data/voc.names
    %

    % (VOC: 20 classes, COCO: 80 classes)
    dname = get_dnn_dir('YOLO');
    imageset = validatestring(imageset, {'VOC', 'COCO'});
    if isTiny
        prefix = 'tiny-';
    else
        prefix = '';
    end
    if strcmp(imageset, 'VOC')
        suffix = '-voc';
    else
        suffix = '';
    end
    net = cv.Net('Darknet', ...
        fullfile(dname, [prefix 'yolo' suffix '.cfg']), ...
        fullfile(dname, [prefix 'yolo' suffix '.weights']));
    labels = readLabels(fullfile(dname, [lower(imageset) '.names']), true);
    blobOpts = {'SwapRB',false, 'Size',[416 416], 'ScaleFactor',1/255};
end
