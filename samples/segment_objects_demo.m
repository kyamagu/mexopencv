%% Background Subtraction demo
% An example using drawContours to clean up a background segmentation result.
%
% This program demonstrates a simple method of connected components clean up
% of background subtraction.
% When the program starts, it begins learning the background.
% You can toggle background learning on and off using the checkbox.
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/segment_objects.cpp>
%

%% Set up camera
%cap = cv.VideoCapture('768x576.avi');
cap = cv.VideoCapture(0);
pause(2);
if ~cap.isOpened()
    error('Can not open camera');
end

frame = cap.read();
if isempty(frame)
    error('Can not read data from the video source');
end

%% Create a background subtractor
bgsubtractor = cv.BackgroundSubtractorMOG2();
bgsubtractor.VarThreshold = 10;

niters = 3;

%% Prepare window
hFig = figure('Position',[300 300 1000 450], ...
    'KeyPressFcn',@(o,e)setappdata(o,'flag',true));
setappdata(hFig, 'flag',false);
subplot(131), hImg1 = imshow(frame); title('video')
subplot(132), hImg2 = imshow(zeros(size(frame))); title('FG segmented')
subplot(133), hImg3 = imshow(zeros(size(frame))); title('BG')
hCB = uicontrol('Style','checkbox', 'Position',[20 20 200 20], ...
    'String','Update Background Model', 'Value',true);

%% Main loop
while ishghandle(hFig)
    % get next frame
    frame = cap.read();
    if isempty(frame), break; end

    % determine whether to update BG model or not, then compute FG mask
    update_bg_model = get(hCB,'Value');
    if update_bg_model
        learnRate = -1; % automatically chosen learning rate
    else
        learnRate = 0;  % dont update BG model
    end
    fgmask = bgsubtractor.apply(frame, 'LearningRate',learnRate);

    % process mask and extract largest connected component
    im = cv.dilate(fgmask, 'Iterations',niters);
    im = cv.erode(im, 'Iterations',niters*2);
    im = cv.dilate(im, 'Iterations',niters);
    [contours, hierarchy] = cv.findContours(im, ...
        'Mode','CComp', 'Method','Simple');
    if isempty(contours), continue; end
    areas = [];
    idx = 0;
    while idx >= 0
        % compute contour area
        areas(end+1) = abs(cv.contourArea(contours{idx+1}));
        % iterate through all the top-level contours
        idx = hierarchy{idx+1}(1);
    end
    [~,largestComp] = max(areas);
    out_frame = cv.drawContours(zeros(size(frame),'uint8'), contours, ...
        'ContourIdx',largestComp-1, 'Hierarchy',hierarchy, ...
        'Color',[0 0 255], 'Thickness','Filled');

    % update images
    set(hImg1, 'CData',frame)     % video frame
    set(hImg2, 'CData',out_frame) % largest contour in FG mask
    if update_bg_model
        % get the current BG model
        set(hImg3, 'CData',bgsubtractor.getBackgroundImage())
    end

    % Terminate if any user input
    flag = getappdata(hFig, 'flag');
    if isempty(flag)||flag, break; end
    pause(0.1);
end

%%
% release camera
cap.release()
