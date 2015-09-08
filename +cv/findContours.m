%FINDCONTOURS  Finds contours in a binary image
%
%    contours = cv.findContours(image)
%    contours = cv.findContours(image, 'OptionName', optionValue, ...)
%    [contours,hierarchy] = cv.findContours(...)
%
% ## Input
% * __image__ Source, an 8-bit single-channel image. Non-zero pixels are
%       treated as 1's. Zero pixels remain 0's, so the image is treated as
%       binary. You can use cv.compare, cv.inRange, cv.threshold,
%       cv.adaptiveThreshold, cv.Canny, and others to create a binary image
%       out of a grayscale or color one. If mode equals to `CComp` or
%       `FloodFill`, the input can also be a 32-bit integer image of labels
%       (`int32` class).
%
% ## Output
% * __contours__ Detected contours. Each contour is stored as a vector of
%       points. A cell array of cell array of 2D integer points, of the form:
%       `{{[x,y],[x,y],...}, ...}`.
% * __hierarchy__ Optional output vector containing information about the
%       image topology. It has as many elements as the number of contours.
%       For each i-th contour, `contours{i}`, the elements `hierarchy{i}(1)`,
%       `hierarchy{i}(2)`, `hierarchy{i}(3)`, and `hierarchy{i}(4)` are set to
%       0-based indices in `contours` of the next and previous contours at the
%       same hierarchical level, the first child contour and the parent
%       contour, respectively. If for the i-th contour there are no next,
%       previous, parent, or nested contours, the corresponding elements of
%       `hierarchy{i}` will be negative. A cell array of 4-element integer
%       vectors of the form `{[next,prev,child,parent], ...}`.
%
% ## Options
% * __Mode__ Contour retrieval mode,  default is 'External'. One of:
%     * __External__ retrieves only the extreme outer contours. It sets
%           `hierarchy{i}(3)=hierarchy{i}(4)=-1` for all the contours.
%     * __List__ retrieves all of the contours without establishing any
%           hierarchical relationships.
%     * __CComp__ retrieves all of the contours and organizes them into a
%           two-level hierarchy. At the top level, there are external
%           boundaries of the components. At the second level, there are
%           boundaries of the holes. If there is another contour inside a
%           hole of a connected component, it is still put at the top level.
%     * __Tree__ retrieves all of the contours and reconstructs a full
%           hierarchy of nested contours
%     * __FloodFill__ connected components of a multi-level image (only valid
%           for 32-bit integer images).
% * __Method__ Contour approximation method, default is 'None'. One of:
%     * __None__ stores absolutely all the contour points. That is, any 2
%           subsequent points `(x1,y1)` and `(x2,y2)` of the contour will be
%           either horizontal, vertical or diagonal neighbors, that is,
%           `max(abs(x1-x2),abs(y2-y1))==1`.
%     * __Simple__ compresses horizontal, vertical, and diagonal segments and
%           leaves only their end points. For example, an up-right rectangular
%           contour is encoded with 4 points.
%     * __TC89_L1__, __TC89_KCOS__ applies one of the flavors of the Teh-Chin
%           chain approximation algorithm [TehChin89] (1-curvature or
%           k-cosine curvature).
% * __Offset__ Optional offset by which every contour point is shifted. This
%       is useful if the contours are extracted from the image ROI and then
%       they should be analyzed in the whole image context. default [0,0]
%
% The function retrieves contours from the binary image using the algorithm
% [Suzuki85]. The contours are a useful tool for shape analysis and object
% detection and recognition.
%
% ## Note
% The function does not take into account 1-pixel border of the image (it's
% filled with 0's and used for neighbor analysis in the algorithm), therefore
% the contours touching the image border will be clipped.
%
% ## References
% [Suzuki85]:
% > Satoshi Suzuki and others. "Topological structural analysis of digitized
% > binary images by border following". Computer Vision, Graphics, and Image
% > Processing, 30(1):32-46, 1985.
%
% [TehChin89]:
% > C-H Teh and Roland T. Chin. "On the detection of dominant points on
% > digital curves". Pattern Analysis and Machine Intelligence, IEEE
% > Transactions on, 11(8):859-872, 1989.
%
% See also: cv.drawContours, bwboundaries, bwconncomp
%
