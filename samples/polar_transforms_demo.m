%%  Polar Transforms demo
% An example using the cv.linearPolar and cv.logPolar operations.
%
% This program illustrates Linear-Polar and Log-Polar image transforms.
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/polar_transforms.cpp>
%

%%
% Set up camera
camera = cv.VideoCapture();
pause(1); % Necessary in some environment. See help cv.VideoCapture
assert(camera.isOpened(), 'Camera failed to initialize');

im = camera.read();
assert(~isempty(im), 'Failed to capture frames');
[r,c,~] = size(im);

disp('Polar transforms demo. Press any key when done.');

%%
% Set up display window, and start the main loop

window = figure('KeyPressFcn',@(obj,evt) setappdata(obj, 'flag',true));
setappdata(window, 'flag',false);

subplot(133), hImg(3) = imshow(im); title('Recovered image')
subplot(132), hImg(2) = imshow(im); title('Linear-Polar')
subplot(131), hImg(1) = imshow(im); title('Log-Polar')

% Start main loop
while ishghandle(window)
    % Grab an image
    im = camera.read();
    if isempty(im), break; end

    % transform
    log_polar_img = cv.logPolar(im, [c r]./2, 70, ...
        'Interpolation','Linear', 'FillOutliers',true);
    lin_polar_img = cv.linearPolar(im, [c r]./2, 700, ...
        'Interpolation','Linear', 'FillOutliers',true);

    % recover
    %recovered_img = cv.logPolar(log_polar_img, [c r]./2, 70, ...
    %    'Interpolation','Linear', 'FillOutliers',false, 'InverseMap',true);
    recovered_img = cv.linearPolar(lin_polar_img, [c r]./2, 700, ...
        'Interpolation','Linear', 'FillOutliers',true, 'InverseMap',true);

    % show results
    set(hImg(1), 'CData',log_polar_img);
    set(hImg(2), 'CData',lin_polar_img);
    set(hImg(3), 'CData',recovered_img);

    % Terminate if any user input
    flag = getappdata(window, 'flag');
    if isempty(flag) || flag, break; end
    pause(0.1);
end

% Close
snapnow
close(window);
clear camera
