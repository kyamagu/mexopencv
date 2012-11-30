%FINDCONTOURS  Finds contours in a binary image
%
%    contours = cv.findContours(image)
%    contours = cv.findContours(image, 'OptionName', optionValue, ...)
%    [contours,hierarchy] = cv.findContours(...)
%
% ## Input
% * __image__ Source, an 8-bit single-channel image. Non-zero pixels are treated
%         as 1's. Zero pixels remain 0's, so the image is treated as binary.
%
% ## Output
% * __contours__ Detected contours. Each contour is stored as a vector of points.
% * __hierarchy__ Optional output vector containing information about the image
%         topology. It has as many elements as the number of contours. For each
%         i-th contour, contours[i], the elements hierarchy[i][0], hiearchy[i][1], 
%         hiearchy[i][2], and hiearchy[i][3] are set to 0-based indices in contours 
%         of the next and previous contours at the same hierarchical level, 
%         the first child contour and the parent contour, respectively.
%         If for the i-th contour there are no next, previous, parent, or nested
%         contours, the corresponding elements of hierarchy[i] will be negative.
%
% ## Options
% * __Mode__ Contour retrieval mode.
%     * `'External'` retrieves only the extreme outer contours. It sets
%             hierarchy[i][2]=hierarchy[i][3]=-1 for all the contours.
%     * `'List'` retrieves all of the contours without establishing any
%             hierarchical relationships.     
%     * `'CComp'` retrieves all of the contours and organizes them into a
%             two-level hierarchy. At the top level, there are external
%             boundaries of the components. At the second level, there are
%             boundaries of the holes. If there is another contour inside a
%             hole of a connected component, it is still put at the top level.
%     * `'Tree'` retrieves all of the contours and reconstructs a full
%             hierarchy of nested contours
% * __Method__ Contour approximation method.
%     * `'None'` stores absolutely all the contour points. That is, any 2
%             subsequent points (x1,y1) and (x2,y2) of the contour will be
%             either horizontal, vertical or diagonal neighbors, that is,
%             max(abs(x1-x2),abs(y2-y1))==1.
%     * `'Simple'` compresses horizontal, vertical, and diagonal segments and
%             leaves only their end points. For example, an up-right
%             rectangular contour is encoded with 4 points.
%     * `'TC89_L1'`, `'TC89_KCOS'` applies one of the flavors of the Teh-Chin
%             chain approximation algorithm. See [TehChin89] for details.
% * __Offset__ Optional offset by which every contour point is shifted. This
%         is useful if the contours are extracted from the image ROI and then
%         they should be analyzed in the whole image context.
%
% The function retrieves contours from the binary image using the algorithm
% [Suzuki85]. The contours are a useful tool for shape analysis and object
% detection and recognition.
%
