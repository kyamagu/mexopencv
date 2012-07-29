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
        type
    end
    
    methods
        function this = FeatureDetector(type)
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
            if nargin < 1, type = 'FAST'; end
            if ~ischar(type)
                error('DescriptorExtractor:error','Invalid type');
            end
            this.id = FeatureDetector_(type);
        end
        
        function delete(this)
            %DELETE  FeatureDetector destructor
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'delete');
        end
        
        function t = get.type(this)
            %TYPE  FeatureDetector type
            t = FeatureDetector_(this.id, 'type');
        end
        
        function keypoints = detect(this, im)
            %DETECT  Detects keypoints in an image
            %
            %    keypoints = detector.detect(im)
            %
            % ## Input
            % * __im__ Image
            %
            % ## Output
            % * __keypoints__ The detected keypoints
            %
            % See also cv.FeatureDetector
            %
            keypoints = FeatureDetector_(this.id, 'detect', im);
        end
        
        function read(this, filename)
            %READ  Reads a feature detector object from a file
            %
            %    detector.read(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'write', filename);
        end
        
        function write(this, filename)
            %WRITE  Writes a feature detector object to a file
            %
            %    detector.write(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.FeatureDetector
            %
            FeatureDetector_(this.id, 'write', filename);
        end
    end
    
end
