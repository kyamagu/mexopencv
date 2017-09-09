%DRAWMARKERARUCO  Draw a canonical marker image
%
%     img = cv.drawMarkerAruco(dictionary, id, sidePixels)
%     img = cv.drawMarkerAruco(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __dictionary__ dictionary of markers indicating the type of markers.
% * __id__ identifier of the marker that will be returned. It has to be a
%   valid id in the specified dictionary (0-based).
% * __sidePixels__ size of the image in pixels.
%
% ## Output
% * __img__ output image with the marker, of size `sidePixels-by-sidePixels`.
%
% ## Options
% * __BorderBits__ width of the marker border. default 1
%
% This function returns a marker image in its canonical form (i.e. ready to be
% printed).
%
% See also: cv.estimatePoseBoard, cv.drawPlanarBoard, cv.drawCharucoBoard
%
