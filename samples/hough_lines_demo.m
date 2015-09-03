%% Hough lines demo
% An example using the Hough line detector.
%
% This program demonstrates line finding with the Hough transform.
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/houghlines.cpp>
%

%% Input image
src = imread('gantrycrane.png');

imshow(src), title('Source')
snapnow

%% Processing
% Edge Detection
dst = cv.Canny(src, [50, 200], 'ApertureSize',3);

%%
% Output images
color_dst = cv.cvtColor(dst, 'GRAY2RGB');
color_dst2 = color_dst;

%% HoughLines
tic
lines = cv.HoughLines(dst, 'Rho',1, 'Theta',pi/180, 'Threshold',100);
toc

%%
for i=1:numel(lines)
    rho = lines{i}(1);
    theta = lines{i}(2);

    a = cos(theta); b = sin(theta);
    x0 = a*rho; y0 = b*rho;
    pt1 = round([x0 + 1000*(-b), y0 + 1000*(a)]);
    pt2 = round([x0 - 1000*(-b), y0 - 1000*(a)]);

    color_dst = cv.line(color_dst, pt1, pt2, ...
        'Color',[0,0,255], 'Thickness',2, 'LineType','AA');
end

imshow(color_dst), title('Detected Lines')
snapnow

%% HoughLinesP
tic
lines = cv.HoughLinesP(dst, 'Rho',1, 'Theta',pi/180, 'Threshold',50, ...
    'MinLineLength',50, 'MaxLineGap',20);
toc

%%
for i=1:numel(lines)
    color_dst2 = cv.line(color_dst2, lines{i}(1:2), lines{i}(3:4), ...
        'Color',[0,0,255], 'Thickness',2, 'LineType','AA');
end

imshow(color_dst2), title('Detected Line Segments')
snapnow
