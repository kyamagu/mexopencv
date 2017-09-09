classdef FeaturesMatcher < handle
    %FEATURESMATCHER  Feature matchers class
    %
    % See also: cv.Stitcher, cv.FeaturesFinder, cv.DescriptorMatcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = FeaturesMatcher(matcherType, varargin)
            %FEATURESMATCHER  Constructor
            %
            %     obj = cv.FeaturesMatcher(matcherType)
            %     obj = cv.FeaturesMatcher(matcherType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __matcherType__ One of:
            %   * __BestOf2NearestMatcher__ A "best of 2 nearest" matcher.
            %     Features matcher which finds two best matches for each
            %     feature and leaves the best one only if the ratio between
            %     descriptor distances is greater than the threshold
            %     `MatchConf`.
            %   * __BestOf2NearestRangeMatcher__
            %   * __AffineBestOf2NearestMatcher__ A "best of 2 nearest"
            %     matcher that expects affine trasformation between images.
            %     Features matcher similar to `BestOf2NearestMatcher` which
            %     finds two best matches for each feature and leaves the best
            %     one only if the ratio between descriptor distances is
            %     greater than the threshold `MatchConf`. Unlike
            %     `BestOf2NearestMatcher` this matcher uses affine
            %     transformation (affine trasformation estimate will be placed
            %     in `matches_info`).
            %
            % ## Options
            % The following are options accepted by all matchers:
            %
            % * __TryUseGPU__ Should try to use GPU or not. default false
            % * __MatchConf__ Match distances ration threshold. Confidence for
            %   feature matching step. default 0.3
            % * __NumMatchesThresh1__ Minimum number of matches required for
            %   the 2D projective transform estimation used in the inliers
            %   classification step. default 6
            % * __NumMatchesThresh2__ Minimum number of matches required for
            %   the 2D projective transform re-estimation on inliers.
            %   default 6
            %
            % The following are options for the various algorithms:
            %
            % ### `BestOf2NearestRangeMatcher`
            % * __RangeWidth__ Range width. default 5
            %
            % ### `AffineBestOf2NearestMatcher`
            % * __FullAffine__ whether to use full affine transformation with
            %   6 degress of freedom (cv.estimateAffine2D) or reduced
            %   transformation with 4 degrees of freedom
            %   (cv.estimateAffinePartial2D) using only rotation, translation
            %   and uniform scaling. default false
            %
            % See also: cv.FeaturesMatcher.match
            %
            this.id = FeaturesMatcher_(0, 'new', matcherType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.FeaturesMatcher
            %
            if isempty(this.id), return; end
            FeaturesMatcher_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = FeaturesMatcher_(this.id, 'typeid');
        end
    end

    %% FeaturesMatcher
    methods
        function collectGarbage(this)
            %COLLECTGARBAGE  Frees unused memory allocated before if there is any
            %
            %     obj.collectGarbage()
            %
            % See also: cv.FeaturesMatcher.FeaturesMatcher
            %
            FeaturesMatcher_(this.id, 'collectGarbage');
        end

        function tf = isThreadSafe(this)
            %ISTHREADSAFE  Check if matcher is thread safe
            %
            %     tf = obj.isThreadSafe()
            %
            % ## Output
            % * __tf__ True, if it's possible to use the same matcher instance
            %   in parallel, false otherwise.
            %
            % See also: cv.FeaturesMatcher.FeaturesMatcher
            %
            tf = FeaturesMatcher_(this.id, 'isThreadSafe');
        end

        function matches_info = match(this, features1, features2)
            %MATCH  Performs images matching
            %
            %     matches_info = obj.match(features1, features2)
            %
            % ## Input
            % * __features1__ First image features. See cv.FeaturesFinder.
            % * __features2__ Second image features. See cv.FeaturesFinder.
            %
            % ## Output
            % * **matches_info** Found matches. Structure containing
            %   information about matches between two images. It's assumed
            %   that there is a transformation between those images.
            %   Transformation may be homography or affine transformation
            %   based on selected matcher. Struct with the following fields:
            %   * **src_img_idx** Images indices (optional).
            %   * **dst_img_idx** Images indices (optional).
            %   * __matches__ Matches. A 1-by-N structure array with the
            %     following fields:
            %     `{'queryIdx', 'trainIdx', 'imgIdx', 'distance'}`
            %   * **inliers_mask** Geometrically consistent matches mask.
            %   * **num_inliers** Number of geometrically consistent matches.
            %   * __H__ Estimated transformation.
            %   * __confidence__ Confidence two images are from the same
            %     panorama.
            %
            % See also: cv.FeaturesMatcher.match_pairwise,
            %  cv.FeaturesFinder.find
            %
            matches_info = FeaturesMatcher_(this.id, 'match', features1, features2);
        end

        function pairwise_matches = match_pairwise(this, features, varargin)
            %MATCH_PAIRWISE  Performs images matching
            %
            %     pairwise_matches = obj.match_pairwise(features)
            %     pairwise_matches = obj.match_pairwise(features, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __features__ Features of the source images.
            %   See cv.FeaturesFinder.
            %
            % ## Output
            % * **pairwise_matches** Found pairwise matches.
            %
            % ## Options
            % * __Mask__ Mask indicating which image pairs must be matched.
            %   default empty
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.FeaturesMatcher.match, cv.FeaturesFinder.find
            %
            pairwise_matches = FeaturesMatcher_(this.id, 'match_pairwise', features, varargin{:});
        end
    end

    %% Auxiliary methods
    methods (Static)
        function str = matchesGraphAsString(pairwise_matches, conf_threshold)
            %MATCHESGRAPHASSTRING  Covert matches to graph
            %
            %     str = cv.FeaturesMatcher.matchesGraphAsString(pairwise_matches, conf_threshold)
            %
            % ## Input
            % * **pairwise_matches** Pairwise matches.
            % * **conf_threshold** Threshold for two images are from the same
            %   panorama confidence.
            %
            % ## Output
            % * __str__ matches graph represented in DOT language. Labels
            %   description: `Nm` is number of matches, `Ni` is number of
            %   inliers, `C` is confidence.
            %
            % Returns matches graph representation in DOT language.
            %
            str = FeaturesMatcher_(0, 'matchesGraphAsString', pairwise_matches, conf_threshold);
        end

        function indices = leaveBiggestComponent(features, pairwise_matches, conf_threshold)
            %LEAVEBIGGESTCOMPONENT  Leave biggest component
            %
            %     indices = cv.FeaturesMatcher.leaveBiggestComponent(features, pairwise_matches, conf_threshold)
            %
            % ## Input
            % * __features__ Features of the source images.
            % * **pairwise_matches** Pairwise matches.
            % * **conf_threshold** Threshold for two images are from the same
            %   panorama confidence.
            %
            % ## Output
            % * __indices__ array of image indices (0-based).
            %
            indices = FeaturesMatcher_(0, 'leaveBiggestComponent', features, pairwise_matches, conf_threshold);
        end
    end

end
