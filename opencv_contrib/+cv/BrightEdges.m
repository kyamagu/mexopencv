%BRIGHTEDGES  Bright edges detector
%
%     edge = cv.BrightEdges(img)
%     edge = cv.BrightEdges(img, 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input color image.
%
% ## Output
% * __edge__ output edge image.
%
% ## Options
% * __Contrast__ default 1
% * __ShortRange__ default 3
% * __LongRange__ default 9
%
% The function implements a new way of detecting edges used is low resolution
% image object recognition in real projects (e.g. 50cm per pixel). It corrects
% surfaces for objects partially under a lighting shadow, and reveal low
% visibility edges. The result is used to feed further object detection
% processes particularly in context where small edges or details are important
% for object discrimination.
%
% The function provides an implementation of an equalized absolute difference
% of blurs, and an optional further treatment to contrast edges based on
% finding local minimum along at least two directions. The local minimum
% detection contrast is a parameter, using 10 as default (10 on 255 maximum).
% The kernel size for the gaussian and the average blur can be passed as
% parameters too.
%
% See also: cv.Canny, cv.blur, cv.GaussianBlur, cv.equalizeHist
%
