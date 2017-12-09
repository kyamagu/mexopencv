%% Image Remapping
%
% In this demo, we show how to use the OpenCV function |cv.remap| to implement
% simple remapping routines.
%
% Sources:
%
% * <https://docs.opencv.org/3.2.0/d1/da0/tutorial_remap.html>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/tutorial_code/ImgTrans/Remap_Demo.cpp>
%

%% Theory
%
% Remapping is the process of taking pixels from one place in the image and
% locating them in another position in a new image.
%
% To accomplish the mapping process, it might be necessary to do some
% interpolation for non-integer pixel locations, since there will not always
% be a one-to-one-pixel correspondence between source and destination images.
%
% We can express the remap for every pixel location $(x,y)$ as:
%
% $$g(x,y) = f ( h(x,y) )$$
%
% where $g()$ is the remapped image, $f()$ the source image and $h(x,y)$ is
% the mapping function that operates on $(x,y)$.
%
% Let's think in a quick example. Imagine that we have an image $I$ and, say
% we want to do a remap such that:
%
% $$h(x,y) = (I.cols - x, y )$$
%
% What would happen? It is easily seen that the image would flip in the $x$
% direction. For instance, consider the input image:
%
% <<https://docs.opencv.org/3.2.0/Remap_Tutorial_Theory_0.jpg>>
%
% observe how the red circle changes positions with respect to x (considering
% $x$ the horizontal direction):
%
% <<https://docs.opencv.org/3.2.0/Remap_Tutorial_Theory_1.jpg>>
%
% In OpenCV, the function |cv.remap| offers a simple remapping implementation.
%

%% Code
%
% This program:
%
% * Loads an image
% * Apply 1 of 4 different remapping processes to the image and display them
%   in a window.
%

%%
% load input image
src = imread(fullfile(mexopencv.root(), 'test', 'tsukuba.png'));
imshow(src), title('Source')

%%
% prepare for building mapping matrices (for x and y coordinates),
% we are going to perform 4 different mappings
[rows,cols,~] = size(src);
[X,Y] = meshgrid((1:cols)-1, (1:rows)-1);  % 0-based indices
map = struct('x',[], 'y',[]);

%%
% 1) reduce the picture to half its size and center it in the middle
map(1).x = zeros(rows,cols);
map(1).y = zeros(rows,cols);
idx = (X > cols*0.25 & X < cols*0.75 & Y > rows*0.25 & Y < rows*0.75);
map(1).x(idx) = 2*(X(idx) - cols*0.25) + 0.5;
map(1).y(idx) = 2*(Y(idx) - rows*0.25) + 0.5;

%%
% 2) turn the image upside down (flip-y)
map(2).x = X;
map(2).y = rows - Y;

%%
% 3) reflect the image from left to right (flip-x)
map(3).x = cols - X;
map(3).y = Y;

%%
% 4) combination of 3 and 4 (flip-xy)
map(4).x = cols - X;
map(4).y = rows - Y;

%%
% apply mapping matrices to source image, and show results
pos = get(0, 'DefaultFigurePosition');
figure('Position',pos.*[0.5 0.5 1.3 1.3])
for k=1:4
    dst = cv.remap(src, map(k).x, map(k).y);
    subplot(2,2,k), imshow(dst), title(sprintf('map(%d)',k))
end

%%
% show mapping matrices
figure('Position',pos.*[0.5 1 2 1])
for k=1:4
    subplot(2,4,k), imshow(map(k).x, []), title(sprintf('map(%d).X',k))
    subplot(2,4,k+4), imshow(map(k).y, []), title(sprintf('map(%d).Y',k))
end
