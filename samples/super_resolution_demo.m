%% Super Resolution demo
% This sample demonstrates Super Resolution algorithms for video sequence.
%
% <https://github.com/Itseez/opencv/blob/3.0.0/samples/gpu/super_resolution.cpp>
%

%%
% Super Resolution algorithm (runs on CPU)
superRes = cv.SuperResolution('BTVL1');
superRes.Scale = 4;              % Scale factor
superRes.Iterations = 10;        % Iteration count
superRes.TemporalAreaRadius = 4; % Radius of the temporal search area

%%
% Optical Flow algorithm (Farneback or TV-L1)
if true
    superRes.setOpticalFlow('FarnebackOpticalFlow');
else
    superRes.setOpticalFlow('DualTVL1OpticalFlow');
end

%%
% Input video
inputVideoName = fullfile(mexopencv.root(),'test','car.avi');
if ~exist(inputVideoName, 'file')
    % download video from Github
    url = 'https://cdn.rawgit.com/Itseez/opencv_extra/3.0.0/testdata/superres/car.avi';
    disp('Downloading video...')
    urlwrite(url, inputVideoName);
end
superRes.setInput('Video', inputVideoName);

% get video info
cap = cv.VideoCapture(inputVideoName);
fprintf('Size = %dx%d\n', cap.FrameWidth, cap.FrameHeight);
fprintf('NumFrames = %d\n', cap.FrameCount);
clear cap

%%
% Output video
outputVideoName = [tempname '.avi'];
writer = cv.VideoWriter();

%%
% Set up display window, and start loop
hFig = figure('Name', 'Super Resolution', 'NumberTitle','off', ...
    'Menubar','none', 'KeyPressFcn',@(o,e)setappdata(o, 'flag',true));
setappdata(hFig, 'flag',false);

i = 0;
while true
    % get next frame
    i = i + 1;
    fprintf('[%3d] : ', i);
    tic, frame = superRes.nextFrame(); toc
    if isempty(frame), break; end
    sz = size(frame);

    % write it to output video
    if ~writer.isOpened()
        writer.open(outputVideoName, [sz(2) sz(1)], ...
            'FourCC','XVID', 'FPS',25);
    end
    writer.write(frame);

    % display it
    if i == 1
        set(hFig, 'Position',[200 200 sz(2) sz(1)]);
        movegui(hFig, 'center');
        hImg = imshow(frame, 'InitialMagnification',100, 'Border','tight');
    else
        set(hImg, 'CData',frame);
    end
    %title(num2str(i))

    % Terminate if any user input
    flag = getappdata(hFig, 'flag');
    if isempty(flag)||flag, break; end
    drawnow
end

%%
% release output video, and open it in external player
writer.release();
if ispc
    winopen(outputVideoName)
end
