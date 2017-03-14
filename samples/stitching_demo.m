%% Rotation model images stitcher
% A basic example on image stitching.
%
% <http://docs.opencv.org/3.2.0/d8/d19/tutorial_stitcher.html>
% <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/stitching.cpp>
%

%% Input images (two or more)
im1 = imread(fullfile(mexopencv.root(),'test','b1.jpg'));
im2 = imread(fullfile(mexopencv.root(),'test','b2.jpg'));
%imshow(cat(2, im1, im2))
subplot(121), imshow(im1)
subplot(122), imshow(im2)

%% Options

% Try to use GPU. The default value is false.
% All default values are for CPU mode.
try_use_gpu = false;

% Determines configuration of stitcher. The default is 'Panorama' mode
% suitable for creating photo panoramas. Option 'Scans' is suitable for
% stitching materials under affine transformation, such as scans.
smode = 'Panorama';

%% Stitch
stitcher = cv.Stitcher('Mode',smode, 'TryUseGPU',try_use_gpu);
tic
pano = stitcher.stitch({im1, im2});
toc

%% Panorama result
figure
imshow(pano)
