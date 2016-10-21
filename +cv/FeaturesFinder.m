classdef FeaturesFinder < handle
    %FEATURESFINDER  Feature finders class
    %
    % See also: cv.Stitcher, cv.FeaturesMatcher, cv.SURF, cv.ORB
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = FeaturesFinder(finderType, varargin)
            %FEATURESFINDER  Constructor
            %
            %    obj = cv.FeaturesFinder(finderType)
            %    obj = cv.FeaturesFinder(finderType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __finderType__ Feature finder type. One of:
            %       * __OrbFeaturesFinder__ ORB features finder. See cv.ORB
            %       * __SurfFeaturesFinder__ SURF features finder. See cv.SURF
            %             (requires `xfeatures2d` module)
            %       * __SurfFeaturesFinderGpu__ (requires CUDA and
            %             `xfeatures2d` module)
            %
            % ## Options
            % The following are options for the various finders:
            %
            % ### `OrbFeaturesFinder`
            % * __GridSize__ default [3,1]
            % * __NFeatures__ default 1500
            % * __ScaleFactor__ default 1.3
            % * __NLevels__ default 5
            %
            % ### `SurfFeaturesFinder`
            % * __HessThresh__ default 300.0
            % * __NumOctaves__ default 3
            % * __NumLayers__ default 4
            % * __NumOctaveDescr__ default 3
            % * __NumLayersDesc__ default 4
            %
            % See also: cv.FeaturesFinder.find
            %
            this.id = FeaturesFinder_(0, 'new', finderType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.FeaturesFinder
            %
            if isempty(this.id), return; end
            FeaturesFinder_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            typename = FeaturesFinder_(this.id, 'typeid');
        end
    end

    %% FeaturesFinder
    methods
        function collectGarbage(this)
            %COLLECTGARBAGE  Frees unused memory allocated before if there is any
            %
            %    obj.collectGarbage()
            %
            % See also: cv.FeaturesFinder.FeaturesFinder
            %
            FeaturesFinder_(this.id, 'collectGarbage');
        end

        function features = find(this, image, varargin)
            %FIND  Finds features in the given image
            %
            %    features = obj.find(image)
            %    features = obj.find(image, rois)
            %
            % ## Input
            % * __image__ Source image.
            % * __rois__ Regions of interest. A cell array of 4-element
            %       vectors `{[x y w h], ...}`
            %
            % ## Output
            % * __features__ Found features. Structure containing image
            %       keypoints and descriptors with the following fields:
            %       * **img_idx**
            %       * **img_size**
            %       * __keypoints__
            %       * __descriptors__
            %
            % See also: cv.FeaturesFinder.FeaturesFinder
            %
            features = FeaturesFinder_(this.id, 'find', image, varargin{:});
        end
    end

end
