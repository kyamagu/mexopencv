%% Hough circles demo
% An example using the Hough circle detector.
%
% This program demonstrates circle finding with the Hough transform.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/houghcircles.cpp>
%

%% Input image
if true
    fname = which('coins.png');
    assert(~isempty(fname), 'Image not found');
else
    fname = fullfile(mexopencv.root(), 'test', 'detect_blob.png');
end
img = cv.imread(fname, 'Flags',1);

imshow(img), title('circles')

%% Processing
% convert to grayscale
gray = cv.cvtColor(img, 'RGB2GRAY');

%%
% reduce noise, otherwise a lot of false circles may be detected
%gray = cv.GaussianBlur(gray, 'KSize',[7,7], 'SigmaX',0.9, 'SigmaY',0.9);
gray = cv.medianBlur(gray, 'KSize',5);

%% HoughCircles
tic
circles = cv.HoughCircles(gray, 'Method','Gradient', 'DP',2, ...
    'MinDist',size(gray,1)/8, 'Param1',200, 'Param2',100, ...
    'MinRadius',20, 'MaxRadius',80);
toc

%%
for i=1:numel(circles)
    center = round(circles{i}(1:2));
    radius = round(circles{i}(3));

    % draw the circle outline
    img = cv.circle(img, center, radius, 'Color',[0,0,255], ...
        'Thickness',2, 'LineType','AA');

    % draw the circle center
    img = cv.circle(img, center, 3, 'Color',[0,255,0], ...
        'Thickness','Filled', 'LineType','AA');
end

imshow(img), title('detected circles')
