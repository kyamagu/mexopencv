%% Background Subtractor Demo
% demonstration of BackgroundSubtractor

%%
% Set up camera
camera = cv.VideoCapture;
pause(3); % Necessary in some environment. See help cv.VideoCapture

%%
% Create a bg subtractor
bs = cv.BackgroundSubtractorMOG(...
    'History',100, 'NMixtures',5, 'BackgroundRatio',0.2, 'NoiseSigma',7);

disp('The subtractor will learn the background for a few seconds.');
disp('Keep out of the frame.');

%%
% Learn initial background model for a while
for t = 1:bs.History
    % Get an image
    im = camera.read;
    im = cv.resize(im,0.5,0.5);
    imshow(im);
    title(num2str(t));

    % learn background
    bs.apply(im, 'LearningRate', -1);

    % progress
    if mod(t,20)==0, fprintf('.'); end
    pause(0.05);
end
disp(' finished.');

%%
% Set up display window, and start the main loop
window = gcf;
set(window, 'KeyPressFcn',@(obj,evt)setappdata(obj,'flag',true));
setappdata(window,'flag',false);

% Start main loop
while true
    % Get an image
    im = camera.read;
    im = cv.resize(im,0.5,0.5);

    % detect and show foreground
    fg = bs.apply(im, 'LearningRate', 0);
    fg = cv.dilate(cv.erode(fg)) > 0;
    masked_im = bitand(im, repmat(im2uint8(fg),[1,1,3]));
    imshow(masked_im);

    % Terminate if any user input
    flag = getappdata(window,'flag');
    if isempty(flag)||flag, break; end
    pause(0.1);
end

% Close
snapnow
close(window);
clear camera
