classdef CascadeClassifier < handle
    %CASCADECLASSIFIER  Haar Feature-based Cascade Classifier for Object Detection
    %
    % The object detector described below has been initially proposed by
    % Paul Viola [Viola01] and improved by Rainer Lienhart [Lienhart02].
    %
    % First, a classifier (namely a cascade of boosted classifiers working
    % with haar-like features) is trained with a few hundred sample views of a
    % particular object (i.e., a face or a car), called positive examples,
    % that are scaled to the same size (say, 20x20), and negative examples -
    % arbitrary images of the same size.
    %
    % After a classifier is trained, it can be applied to a region of interest
    % (of the same size as used during the training) in an input image. The
    % classifier outputs a "1" if the region is likely to show the object
    % (i.e., face/car), and "0" otherwise. To search for the object in the
    % whole image one can move the search window across the image and check
    % every location using the classifier. The classifier is designed so that
    % it can be easily "resized" in order to be able to find the objects of
    % interest at different sizes, which is more efficient than resizing the
    % image itself. So, to find an object of an unknown size in the image the
    % scan procedure should be done several times at different scales.
    %
    % The word "cascade" in the classifier name means that the resultant
    % classifier consists of several simpler classifiers (stages) that are
    % applied subsequently to a region of interest until at some stage the
    % candidate is rejected or all the stages are passed. The word "boosted"
    % means that the classifiers at every stage of the cascade are complex
    % themselves and they are built out of basic classifiers using one of four
    % different boosting techniques (weighted voting). Currently Discrete
    % Adaboost, Real Adaboost, Gentle Adaboost and Logitboost are supported.
    % The basic classifiers are decision-tree classifiers with at least 2
    % leaves. Haar-like features are the input to the basic classifiers, and
    % are calculated as described below. The current algorithm uses the
    % following Haar-like features:
    %
    % 1. Edge features
    % 2. Line features
    % 3. Center-surround features
    %
    % See image: <http://docs.opencv.org/3.0.0/haarfeatures.png>
    %
    % The feature used in a particular classifier is specified by its shape
    % (1a, 2b etc.), position within the region of interest and the scale
    % (this scale is not the same as the scale used at the detection stage,
    % though these two scales are multiplied). For example, in the case of the
    % third line feature (2c) the response is calculated as the difference
    % between the sum of image pixels under the rectangle covering the whole
    % feature (including the two white stripes and the black stripe in the
    % middle) and the sum of the image pixels under the black stripe
    % multiplied by 3 in order to compensate for the differences in the size
    % of areas. The sums of pixel values over a rectangular regions are
    % calculated rapidly using integral images (see below and the integral
    % description).
    %
    % The following reference is for the detection part only. There is a
    % separate application called `opencv_traincascade` that can train a
    % cascade of boosted classifiers from a set of samples. This is not
    % included in mexopencv.
    %
    % ## Note
    % In the new interface it is also possible to use LBP (local binary
    % pattern) features in addition to Haar-like features.
    %
    % ## Example
    % The usage example is shown in the following:
    %
    %    xmlfile = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml');
    %    cc = cv.CascadeClassifier(xmlfile);
    %    im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
    %    boxes = cc.detect(im);
    %    for i=1:numel(boxes)
    %        im = cv.rectangle(im, boxes{i}, 'Color',[0 255 0], 'Thickness',2);
    %    end
    %    imshow(im)
    %
    % ## References
    % [Viola01]:
    % > Paul Viola and Michael Jones. "Rapid Object Detection using a Boosted
    % > Cascade of Simple Features". IEEE CVPR, 2001, Vol 1, pages I-511.
    % > http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.10.6807
    %
    % [Lienhart02]:
    % > Rainer Lienhart and Jochen Maydt. "An Extended Set of Haar-like
    % > Features for Rapid Object Detection". IEEE ICIP 2002, Vol. 1,
    % > pp. 900-903, Sep. 2002.
    %
    % See also: cv.CascadeClassifier.CascadeClassifier,
    %  cv.CascadeClassifier.detect, vision.CascadeObjectDetector
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = CascadeClassifier(filename)
            %CASCADECLASSIFIER  Creates a new cascade classifier object
            %
            %    classifier = cv.CascadeClassifier()
            %    classifier = cv.CascadeClassifier(filename)
            %
            % ## Input
            % * __filename__ Name of the XML file from which the trained
            %       classifier is loaded. This is handled by the
            %       cv.CascadeClassifier.load method.
            %
            % Supports HAAR and LBP cascades.
            %
            % See also: cv.CascadeClassifier.load, cv.CascadeClassifier.detect
            %
            this.id = CascadeClassifier_(0, 'new');
            if nargin > 0
                this.load(filename);
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.CascadeClassifier
            %
            CascadeClassifier_(this.id, 'delete');
        end

        function tf = empty(this)
            %EMPTY  Checks whether the classifier has been loaded
            %
            %    tf = classifier.empty()
            %
            % ## Output
            % * __tf__ a logical value indicating empty object when true.
            %
            % See also: cv.CascadeClassifier.load
            %
            tf = CascadeClassifier_(this.id, 'empty');
        end

        function status = load(this, filename)
            %LOAD  Loads a classifier from a file
            %
            %    classifier.load(filename)
            %    status = classifier.load(filename)
            %
            % ## Input
            % * __filename__ Name of the file from which the classifier is
            %       loaded. The file may contain an old HAAR classifier
            %       trained by the `haartraining` application or a new cascade
            %       classifier trained by the `traincascade` application.
            %
            % ## Output
            % * __status__ a logical value indicating success of load.
            %
            % See also: cv.CascadeClassifier.CascadeClassifier
            %
            status = CascadeClassifier_(this.id, 'load', filename);
        end

        function tf = isOldFormatCascade(this)
            %ISOLDFORMATCASCADE  Check if loaded classifer is from the old format
            %
            %    tf = classifier.isOldFormatCascade()
            %
            % ## Output
            % * __tf__ true if old format, false if new format classifier
            %
            % See also: cv.CascadeClassifier.load
            %
            tf = CascadeClassifier_(this.id, 'isOldFormatCascade');
        end

        function ftype = getFeatureType(this)
            %GETFEATURETYPE  Get features type
            %
            %    ftype = classifier.getFeatureType()
            %
            % ## Output
            % * __ftype__
            %
            assert(~this.isOldFormatCascade(), 'Not supported by old format');
            ftype = CascadeClassifier_(this.id, 'getFeatureType');
        end

        function winsiz = getOriginalWindowSize(this)
            %GETORIGINALWINDOWSIZE  Get original window size
            %
            %    winsiz = classifier.getOriginalWindowSize()
            %
            % ## Output
            % * __winsiz__
            %
            winsiz = CascadeClassifier_(this.id, 'getOriginalWindowSize');
        end

        function S = getMaskGenerator(this)
            %GETMASKGENERATOR  Get the current mask generator function
            %
            %    S = classifier.getMaskGenerator()
            %
            % ## Output
            % * __S__ a struct containing with the following fields:
            %       * __fun__ the name of the mask generator MATLAB function.
            %
            % See also: cv.CascadeClassifier.setMaskGenerator
            %
            S = CascadeClassifier_(this.id, 'getMaskGenerator');
        end

        function setMaskGenerator(this, maskgenFcn)
            %SETMASKGENERATOR  Set the current mask generator function
            %
            %    classifier.setMaskGenerator(maskgenFcn)
            %
            % ## Input
            % * __maskgenFcn__ name of a MATLAB M-function that generates
            %       mask. It also accepts the special name of
            %       'FaceDetectionMaskGenerator'.
            %
            % This only works with the new format cascade classifiers.
            %
            % TODO: Currently not fully used by OpenCV.
            %
            % See also: cv.CascadeClassifier.getMaskGenerator
            %
            CascadeClassifier_(this.id, 'setMaskGenerator', maskgenFcn);
        end

        function [boxes, varargout] = detect(this, im, varargin)
            %DETECT  Detects objects of different sizes in the input image.
            %
            %    boxes = classifier.detect(im)
            %    [boxes, numDetections] = classifier.detect(im)
            %    [boxes, rejectLevels, levelWeights] = classifier.detect(im)
            %    [...] = classifier.detect(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ Matrix of the type `uint8` containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __boxes__ Cell array of rectangles where each rectangle
            %       contains the detected object, the rectangles may be
            %       partially outside the original image.
            % * __numDetections__ optional vector of detection numbers for the
            %       corresponding objects. An object's number of detections is
            %       the number of neighboring positively classified rectangles
            %       that were joined together to form the object.
            % * __rejectLevels__ optional output vector of integers. Implies
            %       `OutputRejectLevels=true`.
            % * __levelWeights__ optional output vector of doubles. Implies
            %       `OutputRejectLevels=true`.
            %
            % ## Options
            % * __ScaleFactor__ Parameter specifying how much the image size
            %       is reduced at each image scale. default 1.1
            % * __MinNeighbors__ Parameter specifying how many neighbors each
            %       candiate rectangle should have to retain it. default 3
            % * __MinSize__ Minimum possible object size. Objects smaller than
            %       that are ignored. Not set by default.
            % * __MaxSize__ Maximum possible object size. Objects larger than
            %       that are ignored. Not set by default.
            % * __OutputRejectLevels__ if is true returns `rejectLevels` and
            %       `levelWeights`. default false
            % * __DoCannyPruning__ Parameter with the same meaning for an old
            %       cascade as in the function `cvHaarDetectObjects`. It is
            %       not used for a new cascade. default false
            % * __ScaleImage__ Parameter with the same meaning for an old
            %       cascade as in the function `cvHaarDetectObjects`. It is
            %       not used for a new cascade. default false
            % * __FindBiggestObject__ Parameter with the same meaning for an
            %       old cascade as in the function `cvHaarDetectObjects`. It
            %       is not used for a new cascade. default false
            % * __DoRoughSearch__ Parameter with the same meaning for an old
            %       cascade as in the function `cvHaarDetectObjects`. It is
            %       not used for a new cascade. default false
            %
            % The detected objects are returned as a cell array of rectangles.
            % Note that the function has three variants based on the number of
            % output arguments.
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.CascadeClassifier.CascadeClassifier
            %
            [boxes, varargout{1:nargout-1}] = CascadeClassifier_(this.id, ...
                'detectMultiScale', im, varargin{:});
        end
    end

    methods (Static)
        function status = convert(oldcascade, newcascade)
            %CONVERT  Convert classifier file from the old format to the new format
            %
            %    cv.CascadeClassifier.convert(oldcascade, newcascade)
            %    status = cv.CascadeClassifier.convert(oldcascade, newcascade)
            %
            % ## Input
            % * __oldcascade__ name of classifier file to read in old format
            % * __newcascade__ name of classifier file to write in new format
            %
            % ## Output
            % * __status__ optional output success flag.
            %
            % See also: cv.CascadeClassifier.load
            %
            status = CascadeClassifier_(0, 'convert', oldcascade, newcascade);
        end
    end

end
