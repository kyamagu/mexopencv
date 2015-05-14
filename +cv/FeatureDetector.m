classdef FeatureDetector < handle
    %FEATUREDETECTOR  FeatureDetector class
    %
    % Feature detector class. Here is how to use:
    %
    %    detector = cv.FeatureDetector('SURF');
    %    keypoints = detector.detect(im);
    %
    % The following detector types are supported:
    %
    %     'FAST'       FastFeatureDetector
    %     'STAR'       StarFeatureDetector
    %     'SIFT'       SiftFeatureDetector
    %     'SURF'       SurfFeatureDetector
    %     'ORB'        OrbFeatureDetector
    %     'MSER'       MserFeatureDetector
    %     'GFTT'       GoodFeaturesToTrackDetector
    %     'HARRIS'     GoodFeaturesToTrackDetector with Harris detector enabled
    %     'Dense'      DenseFeatureDetector
    %     'SimpleBlob' SimpleBlobDetector
    %
    % Also a combined format with one of the following adaptor is
    % supported
    %
    %     'Grid'       GridAdaptedFeatureDetector
    %     'Pyramid'    PyramidAdaptedFeatureDetector
    %
    % for example: 'GridFAST', 'PyramidSTAR'.
    %
    % See also cv.FeatureDetector.FeatureDetector cv.FeatureDetector.write
    % cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (SetAccess = private, Dependent)
        % Type of the detector
        Type
    end

    methods
        function this = FeatureDetector(detectorType, varargin)
            %FEATUREDETECTOR  FeatureDetector constructors
            %
            %    detector = cv.FeatureDetector(type)
            %
            % ## Input
            % * __type__ Type of the detector. see below. default 'FAST'
            %
            % ## Output
            % * __detector__ New instance of the FeatureDetector
            %
            % The following detector types are supported:
            %
            %     'FAST'       FastFeatureDetector
            %     'STAR'       StarFeatureDetector
            %     'SIFT'       SiftFeatureDetector
            %     'SURF'       SurfFeatureDetector
            %     'ORB'        OrbFeatureDetector
            %     'MSER'       MserFeatureDetector
            %     'GFTT'       GoodFeaturesToTrackDetector
            %     'HARRIS'     GoodFeaturesToTrackDetector with Harris detector enabled
            %     'Dense'      DenseFeatureDetector
            %     'SimpleBlob' SimpleBlobDetector
            %
            % Also a combined format with one of the following adaptor is
            % supported
            %
            %     'Grid'       GridAdaptedFeatureDetector
            %     'Pyramid'    PyramidAdaptedFeatureDetector
            %
            % for example: 'GridFAST', 'PyramidSTAR'.
            %
            % See also cv.FeatureDetector cv.FeatureDetector.write
            %
            if nargin < 1, detectorType = 'FAST'; end
            this.id = FeatureDetector_(0, 'new', detectorType, varargin{:});
        end

        function delete(this)
            %DELETE  FeatureDetector destructor
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'delete');
        end

        function clear(this)
            %CLEAR
            FeatureDetector_(this.id, 'clear');
        end

        function empty(this)
            %EMPTY
            FeatureDetector_(this.id, 'empty');
        end

        function def_name = getDefaultName(this)
            %GETDEFAULTNAME
            def_name = FeatureDetector_(this.id, 'getDefaultName');
        end

        function def_norm = defaultNorm(this)
            %DEFAULTNORM
            def_norm = FeatureDetector_(this.id, 'defaultNorm');
        end

        function s = descriptorSize(this)
            %DESCRIPTORSIZE
            s = FeatureDetector_(this.id, 'descriptorSize');
        end
        
        function t = descriptorType(this)
            %DESCRIPTORTYPE
            t = FeatureDetector_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, im, varargin)
            %DETECT  Detects keypoints in an image
            %
            %    keypoints = detector.detect(im)
            %    keypoints = detector.detect(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ Image
            %
            % ## Output
            % * __keypoints__ The detected keypoints. A 1-by-N structure array.
            %       It has the following fields:
            %       * __pt__ coordinates of the keypoint [x,y]
            %       * __size__ diameter of the meaningful keypoint neighborhood
            %       * __angle__ computed orientation of the keypoint (-1 if not applicable).
            %             Its possible values are in a range [0,360) degrees. It is measured
            %             relative to image coordinate system (y-axis is directed downward),
            %             ie in clockwise.
            %       * __response__ the response by which the most strong keypoints have been
            %             selected. Can be used for further sorting or subsampling.
            %       * __octave__ octave (pyramid layer) from which the keypoint has been
            %             extracted.
            %       * **class_id** object id that can be used to clustered keypoints by an
            %             object they belong to.
            %
            % ## Options
            % * __Mask__ Optional mask specifying where to look for keypoints.
            %       It must be a 8-bit integer matrix with non-zero values
            %       in the region of interest.
            %
            % See also cv.FeatureDetector
            %
            keypoints = FeatureDetector_(this.id, 'detect', im, varargin{:});
        end

        function load(this, filename, varargin)
            %READ  Reads a feature detector object from a file
            %
            %    detector.read(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'load', filename, varargin{:});
        end

        function save(this, filename)
            %WRITE  Writes a feature detector object to a file
            %
            %    detector.write(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'save', filename);
        end
    end

    methods
        function t = get.Type(this)
            %TYPE  FeatureDetector type
            t = FeatureDetector_(this.id, 'type');
        end
    end

end
