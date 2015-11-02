%SEAMLESSCLONE  Seamless Cloning
%
%    blend = cv.seamlessClone(src, dst, mask, p)
%    blend = cv.seamlessClone(src, dst, mask, p, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
% * __dst__ Input 8-bit 3-channel image.
% * __mask__ Input 8-bit 1 or 3-channel image.
% * __p__ Point `[x,y]` in `dst` image where object is placed.
%
% ## Output
% * __blend__ Output image with the same size and type as `dst`.
%
% ## Options
% * __Method__ Cloning method that could be one of the following:
%       * __NormalClone__ (default) The power of the method is fully expressed
%             when inserting objects with complex outlines into a new
%             background.
%       * __MixedClone__ The classic method, color-based selection and alpha
%             masking might be time consuming and often leaves an undesirable
%             halo. Seamless cloning, even averaged with the original image,
%             is not effective. Mixed seamless cloning based on a loose
%             selection proves effective.
%       * __MonochromeTransfer__ Feature exchange allows the user to easily
%             replace certain features of one object by alternative features.
% * __FlipChannels__ whether to flip the order of color channels in inputs
%       `src` and `mask` and output `dst`, between MATLAB's RGB order and
%       OpenCV's BGR (input: RGB->BGR, output: BGR->RGB). default true
%
% Image editing tasks concern either global changes (color/intensity
% corrections, filters, deformations) or local changes concerned to a
% selection. Here we are interested in achieving local changes, ones that are
% restricted to a region manually selected (ROI), in a seamless and effortless
% manner. The extent of the changes ranges from slight distortions to complete
% replacement by novel content [PM03].
%
% ## References
% [PM03]:
% > Patrick Perez, Michel Gangnet, and Andrew Blake. "Poisson image editing".
% > In ACM Transactions on Graphics (TOG), volume 22, pages 313-318. ACM, 2003.
%
