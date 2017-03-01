%% People Detector Demo
% This program demonstrates the use of the HoG descriptor using the
% pre-trained SVM model for people detection.
% During execution, close figure to quit.
%
% <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/peopledetect.cpp>
%

%% Detector

% initialize
hog = cv.HOGDescriptor();
hog.SvmDetector = 'DefaultPeopleDetector';

%% Video

% input video file
vidfile = fullfile(mexopencv.root(),'test','768x576.avi');
if ~exist(vidfile, 'file')
    % download video from Github
    url = 'https://cdn.rawgit.com/opencv/opencv/3.1.0/samples/data/768x576.avi';
    disp('Downloading video...')
    urlwrite(url, vidfile);
end

% Read from video file
vid = cv.VideoCapture(vidfile);
assert(vid.isOpened(), 'cannot open video file');
img = vid.read();
assert(~isempty(img), 'Failed to read frame');

% prepare figure
hImg = imshow(img);
title('People Detector')

%% Run

% main processing loop
while ishghandle(hImg)
    % grab a new frame
    img = vid.read();
    if isempty(img), break; end

    % Run the detector with default parameters.
    % To get a higher hit-rate (and more false alarms, respectively),
    % decrease the HitThreshold and FinalThreshold
    % (set FinalThreshold to 0 to turn off the grouping completely).
    tic
    rects = hog.detectMultiScale(img, ...
        'HitThreshold',0, 'WinStride',[8 8], 'Padding',[32 32], ...
        'Scale',1.05, 'FinalThreshold',2);
    fprintf('detection time = %f\n', toc);

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
        r(1:2) = r(1:2) + round(r(3:4) .* [0.1 0.07]);
        r(3:4) = round(r(3:4) * 0.8);

        img = cv.rectangle(img, cv.Rect.tl(r), cv.Rect.br(r), ...
            'Color',[0 255 0], 'Thickness',3);
    end

    % display frame
    set(hImg, 'CData',img);
    drawnow;
end

vid.release();
