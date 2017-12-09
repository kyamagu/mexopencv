%% DNN: Face Detection
% Face detector based on SSD framework (Single Shot MultiBox Detector),
% using a reduced ResNet-10 model.
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/resnet_ssd_face_python.py>
%

%%
% import network
[net, blobOpts] = ResNetSSD_FaceDetector();
assert(~net.empty());

%%
% minimum confidence threshold of detections to show
confThreshold = 0.5;

%%
% prepare video input
cap = cv.VideoCapture();
pause(1);
assert(cap.isOpened());

%%
% prepare figure
frame = cap.read();
assert(~isempty(frame));
hImg = imshow(frame);
sz = [size(frame,2) size(frame,1)];

%%
% video feed
while ishghandle(hImg)
    % read frame
    frame = cap.read();
    if isempty(frame), break; end

    % detect faces
    net.setInput(cv.Net.blobFromImages(flip(frame,3), blobOpts{:}));
    detections = net.forward();  % SSD output is 1-by-1-by-ndetections-by-7
    detections = permute(detections, [3 4 2 1]);

    % draw detections
    for i=1:size(detections,1)
        % only strong detections
        d = detections(i,:);
        if d(2) == 1 && d(3) > confThreshold  % 0: background, 1: face
            % plot bounding boxes (coordinates are relative to image size)
            frame = cv.rectangle(frame, d(4:5).*sz, d(6:7).*sz, ...
                'Color',[0 255 0], 'Thickness',2);
            frame = cv.putText(frame, sprintf('conf = %3.0f%%', d(3)*100), ...
                d(4:5).*sz - [0 4], 'Color',[255 0 0], 'FontScale',0.5);
        end
    end

    % show inference timing
    [~,t] = net.getPerfProfile();
    t = double(t) / cv.TickMeter.getTickFrequency();
    frame = cv.putText(frame, sprintf('time = %g sec', t), [10 20], ...
        'Color',[255 255 0], 'FontScale',0.5);

    % update plot
    set(hImg, 'CData',frame);
    drawnow;
end
cap.release();

%%
% Helper function

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

function [net, blobOpts] = ResNetSSD_FaceDetector()
    %RESNETSSD_FACEDETECTOR  face detector based on SSD framework with reduced ResNet-10 backbone
    %
    % homepage = https://github.com/opencv/opencv/blob/3.3.1/samples/dnn/face_detector/how_to_train_face_detector.txt
    %
    % ## Model
    %
    % file = test/dnn/ResNetSSD_FaceDetector/deploy.prototxt
    % url  = https://github.com/opencv/opencv/raw/3.3.1/samples/dnn/face_detector/deploy.prototxt
    % hash = 5fd52177a483cbac12fd61e9ecd87c762829ecbe
    %
    % ## Weights
    %
    % file = test/dnn/ResNetSSD_FaceDetector/res10_300x300_ssd_iter_140000.caffemodel
    % url  = https://github.com/opencv/opencv_3rdparty/raw/dnn_samples_face_detector_20170830/res10_300x300_ssd_iter_140000.caffemodel
    % hash = 15aa726b4d46d9f023526d85537db81cbc8dd566
    % size = 10.1 MB
    %

    dname = get_dnn_dir('ResNetSSD_FaceDetector');
    net = cv.Net('Caffe', ...
        fullfile(dname, 'deploy.prototxt'), ...
        fullfile(dname, 'res10_300x300_ssd_iter_140000.caffemodel'));
    blobOpts = {'SwapRB',false, 'Crop',false, 'Size',[300 300], 'Mean',[104 117 123]};
end
