%% Line Segment Detector demo
% An example using the LineSegmentDetector.
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/lsd_lines.cpp>
%

%% Input image
img = imread(fullfile(mexopencv.root(),'test','building.jpg'));
gray = cv.cvtColor(img, 'RGB2GRAY');

%% Preprocess
% Apply canny edge
%gray = cv.Canny(gray, [50 200], 'ApertureSize',5);

%% LSD detectors
% Create two LSD detectors with standard and no refinement.
lsd1 = cv.LineSegmentDetector('Refine','Standard');
lsd2 = cv.LineSegmentDetector('Refine','None');

%%
% Detect the lines both ways
tic, lines1 = lsd1.detect(gray); toc
tic, lines2 = lsd2.detect(gray); toc

%% Result 1
% Show found lines with standard refinement
drawnLines1 = lsd1.drawSegments(gray, lines1);
imshow(drawnLines1), title('Standard refinement')
snapnow

%% Result 2
% Show found lines with no refinement
drawnLines2 = lsd2.drawSegments(gray, lines2);
imshow(drawnLines2), title('No refinement')
snapnow

%% Compare
[h,w,~] = size(img);
[comparison,mis_count] = lsd1.compareSegments([w,h], lines1, lines2);
imshow(comparison), title(sprintf('Mismatch = %d', mis_count))
snapnow
