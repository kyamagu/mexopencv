%FLOODFILL  Fills a connected component with the given color
%
%    dst = floodFill(src, seed, newVal)
%    dst = floodFill(src, seed, newVal, 'Mask', mask, ...)
%    [dst, rect, area] = floodFill(src, seed, newVal, ...)
%    [dst, mask, rect, area] = floodFill(src, seed, newVal, 'Mask', mask, ...)
%
%  Input:
%    src: Input/output 1- or 3-channel, 8-bit, or floating-point image. It is
%         modified by the function unless the 'MaskOnly' flag is set in the
%         option
%    seed: Starting point.
%    newVal: New value of the repainted domain pixels.
%  Output:
%    dst: Destination image of the same size and the same type as src.
%    rect: Optional output parameter set by the function to the minimum
%          bounding rectangle of the repainted domain.
%    area: Optional output parameter set by the function to the number of
%          filled pixels
%  Options:
%    'LoDiff': Maximal lower brightness/color difference between the currently
%              observed pixel and one of its neighbors belonging to the
%              component, or a seed pixel being added to the component.
%    'UpDiff': Maximal upper brightness/color difference between the currently
%              observed pixel and one of its neighbors belonging to the
%              component, or a seed pixel being added to the component.
%    'Connectivity': 4 or 8
%    'FixedRange': If set, the difference between the current pixel and
%              seed pixel is considered. Otherwise, the difference between
%              neighbor pixels is considered (that is, the range is
%              floating).
%    'MaskOnly': If set, the function does not change the image ( newVal
%              is ignored), but fills the mask. The flag can be used for
%              the second variant only.
%
% The functions floodFill fill a connected component starting from the
% seed point with the specified color. The connectivity is determined by
% the color/brightness closeness of the neighbor pixels.
%