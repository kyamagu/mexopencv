%% Smoothing Images
% In this tutorial you will learn how to apply diverse linear filters to
% smooth images using OpenCV functions such as:
%
% * <matlab:doc('cv.blur') cv.blur>
% * <matlab:doc('cv.GaussianBlur') cv.GaussianBlur>
% * <matlab:doc('cv.medianBlur') cv.medianBlur>
% * <matlab:doc('cv.bilateralFilter') cv.bilateralFilter>
%
% Sources:
%
% * <https://docs.opencv.org/3.1.0/dc/dd3/tutorial_gausian_median_blur_bilateral_filter.html>
%

%% Theory
% Note: The explanation below belongs to the book
% <http://szeliski.org/Book/ Computer Vision: Algorithms and Applications>
% by Richard Szeliski and _Learning OpenCV_.
%%
% _Smoothing_, also called _blurring_, is a simple and frequently used
% image processing operation.
%%
% There are many reasons for smoothing. In this tutorial we will focus on
% smoothing in order to reduce noise (other uses will be seen in the
% following tutorials).
%%
% To perform a smoothing operation we will apply a _filter_ to our image.
% The most common type of filters are _linear_, in which an output pixel's
% value (i.e. $g(i,j)$) is determined as a weighted sum of input pixel
% values (i.e. $f(i+k,j+l)$):
%
% $$ g(i,j) = \sum_{k,l} f(i+k, j+l) h(k,l) $$
%
% $h(k,l)$ is called the _kernel_, which is nothing more than the
% coefficients of the filter.
%
% It helps to visualize a _filter_ as a window of coefficients sliding
% across the image.
%%
% There are many kind of filters, here we will mention the most used.
%

%% 1. Normalized Box Filter
%
% * This filter is the simplest of all! Each output pixel is the _mean_ of
%   its kernel neighbors (all of them contribute with equal weights)
% * The kernel is below:
%
% $$ K = \frac{1}{K_{width} \cdot K_{height}}
%     \left[ {\matrix{
%       1 & 1 & 1 & ... & 1 \cr
%       1 & 1 & 1 & ... & 1 \cr
%       . & . & . & ... & 1 \cr
%       . & . & . & ... & 1 \cr
%       1 & 1 & 1 & ... & 1
%     } } \right] $$
%

%% 2. Gaussian Filter
%
% * Probably the most useful filter (although not the fastest). Gaussian
%   filtering is done by convolving each point in the input array with a
%   _Gaussian kernel_ and then summing them all to produce the output array.
%
% * Just to make the picture clearer, remember how a 1D Gaussian kernel look
%   like?
%

pos = get(0, 'DefaultFigurePosition');
set(gcf, 'Position',pos.*[1 1 0.5 0.5])

x = linspace(-4,4,100);
plot(x, normpdf(x,0,1))
xlabel('x'), ylabel('G(x)'), grid on

%%
% Assuming that an image is 1D, you can notice that the pixel located in the
% middle would have the biggest weight. The weight of its neighbors decreases
% as the spatial distance between them and the center pixel increases.
%
% Note: Remember that a 2D Gaussian can be represented as:
%
% $$ G_{0}(x, y) = A e^{ \frac{ -(x - \mu_{x})^{2} }{ 2\sigma^{2}_{x} } +
%                        \frac{ -(y - \mu_{y})^{2} }{ 2\sigma^{2}_{y} } } $$
%
% where $\mu$ is the mean (the peak) and $\sigma^{2}$ represents the variance
% (per each of the variables $x$ and $y$).
%

%% 3. Median Filter
%
% The median filter run through each element of the signal (in this case the
% image) and replace each pixel with the *median* of its neighboring pixels
% (located in a square neighborhood around the evaluated pixel).
%

%% 4. Bilateral Filter
%
% * So far, we have explained some filters which main goal is to _smooth_ an
%   input image. However, sometimes the filters do not only dissolve the
%   noise, but also smooth away the _edges_. To avoid this (at certain extent
%   at least), we can use a bilateral filter.
% * In an analogous way as the Gaussian filter, the bilateral filter also
%   considers the neighboring pixels with weights assigned to each of them.
%   These weights have two components, the first of which is the same
%   weighting used by the Gaussian filter. The second component takes into
%   account the difference in intensity between the neighboring pixels and
%   the evaluated one.
% * For a more detailed explanation you can check
%   <http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/MANDUCHI1/Bilateral_Filtering.html this link>.
%

%% Code
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/tutorial_code/ImgProc/Smoothing.cpp>
%
% This <./smoothing_demo.html program>:
%
% * Loads an image
% * Applies 4 different kinds of filters (explained in Theory) and show the
%   filtered images sequentially.
%
%%
% <include>smoothing_demo.m</include>
%

%% Explanation
% Let's check the OpenCV functions that involve only the smoothing procedute,
% since the rest is already known by now.
%

%%
% <html><h3>1. Normalized Block Filter:</h3></html>
%
% OpenCV offers the function |cv.blur()| to perform smoothing with this
% filter.
%
%%
dbtype smoothing_demo 26:30
%%
% We specify the following arguments (for more details, check the function
% reference):
%
% * |src|: Source image
% * |dst|: Destination image
% * |'KSize',[w,h]|: Defines the size of the kernel to be used (of width $w$
%   pixels and height $h$ pixels)
% * |'Anchor',[-1,-1]|: Indicates where the anchor point (the pixel evaluated)
%   is located with respect to the neighborhood. If there is a negative value,
%   then the center of the kernel is considered the anchor point.
%

%%
% <html><h3>2. Gaussian Filter:</h3></html>
%
% It is performed by the function |cv.GaussianBlur()|:
%
%%
dbtype smoothing_demo 33:37
%%
% Here we use the following arguments:
%
% * |src|: Source image
% * |dst|: Destination image
% * |'KSize',[w,h]|: The size of the kernel to be used (the neighbors to be
%   considered). $w$ and $h$ have to be odd and positive numbers otherwise the
%   size will be calculated using the $\sigma_{x}$ and $\sigma_{y}$ arguments.
% * |'SigmaX'|: The standard deviation in x. Writing $0$ implies that
%   $\sigma_{x}$ is calculated using kernel size.
% * |'SigmaY|: The standard deviation in y. Writing $0$ implies that
%   $\sigma_{y}$ is calculated using kernel size.
%

%%
% <html><h3>3. Median Filter:</h3></html>
%
% This filter is provided by the |cv.medianBlur()| function:
%
%%
dbtype smoothing_demo 40:44
%%
% We use these arguments:
%
% * |src|: Source image
% * |dst|: Destination image, must be the same type as |src|
% * |'KSize',i|: Size of the kernel (only one because we use a square window).
%   Must be odd.
%

%%
% <html><h3>4. Bilateral Filter:</h3></html>
%
% Provided by OpenCV function |cv.bilateralFilter()|.
%
%%
dbtype smoothing_demo 47:52
%%
% We use the following arguments:
%
% * |src|: Source image
% * |dst|: Destination image
% * |'Diameter',d|: The diameter of each pixel neighborhood.
% * |'SigmaColor',sc|: Standard deviation in the color space $\sigma_{Color}$.
% * |'SigmaSpace',ss|: Standard deviation in the coordinate space (in pixel
%   terms) $\sigma_{Space}$.
%

%% Results
%
% * The code opens an image (in this case |lena.jpg|) and display it under the
%   effects of the 4 filters explained.
% * Here is a snapshot of the image smoothed using |cv.medianBlur|:
%
% <<./smoothing_demo_04.png>>
%
