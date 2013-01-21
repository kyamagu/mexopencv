classdef DescriptorExtractor < handle
    %DESCRIPTOREXTRACTOR  DescriptorExtractor class
    %
    % Descriptor extractor class. Here is how to use:
    %
    %    detector = cv.FeatureDetector('SURF');
    %    keypoints = detector.detect(im);
    %    extractor = cv.DescriptorExtractor('SURF');
    %    descriptors = extractor.compute(im, keypoints);
    %
    % The following extractor types are supported:
    %
    %     'SIFT'     SiftDescriptorExtractor
    %     'SURF'     SurfDescriptorExtractor
    %     'ORB'      OrbDescriptorExtractor
    %     'BRIEF'    BriefDescriptorExtractor
    %
    % Also a combined format with the following adaptor is
    % supported
    %
    %     'Opponent' OpponentColorDescriptorExtractor
    %
    % for example: 'OpponentSIFT'.
    %
    % See also cv.DescriptorExtractor.DescriptorExtractor
    % cv.DescriptorExtractor.compute cv.FeatureDetector
    % cv.BOWImgDescriptorExtractor
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % Size of the DescriptorExtractor
        size
        % Type of the extractor
        type
    end
    
    methods
        function this = DescriptorExtractor(type)
            %DESCRIPTOREXTRACTOR  DescriptorExtractor constructors
            %
            %    extractor = cv.DescriptorExtractor(type)
            %
            % ## Input
            % * __type__ Type of the detector. see below. default 'FAST'
            %
            % ## Output
            % * __extractor__ New instance of the DescriptorExtractor
            %
            % The following extractor types are supported:
            %
            %     'SIFT'     SiftDescriptorExtractor
            %     'SURF'     SurfDescriptorExtractor
            %     'ORB'      OrbDescriptorExtractor
            %     'BRIEF'    BriefDescriptorExtractor
            %
            % Also a combined format with the following adaptor is
            % supported
            %
            %     'Opponent' OpponentColorDescriptorExtractor
            %
            % for example: 'OpponentSIFT'.
            %
            % See also cv.DescriptorExtractor cv.DescriptorExtractor.write
            %
            if nargin < 1, type = 'SIFT'; end
            if ~ischar(type)
                error('DescriptorExtractor:error','Invalid type');
            end
            this.id = DescriptorExtractor_(type);
        end
        
        function delete(this)
            %DELETE  DescriptorExtractor destructor
            %
            % See also cv.DescriptorExtractor
            %
            DescriptorExtractor_(this.id, 'delete');
        end
        
        function s = get.size(this)
            %SIZE  DescriptorExtractor size
            s = DescriptorExtractor_(this.id, 'size');
        end
        
        function t = get.type(this)
            %TYPE  DescriptorExtractor type
            t = DescriptorExtractor_(this.id, 'type');
        end
        
        function [descriptors, keypoints] = compute(this, im, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image
            %
            %    descroptors = extractor.compute(im, keypoints)
            %
            % ## Input
            % * __im__ Image.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example:
            %       SIFT duplicates keypoint with several dominant
            %       orientations (for each orientation).
            %       A 1-by-N structure array, it has the following fields:
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
            % ## Output
            % * __descriptors__ Computed descriptors.
            % * __keypoints__ Keypoints for which descriptors have been computed.
            %
            % See also cv.DescriptorExtractor
            %
            [descriptors, keypoints] = DescriptorExtractor_(this.id, 'compute', im, keypoints);
        end
        
        function read(this, filename)
            %READ  Reads a descriptor extractor object from a file
            %
            %    extractor.read(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.DescriptorExtractor
            %
            DescriptorExtractor_(this.id, 'write', filename);
        end
        
        function write(this, filename)
            %WRITE  Writes a descriptor extractor object to a file
            %
            %    extractor.write(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.DescriptorExtractor
            %
            DescriptorExtractor_(this.id, 'write', filename);
        end
    end
    
end
