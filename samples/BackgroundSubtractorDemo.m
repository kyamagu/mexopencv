function BackgroundSubtractorDemo
%BackgroundSubtractorDemo demonstration of BackgroundSubtractor

fprintf('The subtractor will learn the background for a few seconds.\n');
fprintf('Keep out of the frame.');

% Set up camera
camera = cv.VideoCapture;
pause(3);

% Create a subtractor
bs = cv.BackgroundSubtractorMOG(100,5,0.2,'NoiseSigma',7);

% Set up display window
window = figure('KeyPressFcn',@(obj,evt)setappdata(obj,'flag',true));
setappdata(window,'flag',false);

% Learn initial background model for a while
for t = 1:bs.history
    % Get an image
    im = camera.read;
    im = cv.resize(im,0.5);
    bs.apply(im, 'LearningRate', -1);
    imshow(im);
    pause(0.05);
    if mod(t,20)==0, fprintf('.'); end
end
fprintf('finished.\n');

% Start main loop
while true
    % Get an image
    im = camera.read;
    im = cv.resize(im,0.5);
    fg = bs.apply(im, 'LearningRate', 0);
    fg = cv.dilate(cv.erode(fg))>0;
    masked_im = bitand(im,repmat(im2uint8(fg),[1,1,3]));
    imshow(masked_im);

    % Terminate if any user input
    flag = getappdata(window,'flag');
    if isempty(flag)||flag, break; end
    pause(0.1);
end

% Close
close(window);

end

