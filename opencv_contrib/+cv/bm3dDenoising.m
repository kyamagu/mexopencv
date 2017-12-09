%BM3DDENOISING  Performs image denoising using the Block-Matching and 3D-filtering algorithm
%
%     dst = cv.bm3dDenoising(src)
%     [dstStep1, dstStep2] = cv.bm3dDenoising(src)
%     [...] = cv.bm3dDenoising(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit or 16-bit 1-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
% * __dstStep1__ Output image of the first step of BM3D with the same size and
%   type as `src`. `Basic` image must be provided.
% * __dstStep2__ Output image of the second step of BM3D with the same size
%   and type as `src`.
%
% ## Options
% * __Basic__ Basic image, initial estimate of the first step. Must be
%   provided in the case of `Step=2`.
% * __H__ Parameter regulating filter strength. Big `H` value perfectly
%   removes noise but also removes image details, smaller `H` value preserves
%   details but also preserves some noise. default 1
% * __TemplateWindowSize__ Size in pixels of the template patch that is used
%   for block-matching. Should be power of 2. default 4
% * __SearchWindowSize__ Size in pixels of the window that is used to perform
%   block-matching. Affect performance linearly: greater `SearchWindowsSize`
%   greater denoising time. Must be larger than `TemplateWindowSize`.
%   default 16
% * __BlockMatchingStep1__ Block matching threshold for the first step of BM3D
%   (hard thresholding), i.e. maximum distance for which two blocks are
%   considered similar. Value expressed in euclidean distance. default 2500
% * __BlockMatchingStep2__ Block matching threshold for the second step of
%   BM3D (Wiener filtering), i.e. maximum distance for which two blocks are
%   considered similar. Value expressed in euclidean distance. default 400
% * __GroupSize__ Maximum size of the 3D group for collaborative filtering.
%   default 8
% * __SlidingStep__ Sliding step to process every next reference block.
%   default 1
% * __Beta__ Kaiser window parameter that affects the sidelobe attenuation of
%   the transform of the window. Kaiser window is used in order to reduce
%   border effects. To prevent usage of the window, set beta to zero.
%   default 2.0
% * __NormType__ Norm used to calculate distance between blocks. L2 is slower
%   than L1 but yields more accurate results. default 'L2'. One:
%   * __L2__
%   * __L1__
% * __Step__ Step of BM3D to be executed. Possible variants are: step 1,
%   step 2, both steps. In the first variant, allowed are only '1' and 'All'.
%   '2' is not allowed as it requires `Basic` estimate to be present. One of:
%   * __All__ (default) Execute all steps of the algorithm.
%   * __1__ Execute only first step of the algorithm.
%   * __2__ Execute only second step of the algorithm.
% * __TransformType__ Type of the orthogonal transform used in collaborative
%   filtering step. Currently only Haar transform is supported. One of:
%   * __Haar__ (default) Un-normalized Haar transform.
%
% Performs image denoising using the Block-Matching and 3D-filtering algorithm
% [PDF](http://www.cs.tut.fi/~foi/GCF-BM3D/BM3D_TIP_2007.pdf) with several
% computational optimizations. Noise expected to be a gaussian white noise.
%
% This function expected to be applied to grayscale images. Advanced usage of
% this function can be manual denoising of colored image in different
% colorspaces.
%
% Note: This algorithm is patented and is excluded in the default
% configuration; Set `OPENCV_ENABLE_NONFREE` CMake option and rebuild the
% library.
%
% See also: cv.fastNlMeansDenoising, wiener2
%
