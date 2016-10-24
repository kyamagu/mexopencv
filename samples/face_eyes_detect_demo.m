%% Face and Eyes Detection demo
%
% This program demonstrates the cascade recognizer. You can use Haar
% or LBP features.
% This classifier can recognize many kinds of rigid objects, once the
% appropriate classifier is trained. It's most known use is for faces.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/facedetect.cpp>
%

%% Options

% this is the primary trained classifier such as frontal face
cascadeName = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt.xml');
% this an optional secondary classifier such as eyes
nestedCascadeName = fullfile(mexopencv.root(),'test','haarcascade_eye_tree_eyeglasses.xml');
% image scale greater or equal to 1, try 1.3 for example
scale = 1.0;
% attempts detection of flipped image as well
tryflip = false;

%% Initialize

% download XML files if missing
download_classifier_xml(cascadeName);
download_classifier_xml(nestedCascadeName);

% load cacade classifiers
cascade = cv.CascadeClassifier(cascadeName);
assert(~cascade.empty(), 'Could not load classifier cascade');
nestedCascade = cv.CascadeClassifier();
if ~nestedCascade.load(nestedCascadeName)
    disp('Could not load classifier cascade for nested objects');
end
scale = max(scale, 1.0);

%% Main loop
% (either video feed or a still image)
if false
    % read an image
    frame = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), 'Color',true);
    % detect faces/eyes and draw detections
    frame = detectAndDraw(frame, cascade, nestedCascade, scale, tryflip);
    imshow(frame);
else
    % prepare video input
    cap = cv.VideoCapture();
    pause(1);
    assert(cap.isOpened());

    % prepare figure
    frame = cap.read();
    assert(~isempty(frame));
    hImg = imshow(frame);

    % video feed
    while ishghandle(hImg)
        % read frame
        frame = cap.read();
        if isempty(frame), break; end

        % detect faces/eyes and draw detections
        frame = detectAndDraw(frame, cascade, nestedCascade, scale, tryflip);

        % update
        set(hImg, 'CData',frame);
        drawnow;
    end
    cap.release();
end

%% Help function
function img = detectAndDraw(img, cascadeF, cascadeE, scale, tryflip)
    % downscale image and preprocess it
    fx = 1/scale;
    gray = cv.cvtColor(img, 'RGB2GRAY');
    gray = cv.resize(gray, fx, fx);
    gray = cv.equalizeHist(gray);
    [h,w] = size(gray);

    % detection options
    detectOpts = {
        'ScaleFactor',1.1, ...
        'MinNeighbors',2, ...
        ... 'FindBiggestObject',true, ...
        ... 'DoRoughSearch',true, ...
        'ScaleImage',true, ...
        'MinSize',[30 30]
    };

    % detect faces
    tic
    faces = cascadeF.detect(gray, detectOpts{:});
    if tryflip
        faces2 = cascadeF.detect(cv.flip(gray, 1), detectOpts{:});
        faces2 = cellfun(@(r) [w-r(1)-r(3) r(2:4)], faces2, 'Uniform',false);
        faces = [faces(:); faces2(:)];
    end
    toc

    % draw
    clrs = uint8(255 * lines(7));
    for i=1:numel(faces)
        r = faces{i};
        ii = mod(i-1, size(clrs,1)) + 1;
        drawOpts = {'Color',clrs(ii,:), 'Thickness',3};

        % draw faces
        aspect_ratio = r(3)/r(4);
        if 0.75 < aspect_ratio && aspect_ratio < 1.3
            center = round((r(1:2) + r(3:4)*0.5) * scale);
            radius = round((r(3) + r(4)) * 0.25*scale);
            img = cv.circle(img, center, radius, drawOpts{:});
        else
            pt1 = round(r(1:2) * scale);
            pt2 = round((r(1:2) + r(3:4) - 1) * scale);
            img = cv.rectangle(img, pt1, pt2, drawOpts{:});
        end

        if ~cascadeE.empty()
            % detect nested objects (eyes)
            grayROI = imcrop(gray, [r(1:2)+1 r(3:4)]);
            nestedObjs = cascadeE.detect(grayROI, detectOpts{:});

            % draw eyes
            for j=1:numel(nestedObjs)
                nr = nestedObjs{j};
                center = round((r(1:2) + nr(1:2) + nr(3:4)*0.5) * scale);
                radius = round((nr(3) + nr(4)) * 0.25*scale);
                img = cv.circle(img, center, radius, drawOpts{:});
            end
        end
    end
end

function download_classifier_xml(fname)
    if ~exist(fname, 'file')
        % attempt to download trained Haar/LBP/HOG classifier from Github
        url = 'https://cdn.rawgit.com/opencv/opencv/3.1.0/data/';
        [~, f, ext] = fileparts(fname);
        if strncmpi(f, 'haarcascade_', length('haarcascade_'))
            url = fullfile(url, 'haarcascades');
        elseif strncmpi(f, 'lbpcascade_', length('lbpcascade_'))
            url = fullfile(url, 'lbpcascades');
        elseif strncmpi(f, 'hogcascade_', length('hogcascade_'))
            url = fullfile(url, 'hogcascades');
        else
            error('File not found');
        end
        fprintf('Downloading cascade classifier "%s"...\n', [f ext]);
        url = strrep(fullfile(url, [f ext]), '\', '/');
        urlwrite(url, fname);
    end
end
