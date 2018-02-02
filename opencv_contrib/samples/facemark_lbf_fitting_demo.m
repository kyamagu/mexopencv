%% Face landmark detection in a video (LBF)
%
% This demos lets you detect landmarks of detected faces in a video. It first
% detects faces in a current video frame and then finds their facial landmarks.
%
% Sources:
%
% * <https://github.com/opencv/opencv_contrib/blob/3.4.0/modules/face/samples/facemark_lbf_fitting.cpp>
%

%% Options

% [INPUT] path to input video
if true
    vid = fullfile(mexopencv.root(),'test','dudek.webm');
else
    vid = 0;
end

% [INPUT] path to the trained model to load
modelFile = fullfile(mexopencv.root(),'test','lbfmodel.yaml');
if exist(modelFile, 'file') ~= 2
    % download model from GitHub
    disp('Downloading model (~ 54MB)...')
    url = 'https://github.com/kurnianggoro/GSOC2017/raw/master/data/lbfmodel.yaml';
    urlwrite(url, modelFile);
end

% [INPUT] path to the cascade xml file for the face detector
xmlFace = fullfile(mexopencv.root(),'test','lbpcascade_frontalface.xml');
download_classifier_xml(xmlFace);

% name of user-defined face detector function
faceDetectFcn = 'myFaceDetector';
assert(exist([faceDetectFcn '.m'], 'file') == 2, 'missing face detect function');

%% Init
% create instance of the face landmark detection class,
% and set the face detector function, then load the pre-trained model
if true
    obj = cv.Facemark('LBF');
    obj.setFaceDetector(faceDetectFcn);
else
    obj = cv.Facemark('LBF', 'CascadeFace',xmlFace);
end
obj.loadModel(modelFile);

%% Video
% open video, and prepare figure
cap = cv.VideoCapture(vid);
assert(cap.isOpened(), 'Failed to load video');
img = cap.read();
assert(~isempty(img), 'Failed to read frame');
hImg = imshow(img);

%% Detect
% main loop
counter = 0;
tID = tic();
while ishghandle(hImg)
    % read frame
    img = cap.read();
    if isempty(img), break; end

    % scale frame
    scale = 400 / size(img,2);
    imgS = cv.resize(img, fix(scale * [size(img,2) size(img,1)]));

    % detect faces
    rects = obj.getFaces(imgS);
    rects = cellfun(@(r) fix(r/scale), rects, 'Uniform',false);

    % detect and display face landmarks
    if ~isempty(rects)
        img = cv.rectangle(img, rects, 'Color',[0 255 0]);
        landmarks = obj.fit(img, rects);
        for i=1:numel(landmarks)
            img = cv.Facemark.drawFacemarks(img, landmarks{i}, 'Color',[0 0 255]);
        end
    end

    % show FPS
    counter = counter + 1;
    fps = counter/toc(tID);
    txt = sprintf('faces: %d, fps: %03.2f', numel(rects), fps);
    img = cv.putText(img, txt, [20 40], ...
        'FontFace','HersheyPlain', 'FontScale',2, ...
        'Thickness',2, 'Color',[255 255 255]);

    % show frame + results
    set(hImg, 'CData',img)
    drawnow
end
cap.release();

%% Helper function

function download_classifier_xml(fname)
    if exist(fname, 'file') ~= 2
        % attempt to download trained Haar/LBP/HOG classifier from Github
        url = 'https://cdn.rawgit.com/opencv/opencv/3.4.0/data/';
        [~, f, ext] = fileparts(fname);
        if strncmpi(f, 'haarcascade_', length('haarcascade_'))
            url = [url, 'haarcascades/'];
        elseif strncmpi(f, 'lbpcascade_', length('lbpcascade_'))
            url = [url, 'lbpcascades/'];
        elseif strncmpi(f, 'hogcascade_', length('hogcascade_'))
            url = [url, 'hogcascades/'];
        else
            error('File not found');
        end
        urlwrite([url f ext], fname);
    end
end

% The facemark API provides the functionality to the user to use their own
% face detector. The code below implements a sample face detector. This
% function must be saved in its own M-function to be used by the facemark API.
function faces = myFaceDetector(img)
    persistent obj
    if isempty(obj)
        obj = cv.CascadeClassifier();
        obj.load(xmlFace);
    end

    if size(img,3) > 1
        gray = cv.cvtColor(img, 'RGB2GRAY');
    else
        gray = img;
    end
    gray = cv.equalizeHist(gray);
    faces = obj.detect(gray, 'ScaleFactor',1.4, 'MinNeighbors',2, ...
        'ScaleImage',true, 'MinSize',[30 30]);
end
