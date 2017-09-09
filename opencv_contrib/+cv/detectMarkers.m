%DETECTMARKERS  Basic ArUco marker detection
%
%     [corners, ids] = cv.detectMarkers(img, dictionary)
%     [corners, ids, rejectedImgPoints] = cv.detectMarkers(img, dictionary)
%     [...] = cv.detectMarkers(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image (8-bit grayscale or color).
% * __dictionary__ indicates the type of markers that will be searched. You
%   can specify the dictionary as a cell-array that starts with the type name
%   followed by option arguments `{Type, ...}`. There are three types of
%   dictionaries available:
%   * __Predefined__ `{'Predefined', name}` or simply as a string `name`.
%     Returns one of the predefined dictionaries.
%   * __Custom__ `{'Custom', nMarkers, markerSize, 'BaseDictionary',baseDict}`.
%     Generates a new customizable marker dictionary. This creates a new
%     dictionary composed by `nMarkers` markers and each markers composed by
%     `markerSize*markerSize` bits. If `BaseDictionary` is provided, its
%     markers are directly included and the rest are generated based on them.
%     If the size of `baseDict` is higher than `nMarkers`, only the first
%     `nMarkers` in `baseDict` are taken and no new marker is added.
%   * __Manual__ `{'Manual', bytesList, markerSize, maxCorrectionBits}`.
%     Creates a dictionary/set of markers manually. It contains the inner
%     codification.
%
% ## Output
% * __corners__ cell array of detected marker corners. For each marker, its
%   four corners are provided `{{[x1,y1],[x2,y2],[x3,y3],[x4,y4]}, ..}`. The
%   order of the corners is clockwise.
% * __ids__ vector of identifiers of the detected markers. The identifier is
%   of integer type (0-based). For N detected markers, the size of ids is also
%   N. The identifiers have the same order than the markers in the `corners`
%   array.
% * __rejectedImgPoints__ contains the `corners` of those squares whose inner
%   code has not a correct codification. Useful for debugging purposes.
%
% ## Options
% * __DetectorParameters__ marker detection parameters. A struct of parameters
%   for the detection process, with the following fields:
%   * __adaptiveThreshWinSizeMin__ minimum window size for adaptive
%     thresholding before finding contours (default 3).
%   * __adaptiveThreshWinSizeMax__ maximum window size for adaptive
%     thresholding before finding contours (default 23).
%   * __adaptiveThreshWinSizeStep__ increments from `AdaptiveThreshWinSizeMin`
%     to `AdaptiveThreshWinSizeMax` during the thresholding (default 10).
%   * __adaptiveThreshConstant__ constant for adaptive thresholding before
%     finding contours (default 7)
%   * __minMarkerPerimeterRate__ determine minimum perimeter for marker
%     contour to be detected. This is defined as a rate respect to the maximum
%     dimension of the input image (default 0.03).
%   * __maxMarkerPerimeterRate__ determine maximum perimeter for marker
%     contour to be detected. This is defined as a rate respect to the maximum
%     dimension of the input image (default 4.0).
%   * __polygonalApproxAccuracyRate__ minimum accuracy during the polygonal
%     approximation process to determine which contours are squares
%     (default 0.03).
%   * __minCornerDistanceRate__ minimum distance between corners for detected
%     markers relative to its perimeter (default 0.05)
%   * __minDistanceToBorder__ minimum distance of any corner to the image
%     border for detected markers (in pixels) (default 3)
%   * __minMarkerDistanceRate__ minimum mean distance beetween two marker
%     corners to be considered similar, so that the smaller one is removed.
%     The rate is relative to the smaller perimeter of the two markers
%     (default 0.05).
%   * __cornerRefinementMethod__ corner refinement method, one of:
%     * __None__ (default) no refinement.
%     * __Subpix__ do subpixel refinement (cv.cornerSubPix).
%     * __Contour__ refine the corners using the contour-points.
%   * __cornerRefinementWinSize__ window size for the corner refinement
%     process (in pixels) (default 5).
%   * __cornerRefinementMaxIterations__ maximum number of iterations for stop
%     criteria of the corner refinement process (default 30).
%   * __cornerRefinementMinAccuracy__ minimum error for the stop cristeria of
%     the corner refinement process (default 0.1)
%   * __markerBorderBits__ number of bits of the marker border, i.e. marker
%     border width (default 1).
%   * __perpectiveRemovePixelPerCell__ number of bits (per dimension) for each
%     cell of the marker when removing the perspective (default 4).
%   * __perspectiveRemoveIgnoredMarginPerCell__ width of the margin of pixels
%     on each cell not considered for the determination of the cell bit.
%     Represents the rate respect to the total size of the cell, i.e.
%     `PerpectiveRemovePixelPerCell` (default 0.13)
%   * __maxErroneousBitsInBorderRate__ maximum number of accepted erroneous
%     bits in the border (i.e. number of allowed white bits in the border).
%     Represented as a rate respect to the total number of bits per marker
%     (default 0.35).
%   * __minOtsuStdDev__ minimun standard deviation in pixels values during the
%     decodification step to apply Otsu thresholding (otherwise, all the bits
%     are set to 0 or 1 depending on mean higher than 128 or not) (default 5.0)
%   * __errorCorrectionRate__ error correction rate respect to the maximum
%     error correction capability for each dictionary. (default 0.6).
% * __CameraMatrix__ Optional 3x3 camera calibration matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __DistCoeffs__ Optional vector of camera distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
%
% ## Inputs for Predefined Dictionary
% * __name__ name of predefined markers dictionaries/sets. Each dictionary
%   indicates the number of bits and the number of markers contained:
%   * `4x4_50`, `4x4_100`, `4x4_250`, `4x4_1000`: 4x4 bits with
%     (50|100|250|1000) markers.
%   * `5x5_50`, `5x5_100`, `5x5_250`, `5x5_1000`: 5x5 bits with
%     (50|100|250|1000) markers.
%   * `6x6_50`, `6x6_100`, `6x6_250`, `6x6_1000`: 6x6 bits with
%     (50|100|250|1000) markers.
%   * `7x7_50`, `7x7_100`, `7x7_250`, `7x7_1000`: 7x7 bits with
%     (50|100|250|1000) markers.
%   * `ArucoOriginal`: standard ArUco Library Markers. 1024 markers, 5x5 bits,
%     0 minimum distance.
%
% ## Inputs for Custom Dictionary
% * __nMarkers__ number of markers in the dictionary.
% * __markerSize__ number of bits per dimension of each markers.
% * __baseDict__ (Optional) include the markers in this dictionary at the
%   beginning. It is specified in the same format as the parent dictionary
%   (i.e. a cell-array `{Type, ...}`).
%
% ## Inputs for Manual Dictionary
% * __bytesList__ marker code information. Note that the `bytesList` is given
%   in the form of a matrix of bits which is then converted to list of bytes
%   in the 4 rotations using `Dictionary::getByteListFromBits`. It contains
%   the marker codewords where:
%   * the number of rows is the dictionary size
%   * each marker is encoded using `nbytes = ceil(markerSize*markerSize/8)`
%   * each row contains all 4 rotations of the marker, so its length is
%     `4*nbytes`
%   * `bytesList(i,k*nbytes+j)` is then the j-th byte of i-th marker, in its
%     k-th rotation.
% * __markerSize__ number of bits per dimension.
% * __maxCorrectionBits__ maximum number of bits that can be corrected.
%
% The cv.detectMarkers function performs marker detection in the input image.
% Only markers included in the specific dictionary are searched. For each
% detected marker, it returns the 2D position of its corner in the image and
% its corresponding identifier. Note that this function does not perform pose
% estimation.
%
% # ArUco Marker Detection
%
% This module is dedicated to square fiducial markers (also known as Augmented
% Reality Markers). These markers are useful for easy, fast and robust camera
% pose estimation.
%
% The main functionalities are:
%
% - Detection of markers in a image
% - Pose estimation from a single marker or from a board/set of markers
% - Detection of ChArUco board for high subpixel accuracy
% - Camera calibration from both, ArUco boards and ChArUco boards.
% - Detection of ChArUco diamond markers
%
% The implementation is based on the ArUco Library [2] by [1].
%
% This module has been originally developed by Sergio Garrido-Jurado as a
% project for Google Summer of Code 2015 (GSoC 15).
%
% ### ArUco
%
% ArUco markers are easy to detect pattern grids that yield up to 1024
% different patterns. They were built for augmented reality and later used for
% camera calibration. Since the grid uniquely orients the square, the
% detection algorithm can determing the pose of the grid.
%
% ### ChArUco
%
% ArUco markers were improved by interspersing them inside a checkerboard
% called ChArUco. Checkerboard corner intersectionsa provide more stable
% corners because the edge location bias on one square is countered by the
% opposite edge orientation in the connecting square. By interspersing ArUco
% markers inside the checkerboard, each checkerboard corner gets a label which
% enables it to be used in complex calibration or pose scenarios where you
% cannot see all the corners of the checkerboard.
%
% The smallest ChArUco board is 5 checkers and 4 markers called a
% "Diamond Marker".
%
% ## References
% [1]:
% > S. Garrido-Jurado, R. Munoz-Salinas, F. J. Madrid-Cuevas, and
% > M. J. Marin-Jimenez. 2014. "Automatic generation and detection of highly
% > reliable fiducial markers under occlusion". Pattern Recogn. 47, 6
% > (June 2014), 2280-2292. DOI=10.1016/j.patcog.2014.01.005
%
% [2]:
% > ArUco: a minimal library for Augmented Reality applications
% > based on OpenCV, [ArUco](http://www.uco.es/investiga/grupos/ava/node/26)
%
% See also: cv.estimatePoseSingleMarkers, cv.estimatePoseBoard,
%  cv.refineDetectedMarkers, cv.drawDetectedMarkers, cv.adaptiveThreshold,
%  cv.threshold, cv.findContours, cv.cornerSubPix
%
