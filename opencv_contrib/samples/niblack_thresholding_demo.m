%% NiBlack threshold demo
% Sample to demonstrate Niblack thresholding.
%
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/ximgproc/samples/niblack_thresholding.cpp>
%

%TODO: https://github.com/opencv/opencv_contrib/pull/542

%% Load gray-scale image
src = cv.imread(fullfile(mexopencv.root(),'test','sudoku.jpg'), 'Grayscale',true);
assert(~isempty(src), 'Could not open image');

%% threshold image
k = -0.2;
bsz = 31;
tic, dst1 = cv.niBlackThreshold(src, k, 'BlockSize',bsz, 'Type','Binary'); toc
tic, dst2 = cv.adaptiveThreshold(src, 'BlockSize',bsz, 'Type','Binary'); toc
tic, dst3 = cv.threshold(src, 'Otsu', 'Type','Binary'); toc

%% display output
subplot(221), imshow(src), title('Source')
subplot(222), imshow(dst1), title('Niblack')
subplot(223), imshow(dst2), title('Adaptive')
subplot(224), imshow(dst3), title('Otsu')
