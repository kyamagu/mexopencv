%% People Detection using HoG
% This program demonstrates the use of the HoG descriptor using the
% pre-trained SVM model for people detection.
% During execution, close figure to quit.
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/peopledetect.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/python/peopledetect.py>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/gpu/hog.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/tapi/hog.cpp>
%

%% Detector
% initialize
if true
    % DefaultPeopleDetector
    hog = cv.HOGDescriptor('WinSize',[64 64*2], 'NLevels',64);
    hog.SvmDetector = 'DefaultPeopleDetector';
    opts = {'HitThreshold',0, 'WinStride',[8 8], 'Padding',[32 32], ...
        'Scale',1.05, 'FinalThreshold',2};
elseif true
    % DaimlerPeopleDetector
    hog = cv.HOGDescriptor('WinSize',[48 48*2], 'NLevels',13, ...
        'GammaCorrection',true);
    hog.SvmDetector = 'DaimlerPeopleDetector';
    opts = {'HitThreshold',1.4, 'WinStride',[8 8], 'Padding',[0 0], ...
        'Scale',1.05, 'FinalThreshold',8};
else
    % load your own custom detector (linear SVM coefficients)
    hog = cv.HOGDescriptor();
    hog.SvmDetector = randn(1,3781);
end

%%
% you can also try tuning some parameters
%Scale */ 1.05
%NLevels +- 1
%FinalThreshold +- 1
%HitThreshold +- 0.25
%GammaCorrection = !GammaCorrection

%%
% check HOG params are consistent with the loaded pretrained SVM classifier
assert(hog.checkDetectorSize(), 'Invalid HOG params');

%% Video
% input video file
vidfile = fullfile(mexopencv.root(),'test','768x576.avi');
if exist(vidfile, 'file') ~= 2
    % download video from Github
    url = 'https://cdn.rawgit.com/opencv/opencv/3.1.0/samples/data/768x576.avi';
    disp('Downloading video...')
    urlwrite(url, vidfile);
end

%%
% Read from video file
vid = cv.VideoCapture(vidfile);
assert(vid.isOpened(), 'cannot open video file');
img = vid.read();
assert(~isempty(img), 'Failed to read frame');

%%
% prepare figure
hImg = imshow(img);
title('People Detector')

%% Run
% main processing loop
while ishghandle(hImg)
    % grab a new frame
    img = vid.read();
    if isempty(img), break; end
    out = img;

    if false
        % convert image to gray
        img = cv.cvtColor(img, 'RGB2GRAY');
    end

    % Run the detector with default parameters.
    % To get a higher hit-rate (and more false alarms, respectively),
    % decrease the HitThreshold and FinalThreshold
    % (set FinalThreshold to 0 to turn off the grouping completely).
    tic
    rects = hog.detectMultiScale(img, opts{:});
    fprintf('detection time = %f sec, %d found\n', toc, numel(rects));

    % Filter: drop small detections inside a bigger detection
    mask = true(size(rects));
    for i=1:numel(rects)
        for j=1:numel(rects)
            if i~=j && isequal(cv.Rect.intersect(rects{i},rects{j}), rects{i})
                mask(i) = false;
                break;
            end
        end
    end
    rects = rects(mask);

    % draw detections
    for i=1:numel(rects)
        % The HOG detector returns slightly larger rectangles than the real
        % objects, so we slightly shrink the rectangles to get a nicer output
        r = rects{i};
        if false
            r(1:2) = r(1:2) + round(r(3:4) .* [0.1 0.07]);
            r(3:4) = round(r(3:4) * 0.8);
            pt1 = cv.Rect.tl(r);
            pt2 = cv.Rect.br(r);
        else
            pad = fix(r(3:4) .* [0.15 0.05]);
            pt1 = r(1:2) + pad;
            pt2 = r(1:2) + r(3:4) - pad;
        end
        out = cv.rectangle(out, pt1, pt2, 'Color',[0 255 0], 'Thickness',3);
    end

    % display frame
    set(hImg, 'CData',out);
    drawnow;
end
vid.release();  % close video file
