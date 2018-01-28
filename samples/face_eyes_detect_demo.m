%% Face and Eyes Detection
%
% In this demo, we will learn the basics of face detection using Haar
% Feature-based Cascade Classifiers, and how the same extends for eye
% detection, etc.
%
% This program demonstrates the use of |cv.CascadeClassifier| class to detect
% objects (face + eyes). You can use Haar or LBP features. This classifier can
% detect many kinds of rigid objects, once the appropriate classifier is
% trained. It's most known use is for faces.
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/facedetect.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/tapi/ufacedetect.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/gpu/cascadeclassifier.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/python/facedetect.py>
% * <https://docs.opencv.org/3.2.0/db/d28/tutorial_cascade_classifier.html>
% * <https://docs.opencv.org/3.2.0/d7/d8b/tutorial_py_face_detection.html>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/tutorial_code/objectDetection/objectDetection.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/tutorial_code/objectDetection/objectDetection2.cpp>
%

%% Theory
%
% Object Detection using Haar feature-based cascade classifiers is an
% effective object detection method proposed by Paul Viola and Michael Jones
% in their paper, "Rapid Object Detection using a Boosted Cascade of Simple
% Features" in 2001. It is a machine learning based approach where a cascade
% function is trained from a lot of positive and negative images. It is then
% used to detect objects in other images.
%
% Here we will work with face detection. Initially, the algorithm needs a lot
% of positive images (images of faces) and negative images (images without
% faces) to train the classifier. Then we need to extract features from it.
% For this, haar features shown in the below image are used. They are just like
% our convolutional kernel. Each feature is a single value obtained by
% subtracting sum of pixels under the white rectangle from sum of pixels under
% the black rectangle.
%
% <<https://docs.opencv.org/3.4.0/haar_features.jpg>>
%
% Now all possible sizes and locations of each kernel are used to calculate
% lots of features. (Just imagine how much computation it needs? Even a
% 24x24 window results over 160000 features). For each feature calculation, we
% need to find the sum of the pixels under white and black rectangles. To
% solve this, they introduced the integral image. However large your image, it
% reduces the calculations for a given pixels, to an operation involving just
% four pixels. Nice, isn't it? It makes things super-fast.
%
% But among all these features we calculated, most of them are irrelevant. For
% example, consider the image below. The top row shows two good features. The
% first feature selected seems to focus on the property that the region of the
% eyes is often darker than the region of the nose and cheeks. The second
% feature selected relies on the property that the eyes are darker than the
% bridge of the nose. But the same windows applied to cheeks or any other
% place is irrelevant. So how do we select the best features out of 160000+
% features? It is achieved by *Adaboost*.
%
% <<https://docs.opencv.org/3.4.0/haar.png>>
%
% For this, we apply each and every feature on all the training images. For
% each feature, it finds the best threshold which will classify the faces to
% positive and negative. Obviously, there will be errors or misclassifications.
% We select the features with minimum error rate, which means they are the
% features that most accurately classify the face and non-face images. (The
% process is not as simple as this. Each image is given an equal weight in the
% beginning. After each classification, weights of misclassified images are
% increased. Then the same process is done. New error rates are calculated.
% Also new weights. The process is continued until the required accuracy or
% error rate is achieved or the required number of features are found).
%
% The final classifier is a weighted sum of these weak classifiers. It is
% called weak because it alone can't classify the image, but together with
% others forms a strong classifier. The paper says even 200 features provide
% detection with 95% accuracy. Their final setup had around 6000 features.
% (Imagine a reduction from 160000+ features to 6000 features. That is a big
% gain).
%
% So now you take an image. Take each 24x24 window. Apply 6000 features to it.
% Check if it is face or not. Wow.. Isn't it a little inefficient and time
% consuming? Yes, it is. The authors have a good solution for that.
%
% In an image, most of the image is non-face region. So it is a better
% idea to have a simple method to check if a window is not a face region. If
% it is not, discard it in a single shot, and don't process it again. Instead,
% focus on regions where there can be a face. This way, we spend more time
% checking a possible face region.
%
% For this they introduced the concept of *Cascade of Classifiers*. Instead of
% applying all 6000 features on a window, the features are grouped into
% different stages of classifiers and applied one-by-one. (Normally the first
% few stages will contain very many fewer features). If a window fails the
% first stage, discard it. We don't consider the remaining features on it. If
% it passes, apply the second stage of features and continue the process. The
% window which passes all stages is a face region. How is that plan!
%
% The authors' detector had 6000+ features with 38 stages with 1, 10, 25, 25
% and 50 features in the first five stages. (The two features in the above
% image are actually obtained as the best two features from Adaboost).
% According to the authors, on average, 10 features out of 6000+ are evaluated
% per sub-window.
%
% So this is a simple intuitive explanation of how Viola-Jones face detection
% works. Read the paper for more details or check out the following references:
%
% * Video Lecture on
%   <http://www.youtube.com/watch?v=WfdYYNamHZ8 Face Detection and Tracking>
% * An interesting interview regarding Face Detection by
%   <http://www.makematics.com/research/viola-jones/ Adam Harvey>
%
% OpenCV comes with a trainer as well as detector. If you want to train your
% own classifier for any object like car, planes etc. you can use OpenCV to
% create one. See the OpenCV docs for full details on Cascade Classifier
% Training.
%
% Here we will deal with detection. OpenCV already contains many pre-trained
% classifiers for face, eyes, smiles, etc. Those XML files are stored in
% the |opencv/data/haarcascades/| folder.
%

%% Code
%
% In this example, we will create a face and eyes detector with OpenCV:
%
% * First we need to load the required XML classifiers.
% * Then load our input image (or video) in grayscale mode.
% * Now we find the faces in the image. If faces are found, it returns the
%   positions of each detected faces as a rectangle |[x,y,w,h]|. Once we get
%   these locations, we can create a ROI for the face and apply eye detection
%   on this ROI (since eyes are always on the face!).
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

%% Initialization

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

%% Processing function

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
        faces2 = cellfun(@(r) [w-r(1)-r(3) r(2:4)], faces2, 'UniformOutput',false);
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
            if false && mexopencv.require('images')
                grayROI = imcrop(gray, [r(1:2)+1 r(3:4)]);
            else
                grayROI = cv.Rect.crop(gray, r);
            end
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
        fprintf('Downloading cascade classifier "%s"...\n', [f ext]);
        url = [url f ext];
        urlwrite(url, fname);
    end
end
