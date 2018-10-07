% mexopencv
% Version 3.4.1 (R2018a) 01-October-2018
%
%% opencv: Main Modules
%
% core: Core Functionality
%   cv.borderInterpolate                - Computes the source location of an extrapolated pixel
%   cv.copyMakeBorder                   - Forms a border around an image
%   cv.add                              - Calculates the per-element sum of two arrays or an array and a scalar
%   cv.subtract                         - Calculates the per-element difference between two arrays or array and a scalar
%   cv.multiply                         - Calculates the per-element scaled product of two arrays
%   cv.divide                           - Performs per-element division of two arrays or a scalar by an array
%   cv.addWeighted                      - Calculates the weighted sum of two arrays
%   cv.convertScaleAbs                  - Scales, calculates absolute values, and converts the result to 8-bit
%   cv.convertFp16                      - Converts an array to half precision floating number
%   cv.LUT                              - Performs a look-up table transform of an array
%   cv.norm                             - Calculates absolute array norm, absolute difference norm, or relative difference norm
%   cv.PSNR                             - Computes the Peak Signal-to-Noise Ratio (PSNR) image quality metric
%   cv.batchDistance                    - Naive nearest neighbor finder
%   cv.normalize                        - Normalizes the norm or value range of an array
%   cv.flip                             - Flips a 2D array around vertical, horizontal, or both axes
%   cv.rotate                           - Rotates a 2D array in multiples of 90 degrees
%   cv.bitwise_and                      - Calculates the per-element bit-wise conjunction of two arrays or an array and a scalar
%   cv.bitwise_or                       - Calculates the per-element bit-wise disjunction of two arrays or an array and a scalar
%   cv.bitwise_xor                      - Calculates the per-element bit-wise "exclusive or" operation on two arrays or an array and a scalar
%   cv.bitwise_not                      - Inverts every bit of an array
%   cv.absdiff                          - Calculates the per-element absolute difference between two arrays or between an array and a scalar
%   cv.inRange                          - Checks if array elements lie between the elements of two other arrays
%   cv.compare                          - Performs the per-element comparison of two arrays or an array and scalar value
%   cv.polarToCart                      - Calculates x and y coordinates of 2D vectors from their magnitude and angle
%   cv.cartToPolar                      - Calculates the magnitude and angle of 2D vectors
%   cv.phase                            - Calculates the rotation angle of 2D vectors
%   cv.magnitude                        - Calculates the magnitude of 2D vectors
%   cv.transform                        - Performs the matrix transformation of every array element
%   cv.perspectiveTransform             - Performs the perspective matrix transformation of vectors
%   cv.invert                           - Finds the inverse or pseudo-inverse of a matrix
%   cv.solve                            - Solves one or more linear systems or least-squares problems
%   cv.eigen                            - Calculates eigenvalues and eigenvectors of a symmetric matrix
%   cv.eigenNonSymmetric                - Calculates eigenvalues and eigenvectors of a non-symmetric matrix (real eigenvalues only)
%   cv.calcCovarMatrix                  - Calculates the covariance matrix of a set of vectors
%   cv.Mahalanobis                      - Calculates the Mahalanobis distance between two vectors
%   cv.dft                              - Performs a forward or inverse Discrete Fourier transform of a 1D or 2D floating-point array
%   cv.dct                              - Performs a forward or inverse discrete Cosine transform of 1D or 2D array
%   cv.mulSpectrums                     - Performs the per-element multiplication of two Fourier spectrums
%   cv.getOptimalDFTSize                - Returns the optimal DFT size for a given vector size
%   cv.setRNGSeed                       - Sets state of default random number generator
%   cv.PCA                              - Principal Component Analysis class
%   cv.LDA                              - Linear Discriminant Analysis
%   cv.SVD                              - Singular Value Decomposition
%   cv.kmeans                           - Finds centers of clusters and groups input samples around the clusters
%   cv.Rect                             - Class for 2D rectangles
%   cv.RotatedRect                      - The class represents rotated (i.e. not up-right) rectangles on a plane
%   cv.copyTo                           - Copies the matrix to another one
%   cv.convertTo                        - Converts an array to another data type with optional scaling
%   cv.FileStorage                      - Reading from or writing to a XML/YAML/JSON file storage
%   cv.tempfile                         - Return name of a temporary file
%   cv.glob                             - Find all pathnames matching a specified pattern
%   cv.Utils                            - Utility and system information functions
%   cv.getBuildInformation              - Returns OpenCV build information
%   cv.TickMeter                        - A class to measure passing time
%   cv.DownhillSolver                   - Non-linear non-constrained minimization of a function
%   cv.ConjGradSolver                   - Non-linear non-constrained minimization of a function with known gradient
%   cv.solveLP                          - Solve given (non-integer) linear programming problem using the Simplex Algorithm
%
% imgproc: Image Processing
%   cv.GeneralizedHoughBallard          - Generalized Hough transform
%   cv.GeneralizedHoughGuil             - Generalized Hough transform
%   cv.CLAHE                            - Contrast Limited Adaptive Histogram Equalization
%   cv.Subdiv2D                         - Delaunay triangulation and Voronoi tessellation
%   cv.LineSegmentDetector              - Line segment detector class
%   cv.getGaussianKernel                - Returns Gaussian filter coefficients
%   cv.getDerivKernels                  - Returns filter coefficients for computing spatial image derivatives
%   cv.getGaborKernel                   - Returns Gabor filter coefficients
%   cv.getStructuringElement            - Returns a structuring element of the specified size and shape for morphological operations
%   cv.medianBlur                       - Blurs an image using the median filter
%   cv.GaussianBlur                     - Smooths an image using a Gaussian filter
%   cv.bilateralFilter                  - Applies the bilateral filter to an image
%   cv.boxFilter                        - Blurs an image using the box filter
%   cv.sqrBoxFilter                     - Calculates the normalized sum of squares of the pixel values overlapping the filter
%   cv.blur                             - Smooths an image using the normalized box filter
%   cv.filter2D                         - Convolves an image with the kernel
%   cv.sepFilter2D                      - Applies a separable linear filter to an image
%   cv.Sobel                            - Calculates the first, second, third, or mixed image derivatives using an extended Sobel operator
%   cv.spatialGradient                  - Calculates the first order image derivative in both x and y using a Sobel operator
%   cv.Scharr                           - Calculates the first x- or y- image derivative using Scharr operator
%   cv.Laplacian                        - Calculates the Laplacian of an image
%   cv.Canny                            - Finds edges in an image using the Canny algorithm
%   cv.Canny2                           - Finds edges in an image using the Canny algorithm with custom image gradient
%   cv.cornerMinEigenVal                - Calculates the minimal eigenvalue of gradient matrices for corner detection
%   cv.cornerHarris                     - Harris corner detector
%   cv.cornerEigenValsAndVecs           - Calculates eigenvalues and eigenvectors of image blocks for corner detection
%   cv.preCornerDetect                  - Calculates a feature map for corner detection
%   cv.cornerSubPix                     - Refines the corner locations
%   cv.goodFeaturesToTrack              - Determines strong corners on an image
%   cv.HoughLines                       - Finds lines in a binary image using the standard Hough transform
%   cv.HoughLinesP                      - Finds line segments in a binary image using the probabilistic Hough transform
%   cv.HoughLinesPointSet               - Finds lines in a set of points using the standard Hough transform
%   cv.HoughCircles                     - Finds circles in a grayscale image using the Hough transform
%   cv.erode                            - Erodes an image by using a specific structuring element
%   cv.dilate                           - Dilates an image by using a specific structuring element
%   cv.morphologyEx                     - Performs advanced morphological transformations
%   cv.resize                           - Resizes an image
%   cv.warpAffine                       - Applies an affine transformation to an image
%   cv.warpPerspective                  - Applies a perspective transformation to an image
%   cv.remap                            - Applies a generic geometrical transformation to an image
%   cv.convertMaps                      - Converts image transformation maps from one representation to another
%   cv.getRotationMatrix2D              - Calculates an affine matrix of 2D rotation
%   cv.getAffineTransform               - Calculates an affine transform from three pairs of corresponding points
%   cv.invertAffineTransform            - Inverts an affine transformation
%   cv.getPerspectiveTransform          - Calculates a perspective transform from four pairs of the corresponding points
%   cv.getRectSubPix                    - Retrieves a pixel rectangle from an image with sub-pixel accuracy
%   cv.logPolar                         - Remaps an image to semilog-polar coordinates space
%   cv.linearPolar                      - Remaps an image to polar coordinates space
%   cv.integral                         - Calculates the integral of an image
%   cv.accumulate                       - Adds an image to the accumulator image
%   cv.accumulateSquare                 - Adds the square of a source image to the accumulator image
%   cv.accumulateProduct                - Adds the per-element product of two input images to the accumulator
%   cv.accumulateWeighted               - Updates a running average
%   cv.phaseCorrelate                   - Detect translational shifts that occur between two images
%   cv.createHanningWindow              - Computes a Hanning window coefficients in two dimensions
%   cv.threshold                        - Applies a fixed-level threshold to each array element
%   cv.adaptiveThreshold                - Applies an adaptive threshold to an array
%   cv.pyrDown                          - Blurs an image and downsamples it
%   cv.pyrUp                            - Upsamples an image and then blurs it
%   cv.buildPyramid                     - Constructs the Gaussian pyramid for an image
%   cv.undistort                        - Transforms an image to compensate for lens distortion
%   cv.initUndistortRectifyMap          - Computes the undistortion and rectification transformation map
%   cv.initWideAngleProjMap             - Initializes maps for cv.remap for wide-angle
%   cv.getDefaultNewCameraMatrix        - Returns the default new camera matrix
%   cv.undistortPoints                  - Computes the ideal point coordinates from the observed point coordinates
%   cv.calcHist                         - Calculates a histogram of a set of arrays
%   cv.calcBackProject                  - Calculates the back projection of a histogram
%   cv.compareHist                      - Compares two histograms
%   cv.equalizeHist                     - Equalizes the histogram of a grayscale image
%   cv.EMD                              - Computes the "minimal work" distance between two weighted point configurations
%   cv.watershed                        - Performs a marker-based image segmentation using the watershed algorithm
%   cv.pyrMeanShiftFiltering            - Performs initial step of meanshift segmentation of an image
%   cv.grabCut                          - Runs the GrabCut algorithm
%   cv.distanceTransform                - Calculates the distance to the closest zero pixel for each pixel of the source image
%   cv.floodFill                        - Fills a connected component with the given color
%   cv.cvtColor                         - Converts an image from one color space to another
%   cv.cvtColorTwoPlane                 - Dual-plane color conversion modes
%   cv.demosaicing                      - Demosaicing algorithm
%   cv.moments                          - Calculates all of the moments up to the third order of a polygon or rasterized shape
%   cv.HuMoments                        - Calculates seven Hu invariants
%   cv.matchTemplate                    - Compares a template against overlapped image regions
%   cv.connectedComponents              - Computes the connected components labeled image of boolean image
%   cv.findContours                     - Finds contours in a binary image
%   cv.approxPolyDP                     - Approximates a polygonal curve(s) with the specified precision
%   cv.arcLength                        - Calculates a contour perimeter or a curve length
%   cv.boundingRect                     - Calculates the up-right bounding rectangle of a point set
%   cv.contourArea                      - Calculates a contour area
%   cv.minAreaRect                      - Finds a rotated rectangle of the minimum area enclosing the input 2D point set
%   cv.boxPoints                        - Finds the four vertices of a rotated rectangle
%   cv.minEnclosingCircle               - Finds a circle of the minimum area enclosing a 2D point set
%   cv.minEnclosingTriangle             - Finds a triangle of minimum area enclosing a 2D point set and returns its area
%   cv.matchShapes                      - Compares two shapes
%   cv.convexHull                       - Finds the convex hull of a point set
%   cv.convexityDefects                 - Finds the convexity defects of a contour
%   cv.isContourConvex                  - Tests a contour convexity
%   cv.intersectConvexConvex            - Finds intersection of two convex polygons
%   cv.fitEllipse                       - Fits an ellipse around a set of 2D points
%   cv.fitLine                          - Fits a line to a 2D or 3D point set
%   cv.pointPolygonTest                 - Performs a point-in-contour test
%   cv.rotatedRectangleIntersection     - Finds out if there is any intersection between two rotated rectangles
%   cv.blendLinear                      - Performs linear blending of two images
%   cv.applyColorMap                    - Applies a GNU Octave/MATLAB equivalent colormap on a given image
%   cv.line                             - Draws a line segment connecting two points
%   cv.arrowedLine                      - Draws an arrow segment pointing from the first point to the second one
%   cv.rectangle                        - Draws a simple, thick, or filled up-right rectangle
%   cv.circle                           - Draws a circle
%   cv.ellipse                          - Draws a simple or thick elliptic arc or fills an ellipse sector
%   cv.drawMarker                       - Draws a marker on a predefined position in an image
%   cv.fillConvexPoly                   - Fills a convex polygon
%   cv.fillPoly                         - Fills the area bounded by one or more polygons
%   cv.polylines                        - Draws several polygonal curves
%   cv.drawContours                     - Draws contours outlines or filled contours
%   cv.clipLine                         - Clips the line against the image rectangle
%   cv.ellipse2Poly                     - Approximates an elliptic arc with a polyline
%   cv.putText                          - Draws a text string
%   cv.getTextSize                      - Calculates the width and height of a text string
%   cv.getFontScaleFromHeight           - Calculates the font-specific size to use to achieve a given height in pixels
%   cv.LineIterator                     - Raster line iterator
%
% imgcodecs: Image File Reading and Writing
%   cv.imread                           - Loads an image from a file
%   cv.imreadmulti                      - Loads a multi-page image from a file
%   cv.imwrite                          - Saves an image to a specified file
%   cv.imdecode                         - Reads an image from a buffer in memory
%   cv.imencode                         - Encodes an image into a memory buffer
%
% videoio: Video I/O
%   cv.VideoCapture                     - Class for video capturing from video files or cameras
%   cv.VideoWriter                      - Video Writer class
%
% video: Video Analysis
%   cv.CamShift                         - Finds an object center, size, and orientation
%   cv.meanShift                        - Finds an object on a back projection image
%   cv.buildOpticalFlowPyramid          - Constructs the image pyramid which can be passed to cv.calcOpticalFlowPyrLK
%   cv.calcOpticalFlowPyrLK             - Calculates an optical flow for a sparse feature set using the iterative Lucas-Kanade method with pyramids
%   cv.calcOpticalFlowFarneback         - Computes a dense optical flow using the Gunnar Farneback's algorithm
%   cv.estimateRigidTransform           - Computes an optimal affine transformation between two 2D point sets
%   cv.findTransformECC                 - Finds the geometric transform (warp) between two images in terms of the ECC criterion
%   cv.KalmanFilter                     - Kalman filter class
%   cv.DualTVL1OpticalFlow              - "Dual TV L1" Optical Flow Algorithm
%   cv.FarnebackOpticalFlow             - Dense optical flow using the Gunnar Farneback's algorithm
%   cv.SparsePyrLKOpticalFlow           - Class used for calculating a sparse optical flow
%   cv.BackgroundSubtractorMOG2         - Gaussian Mixture-based Background/Foreground Segmentation Algorithm
%   cv.BackgroundSubtractorKNN          - K-nearest neighbours based Background/Foreground Segmentation Algorithm
%
% calib3d: Camera Calibration and 3D Reconstruction
%   cv.Rodrigues                        - Converts a rotation matrix to a rotation vector or vice versa
%   cv.findHomography                   - Finds a perspective transformation between two planes
%   cv.RQDecomp3x3                      - Computes an RQ decomposition of 3x3 matrices
%   cv.decomposeProjectionMatrix        - Decomposes a projection matrix into a rotation matrix and a camera matrix
%   cv.matMulDeriv                      - Computes partial derivatives of the matrix product for each multiplied matrix
%   cv.composeRT                        - Combines two rotation-and-shift transformations
%   cv.projectPoints                    - Projects 3D points to an image plane
%   cv.solvePnP                         - Finds an object pose from 3D-2D point correspondences
%   cv.solvePnPRansac                   - Finds an object pose from 3D-2D point correspondences using the RANSAC scheme
%   cv.solveP3P                         - Finds an object pose from 3 3D-2D point correspondences
%   cv.initCameraMatrix2D               - Finds an initial camera matrix from 3D-2D point correspondences
%   cv.findChessboardCorners            - Finds the positions of internal corners of the chessboard
%   cv.find4QuadCornerSubpix            - Finds subpixel-accurate positions of the chessboard corners
%   cv.drawChessboardCorners            - Renders the detected chessboard corners
%   cv.findCirclesGrid                  - Finds the centers in the grid of circles
%   cv.calibrateCamera                  - Finds the camera intrinsic and extrinsic parameters from several views of a calibration pattern
%   cv.calibrationMatrixValues          - Computes useful camera characteristics from the camera matrix
%   cv.stereoCalibrate                  - Calibrates the stereo camera
%   cv.stereoRectify                    - Computes rectification transforms for each head of a calibrated stereo camera
%   cv.stereoRectifyUncalibrated        - Computes a rectification transform for an uncalibrated stereo camera
%   cv.rectify3Collinear                - Computes the rectification transformations for 3-head camera, where all the heads are on the same line
%   cv.getOptimalNewCameraMatrix        - Returns the new camera matrix based on the free scaling parameter
%   cv.convertPointsToHomogeneous       - Converts points from Euclidean to homogeneous space
%   cv.convertPointsFromHomogeneous     - Converts points from homogeneous to Euclidean space
%   cv.findFundamentalMat               - Calculates a fundamental matrix from the corresponding points in two images
%   cv.findEssentialMat                 - Calculates an essential matrix from the corresponding points in two images
%   cv.decomposeEssentialMat            - Decompose an essential matrix to possible rotations and translation
%   cv.recoverPose                      - Recover relative camera rotation and translation from an estimated essential matrix and the corresponding points in two images, using cheirality check
%   cv.computeCorrespondEpilines        - For points in an image of a stereo pair, computes the corresponding epilines in the other image
%   cv.triangulatePoints                - Reconstructs points by triangulation
%   cv.correctMatches                   - Refines coordinates of corresponding points
%   cv.filterSpeckles                   - Filters off small noise blobs (speckles) in the disparity map
%   cv.getValidDisparityROI             - Computes valid disparity ROI from the valid ROIs of the rectified images
%   cv.validateDisparity                - Validates disparity using the left-right check
%   cv.reprojectImageTo3D               - Reprojects a disparity image to 3D space
%   cv.sampsonDistance                  - Calculates the Sampson Distance between two points
%   cv.estimateAffine3D                 - Computes an optimal affine transformation between two 3D point sets
%   cv.estimateAffine2D                 - Computes an optimal affine transformation between two 2D point sets
%   cv.estimateAffinePartial2D          - Computes an optimal limited affine transformation with 4 degrees of freedom between two 2D point sets
%   cv.decomposeHomographyMat           - Decompose a homography matrix to rotation(s), translation(s) and plane normal(s)
%   cv.StereoBM                         - Class for computing stereo correspondence using the block matching algorithm
%   cv.StereoSGBM                       - Class for computing stereo correspondence using the semi-global block matching algorithm
%   cv.fisheyeProjectPoints             - Projects points using fisheye model
%   cv.fisheyeDistortPoints             - Distorts 2D points using fisheye model
%   cv.fisheyeUndistortPoints           - Undistorts 2D points using fisheye model
%   cv.fisheyeInitUndistortRectifyMap   - Computes undistortion and rectification maps (fisheye)
%   cv.fisheyeUndistortImage            - Transforms an image to compensate for fisheye lens distortion
%   cv.fisheyeEstimateNewCameraMatrixForUndistortRectify - Estimates new camera matrix for undistortion or rectification (fisheye)
%   cv.fisheyeCalibrate                 - Performs camera calibration (fisheye)
%   cv.fisheyeStereoRectify             - Stereo rectification for fisheye camera model
%   cv.fisheyeStereoCalibrate           - Performs stereo calibration (fisheye)
%
% features2d: 2D Features Framework
%   cv.KeyPointsFilter                  - Methods to filter a vector of keypoints
%   cv.FeatureDetector                  - Common interface of 2D image Feature Detectors
%   cv.DescriptorExtractor              - Common interface of 2D image Descriptor Extractors
%   cv.BRISK                            - Class implementing the BRISK keypoint detector and descriptor extractor
%   cv.ORB                              - Class implementing the ORB (oriented BRIEF) keypoint detector and descriptor extractor
%   cv.MSER                             - Maximally Stable Extremal Region extractor
%   cv.FAST                             - Detects corners using the FAST algorithm
%   cv.FastFeatureDetector              - Wrapping class for feature detection using the FAST method
%   cv.AGAST                            - Detects corners using the AGAST algorithm
%   cv.AgastFeatureDetector             - Wrapping class for feature detection using the AGAST method
%   cv.GFTTDetector                     - Wrapping class for feature detection using the goodFeaturesToTrack function
%   cv.SimpleBlobDetector               - Class for extracting blobs from an image
%   cv.KAZE                             - Class implementing the KAZE keypoint detector and descriptor extractor
%   cv.AKAZE                            - Class implementing the AKAZE keypoint detector and descriptor extractor
%   cv.DescriptorMatcher                - Common interface for matching keypoint descriptors
%   cv.drawKeypoints                    - Draws keypoints
%   cv.drawMatches                      - Draws the found matches of keypoints from two images
%   cv.evaluateFeatureDetector          - Evaluates a feature detector
%   cv.computeRecallPrecisionCurve      - Evaluate a descriptor extractor by computing precision/recall curve
%   cv.BOWKMeansTrainer                 - KMeans-based class to train visual vocabulary using the bag of visual words approach
%   cv.BOWImgDescriptorExtractor        - Class to compute an image descriptor using the bag of visual words
%
% objdetect: Object Detection
%   cv.SimilarRects                     - Class for grouping object candidates, detected by Cascade Classifier, HOG etc.
%   cv.groupRectangles                  - Groups the object candidate rectangles
%   cv.groupRectangles_meanshift        - Groups the object candidate rectangles using meanshift
%   cv.CascadeClassifier                - Haar Feature-based Cascade Classifier for Object Detection
%   cv.HOGDescriptor                    - Histogram of Oriented Gaussian (HOG) descriptor and object detector
%   cv.DetectionBasedTracker            - Detection-based tracker
%
% dnn: Deep Neural Network
%   cv.Net                              - Create and manipulate comprehensive artificial neural networks
%
% ml: Machine Learning
%   cv.NormalBayesClassifier            - Bayes classifier for normally distributed data
%   cv.KNearest                         - The class implements K-Nearest Neighbors model
%   cv.SVM                              - Support Vector Machines
%   cv.EM                               - Expectation Maximization Algorithm
%   cv.DTrees                           - Decision Trees
%   cv.RTrees                           - Random Trees
%   cv.Boost                            - Boosted tree classifier derived from cv.DTrees
%   cv.ANN_MLP                          - Artificial Neural Networks - Multi-Layer Perceptrons
%   cv.LogisticRegression               - Logistic Regression classifier
%   cv.SVMSGD                           - Stochastic Gradient Descent SVM classifier
%   cv.randMVNormal                     - Generates sample from multivariate normal distribution
%   cv.createConcentricSpheresTestSet   - Creates test set
%
% photo: Computational Photography
%   cv.inpaint                          - Restores the selected region in an image using the region neighborhood
%   cv.fastNlMeansDenoising             - Image denoising using Non-local Means Denoising algorithm
%   cv.fastNlMeansDenoisingColored      - Modification of fastNlMeansDenoising function for colored images
%   cv.fastNlMeansDenoisingMulti        - Modification of fastNlMeansDenoising function for colored images sequences
%   cv.fastNlMeansDenoisingColoredMulti - Modification of fastNlMeansDenoisingMulti function for colored images sequences
%   cv.denoise_TVL1                     - Primal-Dual algorithm to perform image denoising
%   cv.Tonemap                          - Tonemapping algorithm used to map HDR image to 8-bit range
%   cv.TonemapDrago                     - Tonemapping algorithm used to map HDR image to 8-bit range
%   cv.TonemapDurand                    - Tonemapping algorithm used to map HDR image to 8-bit range
%   cv.TonemapReinhard                  - Tonemapping algorithm used to map HDR image to 8-bit range
%   cv.TonemapMantiuk                   - Tonemapping algorithm used to map HDR image to 8-bit range
%   cv.AlignMTB                         - Aligns images of the same scene with different exposures
%   cv.CalibrateDebevec                 - Camera Response Calibration algorithm
%   cv.CalibrateRobertson               - Camera Response Calibration algorithm
%   cv.MergeDebevec                     - Merge exposure sequence to a single image
%   cv.MergeMertens                     - Merge exposure sequence to a single image
%   cv.MergeRobertson                   - Merge exposure sequence to a single image
%   cv.decolor                          - Transforms a color image to a grayscale image
%   cv.seamlessClone                    - Seamless Cloning
%   cv.colorChange                      - Color Change
%   cv.illuminationChange               - Illumination Change
%   cv.textureFlattening                - Texture Flattening
%   cv.edgePreservingFilter             - Edge-preserving smoothing filter
%   cv.detailEnhance                    - This filter enhances the details of a particular image
%   cv.pencilSketch                     - Pencil-like non-photorealistic line drawing
%   cv.stylization                      - Stylization filter
%
% stitching: Images Stitching
%   cv.RotationWarper                   - Rotation-only model image warper
%   cv.FeaturesFinder                   - Feature finders class
%   cv.FeaturesMatcher                  - Feature matchers class
%   cv.Estimator                        - Rotation estimator base class
%   cv.BundleAdjuster                   - Class for all camera parameters refinement methods
%   cv.ExposureCompensator              - Class for all exposure compensators
%   cv.SeamFinder                       - Class for all seam estimators
%   cv.Blender                          - Class for all image blenders
%   cv.Timelapser                       - Timelapser class
%   cv.Stitcher                         - High level image stitcher
%
% shape: Shape Distance and Matching
%   cv.EMDL1                            - Computes the "minimal work" distance between two weighted point configurations
%   cv.ShapeTransformer                 - Base class for shape transformation algorithms
%   cv.ShapeContextDistanceExtractor    - Implementation of the Shape Context descriptor and matching algorithm
%   cv.HausdorffDistanceExtractor       - A simple Hausdorff distance measure between shapes defined by contours
%
% superres: Super Resolution
%   cv.SuperResolution                  - Class for a whole family of Super Resolution algorithms
%
% videostab: Video Stabilization
%   cv.estimateGlobalMotionLeastSquares - Estimates best global motion between two 2D point clouds in the least-squares sense
%   cv.estimateGlobalMotionRansac       - Estimates best global motion between two 2D point clouds robustly (using RANSAC method)
%   cv.calcBlurriness                   - Calculate image blurriness
%   cv.OnePassStabilizer                - A one-pass video stabilizer
%   cv.TwoPassStabilizer                - A two-pass video stabilizer
%
%% opencv_contrib: Extra Modules
%
% aruco: ArUco Marker Detection
%   cv.dictionaryDump                   - Dump dictionary (aruco)
%   cv.detectMarkers                    - Basic ArUco marker detection
%   cv.estimatePoseSingleMarkers        - Pose estimation for single markers
%   cv.boardDump                        - Dump board (aruco)
%   cv.estimatePoseBoard                - Pose estimation for a board of markers
%   cv.refineDetectedMarkers            - Refind not detected markers based on the already detected and the board layout
%   cv.drawDetectedMarkers              - Draw detected markers in image
%   cv.drawAxis                         - Draw coordinate system axis from pose estimation
%   cv.drawMarkerAruco                  - Draw a canonical marker image
%   cv.drawPlanarBoard                  - Draw a planar board
%   cv.calibrateCameraAruco             - Calibrate a camera using aruco markers
%   cv.getBoardObjectAndImagePoints     - Given a board configuration and a set of detected markers, returns the corresponding image points and object points to call solvePnP
%   cv.drawCharucoBoard                 - Draw a ChArUco board
%   cv.interpolateCornersCharuco        - Interpolate position of ChArUco board corners
%   cv.estimatePoseCharucoBoard         - Pose estimation for a ChArUco board given some of their corners
%   cv.drawDetectedCornersCharuco       - Draws a set of ChArUco corners
%   cv.calibrateCameraCharuco           - Calibrate a camera using ChArUco corners
%   cv.detectCharucoDiamond             - Detect ChArUco Diamond markers
%   cv.drawDetectedDiamonds             - Draw a set of detected ChArUco Diamond markers
%   cv.drawCharucoDiamond               - Draw a ChArUco Diamond marker
%
% bgsegm: Improved Background-Foreground Segmentation Methods
%   cv.BackgroundSubtractorMOG          - Gaussian Mixture-based Background/Foreground Segmentation Algorithm
%   cv.BackgroundSubtractorGMG          - Background Subtractor module
%   cv.BackgroundSubtractorCNT          - Background subtraction based on counting
%   cv.BackgroundSubtractorGSOC         - Background Subtraction implemented during GSOC
%   cv.BackgroundSubtractorLSBP         - Background Subtraction using Local SVD Binary Pattern
%   cv.SyntheticSequenceGenerator       - Synthetic frame sequence generator for testing background subtraction algorithms
%
% bioinspired: Biologically Inspired Vision Models and Derivated Tools
%   cv.Retina                           - A biological retina model for image spatio-temporal noise and luminance changes enhancement
%   cv.RetinaFastToneMapping            - Class with tone mapping algorithm of Meylan et al. (2007)
%   cv.TransientAreasSegmentationModule - Class which provides a transient/moving areas segmentation module
%
% datasets: Framework for Working with Different Datasets
%   cv.Dataset                          - Class for working with different datasets
%
% dnn_objdetect: DNN used for Object Detection
%   cv.InferBbox                        - Post-process DNN object detection model predictions
%
% dpm: Deformable Part-based Models
%   cv.DPMDetector                      - Deformable Part-based Models (DPM) detector
%
% face: Face Analysis
%   cv.BasicFaceRecognizer              - Face Recognition based on Eigen-/Fisher-faces
%   cv.LBPHFaceRecognizer               - Face Recognition based on Local Binary Patterns
%   cv.BIF                              - Implementation of bio-inspired features (BIF)
%   cv.Facemark                         - Base class for all facemark models
%   cv.FacemarkKazemi                   - Face Alignment
%
% hfs: Hierarchical Feature Selection for Efficient Image Segmentation
%   cv.HfsSegment                       - Hierarchical Feature Selection for Efficient Image Segmentation
%
% img_hash: Image Hashing Algorithms
%   cv.ImgHash                          - Base class for Image Hashing algorithms
%
% line_descriptor: Binary Descriptors for Lines Extracted from an Image
%   cv.BinaryDescriptor                 - Class implements both functionalities for detection of lines and computation of their binary descriptor
%   cv.LSDDetector                      - Line Segment Detector
%   cv.BinaryDescriptorMatcher          - BinaryDescriptor matcher class
%   cv.drawLineMatches                  - Draws the found matches of keylines from two images
%   cv.drawKeylines                     - Draws keylines
%
% optflow: Optical Flow Algorithms
%   cv.OpticalFlowPCAFlow               - PCAFlow algorithm
%   cv.GPCForest                        - Implementation of the Global Patch Collider algorithm
%   cv.calcOpticalFlowSF                - Calculate an optical flow using "SimpleFlow" algorithm
%   cv.calcOpticalFlowDF                - DeepFlow optical flow algorithm implementation
%   cv.calcOpticalFlowSparseToDense     - Fast dense optical flow based on PyrLK sparse matches interpolation
%   cv.readOpticalFlow                  - Read a .flo file
%   cv.writeOpticalFlow                 - Write a .flo to disk
%   cv.VariationalRefinement            - Variational optical flow refinement
%   cv.DISOpticalFlow                   - DIS optical flow algorithm
%   cv.updateMotionHistory              - Updates the motion history image by a moving silhouette
%   cv.calcMotionGradient               - Calculates a gradient orientation of a motion history image
%   cv.calcGlobalOrientation            - Calculates a global motion orientation in a selected region
%   cv.segmentMotion                    - Splits a motion history image into a few parts corresponding to separate independent motions (for example, left hand, right hand)
%
% plot: Plot Function for Mat Data
%   cv.Plot2d                           - Class to plot 2D data
%
% saliency: Saliency API
%   cv.StaticSaliencySpectralResidual   - The Spectral Residual approach for Static Saliency
%   cv.StaticSaliencyFineGrained        - The Fine Grained Saliency approach for Static Saliency
%   cv.MotionSaliencyBinWangApr2014     - A Fast Self-tuning Background Subtraction Algorithm for Motion Saliency
%   cv.ObjectnessBING                   - The Binarized normed gradients algorithm for Objectness
%
% text: Scene Text Detection and Recognition
%   cv.TextDetectorCNN                  - Class providing functionality of text detection
%
% xfeatures2d: Extra 2D Features Framework
%   cv.SIFT                             - Class for extracting keypoints and computing descriptors using the Scale Invariant Feature Transform (SIFT)
%   cv.SURF                             - Class for extracting Speeded Up Robust Features from an image
%   cv.FREAK                            - Class implementing the FREAK (Fast Retina Keypoint) keypoint descriptor
%   cv.StarDetector                     - The class implements the Star keypoint detector
%   cv.BriefDescriptorExtractor         - Class for computing BRIEF descriptors
%   cv.LUCID                            - Class implementing the Locally Uniform Comparison Image Descriptor
%   cv.LATCH                            - Class for computing the LATCH descriptor
%   cv.DAISY                            - Class implementing DAISY descriptor
%   cv.MSDDetector                      - Class implementing the MSD (Maximal Self-Dissimilarity) keypoint detector
%   cv.VGG                              - Class implementing VGG (Oxford Visual Geometry Group) descriptor
%   cv.BoostDesc                        - Class implementing BoostDesc (Learning Image Descriptors with Boosting)
%   cv.PCTSignatures                    - Class implementing PCT (Position-Color-Texture) signature extraction
%   cv.PCTSignaturesSQFD                - Class implementing Signature Quadratic Form Distance (SQFD)
%   cv.HarrisLaplaceFeatureDetector     - Class implementing the Harris-Laplace feature detector
%   cv.AffineFeature2D                  - Class implementing affine adaptation for key points
%   cv.FASTForPointSet                  - Estimates cornerness for pre-specified KeyPoints using the FAST algorithm
%   cv.matchGMS                         - GMS (Grid-based Motion Statistics) feature matching strategy
%
% ximgproc: Extended Image Processing
%   cv.DTFilter                         - Interface for realizations of Domain Transform filter
%   cv.GuidedFilter                     - Interface for realizations of Guided Filter
%   cv.AdaptiveManifoldFilter           - Interface for Adaptive Manifold Filter realizations
%   cv.jointBilateralFilter             - Applies the joint bilateral filter to an image
%   cv.bilateralTextureFilter           - Applies the bilateral texture filter to an image
%   cv.rollingGuidanceFilter            - Applies the rolling guidance filter to an image
%   cv.FastGlobalSmootherFilter         - Interface for implementations of Fast Global Smoother filter
%   cv.l0Smooth                         - Global image smoothing via L0 gradient minimization
%   cv.DisparityWLSFilter               - Disparity map filter based on Weighted Least Squares filter
%   cv.EdgeAwareInterpolator            - Sparse match interpolation algorithm
%   cv.StructuredEdgeDetection          - Class implementing edge detection algorithm
%   cv.EdgeBoxes                        - Class implementing Edge Boxes algorithm
%   cv.SuperpixelSEEDS                  - Class implementing the SEEDS (Superpixels Extracted via Energy-Driven Sampling) superpixels algorithm
%   cv.SuperpixelSLIC                   - Class implementing the SLIC (Simple Linear Iterative Clustering) superpixels algorithm
%   cv.SuperpixelLSC                    - Class implementing the LSC (Linear Spectral Clustering) superpixels algorithm
%   cv.GraphSegmentation                - Graph Based Segmentation algorithm
%   cv.SelectiveSearchSegmentation      - Selective search segmentation algorithm
%   cv.FastHoughTransform               - Calculates 2D Fast Hough transform of an image
%   cv.HoughPoint2Line                  - Calculates coordinates of line segment corresponded by point in Hough space
%   cv.FastLineDetector                 - Class implementing the FLD (Fast Line Detector) algorithm
%   cv.covarianceEstimation             - Computes the estimated covariance matrix of an image using the sliding window formulation
%   cv.weightedMedianFilter             - Applies weighted median filter to an image
%   cv.GradientPaillou                  - Applies Paillou filter to an image
%   cv.GradientDeriche                  - Applies Deriche filter to an image
%   cv.PeiLinNormalization              - Calculates an affine transformation that normalize given image using Pei/Lin Normalization
%   cv.ContourFitting                   - Contour Fitting algorithm using Fourier descriptors
%   cv.RidgeDetectionFilter             - Ridge Detection Filter
%   cv.BrightEdges                      - Bright edges detector
%   cv.niBlackThreshold                 - Performs thresholding on input images using Niblack's technique or some of the popular variations it inspired
%   cv.thinning                         - Applies a binary blob thinning operation, to achieve a skeletization of the input image
%   cv.anisotropicDiffusion             - Performs anisotropic diffusion on an image
%
% xobjdetect: Extended Object Detection
%   cv.WBDetector                       - WaldBoost detector - Object Detection using Boosted Features
%
% xphoto: Additional Photo Processing Algorithms
%   cv.inpaint2                         - The function implements different single-image inpainting algorithms
%   cv.SimpleWB                         - Simple white balance algorithm
%   cv.GrayworldWB                      - Gray-world white balance algorithm
%   cv.LearningBasedWB                  - More sophisticated learning-based automatic white balance algorithm
%   cv.applyChannelGains                - Implements an efficient fixed-point approximation for applying channel gains, which is the last step of multiple white balance algorithms
%   cv.dctDenoising                     - The function implements simple dct-based denoising
%   cv.bm3dDenoising                    - Performs image denoising using the Block-Matching and 3D-filtering algorithm
%
