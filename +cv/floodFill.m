%FLOODFILL  Fills a connected component with the given color
%
%    dst = cv.floodFill(src, seed, newVal)
%    dst = cv.floodFill(src, seed, newVal, 'Mask', mask, ...)
%    [dst, rect, area] = cv.floodFill(src, seed, newVal, ...)
%    [dst, mask, rect, area] = cv.floodFill(src, seed, newVal, 'Mask', mask, ...)
%
% ## Input
% * __src__ Input/output 1- or 3-channel, 8-bit, or floating-point image. It is
%        modified by the function unless the 'MaskOnly' flag is set in the
%        option
% * __seed__ Starting point.
% * __newVal__ New value of the repainted domain pixels.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as src.
% * __rect__ Optional output parameter set by the function to the minimum
%        bounding rectangle of the repainted domain.
% * __area__ Optional output parameter set by the function to the number of
%        filled pixels
%
% ## Options
% * __LoDiff__ Maximal lower brightness/color difference between the currently
%        observed pixel and one of its neighbors belonging to the
%        component, or a seed pixel being added to the component.
% * __UpDiff__ Maximal upper brightness/color difference between the currently
%        observed pixel and one of its neighbors belonging to the
%        component, or a seed pixel being added to the component.
% * __Connectivity__ 4 or 8
% * __FixedRange__ If set, the difference between the current pixel and
%        seed pixel is considered. Otherwise, the difference between
%        neighbor pixels is considered (that is, the range is
%        floating).
% * __MaskOnly__ If set, the function does not change the image ( newVal
%        is ignored), but fills the mask. The flag can be used for
%        the second variant only.
%
% The functions floodFill fill a connected component starting from the
% seed point with the specified color. The connectivity is determined by
% the color/brightness closeness of the neighbor pixels.
%
