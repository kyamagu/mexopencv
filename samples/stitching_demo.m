%% Rotation model images stitcher
% A basic example on image stitching.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/stitching.cpp>
%

%% Input images (two or more)
im1 = imread(fullfile(mexopencv.root(),'test','b1.jpg'));
im2 = imread(fullfile(mexopencv.root(),'test','b2.jpg'));
imshowpair(im1, im2, 'montage')

%% Stitch
stitcher = cv.Stitcher('TryUseGPU',false);
tic
pano = stitcher.stitch({im1, im2});
toc

%% Panorama result
imshow(pano)
