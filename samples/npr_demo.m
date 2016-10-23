%% Non-Photorealistic Rendering demo
% This tutorial demonstrates how to use OpenCV Non-Photorealistic Rendering
% Module:
%
% * Edge Preserve Smoothing
%    - Using Normalized convolution Filter
%    - Using Recursive Filter
% * Detail Enhancement
% * Pencil sketch/Color Pencil Drawing
% * Stylization
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/npr_demo.cpp>
%

%% Input Image
I = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));

%% Edge Preserve Smoothing
img = cv.edgePreservingFilter(I, 'Filter','NormConv');
subplot(121), imshow(img), title({'Edge Preserve Smoothing', 'NormConv'})
img = cv.edgePreservingFilter(I, 'Filter','Recursive');
subplot(122), imshow(img), title({'Edge Preserve Smoothing', 'Recursive'})

%% Detail Enhancement
img = cv.detailEnhance(I);
figure
imshow(img), title('Detail Enhanced')

%% Pencil sketch
[img1, img] = cv.pencilSketch(I, 'SigmaS',10 , 'SigmaR',0.1, 'ShadeFactor',0.03);
figure
subplot(121), imshow(img1), title('Pencil Sketch');
subplot(122), imshow(img), title('Color Pencil Sketch');

%% Stylization
img = cv.stylization(I);
figure
imshow(img), title('Stylization')
