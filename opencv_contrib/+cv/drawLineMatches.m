%DRAWLINEMATCHES  Draws the found matches of keylines from two images
%
%     outImg = cv.drawLineMatches(img1, keypoints1, img2, keypoints2, matches1to2)
%     outImg = cv.drawLineMatches(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img1__ First image.
% * __keypoints1__ keylines extracted from first image.
% * __img2__ Second image.
% * __keypoints2__ keylines extracted from second image.
% * __matches1to2__ vector of matches.
%
% ## Output
% * __outImg__ output matrix to draw on.
%
% ## Options
% * __MatchColor__ drawing color for matches (chosen randomly in case of
%   default value). default [-1,-1,-1,-1].
% * __SingleLineColor__ drawing color for keylines (chosen randomly in case of
%   default value). default [-1,-1,-1,-1].
% * __MatchesMask__ mask to indicate which matches must be drawn.
%   default empty.
% * __NotDrawSingleLines__ Single keylines will not be drawn. default false
% * __OutImage__ If set, matches will be drawn on existing content of output
%   image, otherwise source images are used instead. Not set by default.
%
% If both `MatchColor` and `SingleLineColor` are set to their default values,
% function draws matched lines and line connecting them with same color.
%
% See also: cv.drawMatches, cv.drawKeylines, cv.BinaryDescriptor
%
