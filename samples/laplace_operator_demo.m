%% Laplace Operator
%
% In this demo, we show how to use the OpenCV function |cv.Laplacian| to
% implement a discrete analog of the _Laplacian operator_.
%
% Sources:
%
% * <https://docs.opencv.org/3.2.0/d5/db5/tutorial_laplace_operator.html>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/tutorial_code/ImgTrans/Laplace_Demo.cpp>
%

%% Theory
%
% In a previous demo, we learned how to use the _Sobel Operator_. It was based
% on the fact that in the edge area, the pixel intensity shows a "jump" or a
% high variation of intensity. Getting the first derivative of the intensity,
% we observed that an edge is characterized by a maximum, as it can be seen in
% the figure:
%
% <<https://docs.opencv.org/3.2.0/Laplace_Operator_Tutorial_Theory_Previous.jpg>>
%
% And what happens if we take the second derivative?
%
% <<https://docs.opencv.org/3.2.0/Laplace_Operator_Tutorial_Theory_ddIntensity.jpg>>
%
% You can observe that the second derivative is zero! So, we can also use this
% criterion to attempt to detect edges in an image. However, note that zeros
% will not only appear in edges (they can actually appear in other meaningless
% locations); this can be solved by applying filtering where needed.
%
%% Laplacian Operator
%
% From the explanation above, we deduce that the second derivative can be used
% to _detect edges_. Since images are "2D", we would need to take the
% derivative in both dimensions. Here, the Laplacian operator comes handy.
%
% The _Laplacian operator_ is defined by:
%
% $$Laplace(f) = \frac{\partial^{2} f}{\partial x^{2}} +
%                \frac{\partial^{2} f}{\partial y^{2}}$$
%
% The Laplacian operator is implemented in OpenCV by the function
% |cv.Laplacian|. In fact, since the Laplacian uses the gradient of images, it
% calls internally the _Sobel_ operator to perform its computation.
%

%% Code
%
% The program:
%
% * Loads an image
% * Remove noise by applying a Gaussian blur and then convert the original
%   image to grayscale
% * Applies a Laplacian operator to the grayscale image and stores the output
%   image
% * Display the result in a window
%

%%
% load source image
src = cv.imread(fullfile(mexopencv.root(),'test','butterfly.jpg'), 'Color',true);

%%
% apply a Gaussian blur to reduce the noise
src = cv.GaussianBlur(src, 'KSize',[3 3]);

%%
% convert filtered image to grayscale
gray = cv.cvtColor(src, 'RGB2GRAY');

%%
% apply the Laplacian operator to the grayscale image
% (input is 8-bit, we set the output image depth to 16-bit to avoid overflow)
dst = cv.Laplacian(gray, 'KSize',3, 'DDepth','int16');

%%
% take absolute value and convert results back to 8-bit
dstabs = cv.convertScaleAbs(dst);

%%
% show result
imshow(dstabs)
title('Laplace Demo')
