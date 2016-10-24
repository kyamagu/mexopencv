%% Farneback Optical Flow demo
% This program demonstrates dense optical flow algorithm by Gunnar Farneback,
% mainly the function |cv.calcOpticalFlowFarneback|.
% It captures from the camera by default.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/fback.cpp>
%

%% Options

% options for plotting vector field
useQuiver = true;  % use MATLAB quiver or manual OpenCV line/circle
step = 16;         % subsample in x/y directions for less dense plot
clr = [0 255 0];   % color of arrows

%% Input video

% setup video capture
cap = cv.VideoCapture();
assert(cap.isOpened(), 'Could not initialize capturing');
frame = cap.read();
assert(~isempty(frame), 'Could not read frame');
[h,w,~] = size(frame);

%% Prepare

% grid over which to plot vector field
xstep = 1:step:w;
ystep = 1:step:h;
[X,Y] = meshgrid(xstep, ystep);
XY = [X(:) Y(:)];

% prepare plot
prev = cv.cvtColor(frame, 'RGB2GRAY');
hImg = imshow(prev);
if useQuiver
    hold on
    hQ = quiver(X(:), Y(:), X(:)*0, Y(:)*0, 0, 'Color',clr/255);
    hold off
end

%% Main loop
while ishghandle(hImg)
    % grab frame
    frame = cap.read();
    if isempty(frame), break; end

    % calculate optical flow
    next = cv.cvtColor(frame, 'RGB2GRAY');
    flow = cv.calcOpticalFlowFarneback(prev, next, ...
        'Levels',3, 'WinSize',15, 'Iterations',3, 'PolySigma',1.2);

    % draw optical flow map
    out = repmat(prev, [1 1 3]);
    if useQuiver
        % use MATLAB quiver function
        U = flow(ystep,xstep,1);
        V = flow(ystep,xstep,2);
        set(hQ, 'UData',U(:), 'VData',V(:));
    elseif true
        % use OpenCV cirlce/line (vectorized implementation)
        UV = reshape(permute(flow(ystep,xstep,:), [3 1 2]), 2, []).';
        out = cv.circle(out, XY, 2, 'Color',clr, 'Thickness','Filled');
        out = cv.line(out, XY, round(XY+UV), 'Color',clr);  % cv.arrowedLine
    else
        % use OpenCV cirlce/line (loops, slower)
        for x=xstep
            for y=ystep
                xy = [x y];
                uv = [flow(y,x,1) flow(y,x,2)];
                out = cv.circle(out, xy, 2, 'Color',clr, 'Thickness','Filled');
                out = cv.line(out, xy, round(xy+uv), 'Color',clr);
            end
        end
    end

    % show result
    set(hImg, 'CData',out);
    drawnow;

    % swap
    prev = next;
end
cap.release();  % close camera feed
