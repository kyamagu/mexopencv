%% Rotation model images stitcher
% A basic example on image stitching.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/stitching.cpp>
%

%% Input images (two or more)
im1 = imread(fullfile(mexopencv.root(),'test','b1.jpg'));
im2 = imread(fullfile(mexopencv.root(),'test','b2.jpg'));
%imshow(cat(2, im1, im2))
subplot(121), imshow(im1)
subplot(122), imshow(im2)

%% Stitch
stitcher = cv.Stitcher('TryUseGPU',false);
tic
pano = stitcher.stitch({im1, im2});
toc

%% Panorama result
figure
imshow(pano)
