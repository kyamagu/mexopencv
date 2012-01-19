%INPAINT  Restores the selected region in an image using the region neighborhood
%
%    dst = cv.inpaint(src, mask)
%    dst = cv.inpaint(src, mask, 'Method', 'Telea', ...)
%
%  Input:
%    src: Input 8-bit 1-channel or 3-channel image.
%	 mask: Inpainting mask, 8-bit 1-channel image. Non-zero pixels indicate the
%          area that needs to be inpainted.
%  Output:
%    dst: Output image with the same size and type as src.
%  Options:
%    'Radius': Radius of a circlular neighborhood of each point inpainted that
%              is considered by the algorithm.
%	 'Method': Inpainting method that could be one of the following:
%       'NS': Navier-Stokes based method.
%       'Telea': Method by Alexandru Telea [Telea04].
%
% The function reconstructs the selected image area from the pixel near the
% area boundary. The function may be used to remove dust and scratches from a
% scanned photo, or to remove undesirable objects from still images or video.
% See http://en.wikipedia.org/wiki/Inpainting for more details.
%