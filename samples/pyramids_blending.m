%% Image Pyramids
%
% In this tutorial:
%
% * We will learn about Image Pyramids
% * We will use Image pyramids to create a new fruit, "Orapple"
% * We will see these functions: |cv.pyrUp|, |cv.pyrDown|, |cv.buildPyramid|
%
% Sources:
%
% * <https://docs.opencv.org/3.1.0/dc/dff/tutorial_py_pyramids.html>
%

%% Theory
% Normally, we used to work with an image of constant size. But on some
% occasions, we need to work with (the same) images in different resolutions.
% For example, while searching for something in an image, like face, we are
% not sure at what size the object will be present in said image. In that
% case, we will need to create a set of the same image with different
% resolutions and search for object in all of them. These set of images with
% different resolutions are called *Image Pyramids* (because when they are
% kept in a stack with the highest resolution image at the bottom and the
% lowest resolution image at top, it looks like a pyramid).
%
% There are two kinds of Image Pyramids:
%
% # Gaussian Pyramid
% # Laplacian Pyramids
%
% Higher level (Low resolution) in a Gaussian Pyramid is formed by removing
% consecutive rows and columns in Lower level (higher resolution) image.
% Then each pixel in higher level is formed by the contribution from 5 pixels
% in underlying level with gaussian weights. By doing so, a |MxN| image
% becomes |M/2xN/2| image. So area reduces to one-fourth of original area. It
% is called an Octave. The same pattern continues as we go upper in pyramid
% (ie, resolution decreases). Similarly while expanding, area becomes 4 times
% in each level. We can find Gaussian pyramids using |cv.pyrDown| and
% |cv.pyrUp| functions.
%
% Below is the 4 levels in an image pyramid:
%

% compute Gaussian pyramid
img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), 'ReduceScale',2);
p = cv.buildPyramid(img, 'MaxLevel',4);

% combine all levels in one image
[rows,cols,~] = cellfun(@size, p);
dst = zeros([rows(1) cols(1)+cols(2) size(img,3)], class(img));
r_start = [0 0 cumsum(rows(2:end-1))] + 1;
r_end = [rows(1) cumsum(rows(2:end))];
c_start = [0 repmat(cols(1),1,numel(p)-1)] + 1;
c_end = [cols(1) cols(1)+cols(2:end)];
for i=1:numel(p)
    dst(r_start(i):r_end(i), c_start(i):c_end(i), :) = p{i};
end
figure, imshow(dst)

%%
% Now you can go down the image pyramid with |cv.pyrUp| function.
%
% Remember, |higher_reso2| is not equal to |higher_reso|, because once you
% decrease the resolution, you loose the information.
%

higher_reso = img;
lower_reso = cv.pyrDown(higher_reso);
higher_reso2 = cv.pyrUp(lower_reso);
figure, imshow(cat(2, higher_reso, higher_reso2))

%%
% Laplacian Pyramids are formed from the Gaussian Pyramids. There is no
% exclusive function for that. Laplacian pyramid images are like edge images
% only. Most of its elements are zeros. They are used in image compression.
% A level in Laplacian Pyramid is formed by the difference between that level
% in Gaussian Pyramid and expanded version of its upper level in Gaussian
% Pyramid. The three levels of a Laplacian level will look like below
% (contrast is adjusted to enhance the contents):
%

% compute Gaussian pyramid
img = imread(fullfile(mexopencv.root(),'test','butterfly.jpg'));
p = cv.Blender.createLaplacePyr(img, 4);

% combine all levels in one image
[rows,cols,~] = cellfun(@size, p);
dst = zeros([rows(1)+rows(2) cols(1) size(img,3)], class(img));
r_start = [0 repmat(rows(1),1,numel(p)-1)] + 1;
r_end = [rows(1) rows(1)+rows(2:end)];
c_start = [0 0 cumsum(cols(2:end-1))] + 1;
c_end = [cols(1) cumsum(cols(2:end))];
for i=1:numel(p)-1
    dst(r_start(i):r_end(i),  c_start(i):c_end(i), :) = uint8(p{i});
end
figure, imshow(dst)
%imshow(cv.CLAHE(rgb2gray(dst)))

%% Image Blending using Pyramids
% One application of Pyramids is Image Blending. For example, in image
% stitching, you will need to stack two images together, but it may not look
% good due to discontinuities between images. In that case, image blending
% with Pyramids gives you seamless blending without leaving much data in the
% images. One classical example of this is the blending of two fruits, Orange
% and Apple.
%
% Please check first reference in additional resources, it has full
% diagramatic details on image blending, Laplacian Pyramids etc. Simply it is
% done as follows:
%
% * Load the two images of apple and orange
% * Find the Gaussian Pyramids for apple and orange (in this particular
%   example, number of levels is 6)
% * From Gaussian Pyramids, find their Laplacian Pyramids
% * Now join the left half of apple and right half of orange in each levels
%   of Laplacian Pyramids
% * Finally from this joint image pyramids, reconstruct the original image.
%
% Below is the full code. (For sake of simplicity, each step is done
% separately which may take more memory. You can optimize it if you want so).
%

% a pair of images of same size
A = imread(fullfile(mexopencv.root(),'test','apple.jpg'));
B = imread(fullfile(mexopencv.root(),'test','orange.jpg'));

% generate Laplacian Pyramids
pA = cv.Blender.createLaplacePyr(A, 5);
pB = cv.Blender.createLaplacePyr(B, 5);

% add left and right halves of images in each level
p = pB;
for i=1:numel(p)
    idx = round(size(pA{i},2)/2);
    p{i}(:,1:idx,:) = pA{i}(:,1:idx,:);
end
%{
% add top and bottom halves of images in each level
p = pB;
for i=1:numel(p)
    idx = round(size(pA{i},1)/2);
    p{i}(1:idx,:,:) = pA{i}(1:idx,:,:);
end
%}

% reconstruct
C = cv.Blender.restoreImageFromLaplacePyr(p);
C = uint8(C);

% image with direct connecting each half
idx = round(size(A,2)/2);
D = B;
D(:,1:idx,:) = A(:,1:idx,:);

% show images
figure
subplot(221), imshow(A), title('Apple')
subplot(222), imshow(B), title('Orange')
subplot(223), imshow(C), title('Pyramid Blending')
subplot(224), imshow(D), title('Direct Connection')

%% Additional Resources
%
% <http://pages.cs.wisc.edu/~csverma/CS766_09/ImageMosaic/imagemosaic.html Image Blending>
%
