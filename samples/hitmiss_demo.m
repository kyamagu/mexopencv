%% Hit-or-Miss Morphological Operation
%
% In this tutorial you will learn how to find a given configuration or pattern
% in a binary image by using the Hit-or-Miss transform (also known as
% Hit-and-Miss transform).
%
% This transform is also the basis of more advanced morphological operations
% such as thinning or pruning.
%
% We will use the OpenCV function |cv.morphologyEx|.
%
% Sources:
%
% * <https://docs.opencv.org/3.3.0/db/d06/tutorial_hitOrMiss.html>
% * <https://github.com/opencv/opencv/blob/3.3.0/samples/cpp/tutorial_code/ImgProc/HitMiss.cpp>
%

%% Theory
%
% Morphological operators process images based on their shape. These operators
% apply one or more _structuring elements_ to an input image to obtain the
% output image. The two basic morphological operations are the _erosion_ and
% the _dilation_. The combination of these two operations generate advanced
% morphological transformations such as _opening_, _closing_, or _top-hat_
% transform. To know more about these and other basic morphological operations
% refer to previous demos.
%
% The Hit-or-Miss transformation is useful to find patterns in binary images.
% In particular, it finds those pixels whose neighbourhood matches the shape
% of a first structuring element $B_1$ while not matching the shape of a
% second structuring element $B_2$ at the same time. Mathematically, the
% operation applied to an image $A$ can be expressed as follows:
%
% $$A \otimes B = (A \ominus B_1) \cap (A^c \ominus B_2)$$
%
% Therefore, the hit-or-miss operation comprises three steps:
%
% *# Erode image $A$ with structuring element $B_1$.
% *# Erode the complement of image $A$ ($A^c$) with structuring element $B_2$.
% *# AND results from step 1 and step 2.
%
% The structuring elements $B_1$ and $B_2$ can be combined into a single
% element $B$. Let's see an example:
%
% <<https://docs.opencv.org/3.3.0/hitmiss_kernels.png>>
%
% *Structuring elements (kernels). Left: kernel to 'hit'. Middle: kernel to
% 'miss'. Right: final combined kernel*
%
% In this case, we are looking for a pattern in which the central pixel
% belongs to the background while the north, south, east, and west pixels
% belong to the foreground. The rest of pixels in the neighbourhood can be of
% any kind, we don't care about them. Now, let's apply this kernel to an input
% image:
%
% <<https://docs.opencv.org/3.3.0/hitmiss_input.png>>
%
% You can see that the pattern is found in just one location within the image.
%
% <<https://docs.opencv.org/3.3.0/hitmiss_output.png>>
%
%% Other examples
%
% Here you can find the output results of applying different kernels to the
% same input image used before:
%
% * Kernel and output result for finding top-right corners
%
% <<https://docs.opencv.org/3.3.0/hitmiss_example2.png>>
%
% * Kernel and output result for finding left end points
%
% <<https://docs.opencv.org/3.3.0/hitmiss_example3.png>>
%
% Now try your own patterns!
%

%% Code

function hitmiss_demo()
    %%
    % input image
    img = 255 * uint8([
        0 0 0 0 0 0 0 0; ...
        0 1 1 1 0 0 0 1; ...
        0 1 1 1 0 0 0 0; ...
        0 1 1 1 0 1 0 0; ...
        0 0 1 0 0 0 0 0; ...
        0 0 1 0 0 1 1 0; ...
        0 1 0 1 0 0 1 0; ...
        0 1 1 0 0 0 0 0
    ]);
    figure, show_image(img), title('Original')

    %%
    % structuring element
    kernel = int32([0 1 0; 1 -1 1; 0 1 0]);
    figure, show_image(kernel), colorbar, title('Kernel')

    %%
    % hit-or-mess operation
    out = cv.morphologyEx(img, 'HitMiss', 'Element',kernel);
    figure, show_image(out), title('Hit or Miss')
end

%%
function show_image(img)
    % pad because PCOLOR chops off last row and column
    img = cv.copyMakeBorder(img, [0 1 0 1], 'BorderType','Constant');
    if mexopencv.isOctave()
        img = double(img);
    end
    h = pcolor(img);
    set(h, 'EdgeColor','b');
    set(gca, 'XAxisLocation','top')
    axis image ij, colormap(gray(3))
end
