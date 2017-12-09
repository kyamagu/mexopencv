classdef ExposureCompensator < handle
    %EXPOSURECOMPENSATOR  Class for all exposure compensators
    %
    % See also: cv.Stitcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = ExposureCompensator(compensatorType, varargin)
            %EXPOSURECOMPENSATOR  Constructor
            %
            %     obj = cv.ExposureCompensator(compensatorType)
            %     obj = cv.ExposureCompensator(compensatorType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __compensatorType__ exposure compensator type. One of:
            %   * __NoExposureCompensator__ Stub exposure compensator which
            %     does nothing.
            %   * __GainCompensator__ Exposure compensator which tries to
            %     remove exposure related artifacts by adjusting image
            %     intensities, see [BL07] and [WJ10] for details.
            %   * __BlocksGainCompensator__ Exposure compensator which tries
            %     to remove exposure related artifacts by adjusting image
            %     block intensities, see [UES01] for details.
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `BlocksGainCompensator`
            % * __Width__ Block width. default 32
            % * __Heigth__ Block height. default 32
            %
            % ## References
            % [BL07]:
            % > Matthew Brown and David G Lowe.
            % > "Automatic panoramic image stitching using invariant features".
            % > International journal of computer vision, 74(1):59-73, 2007.
            %
            % [WJ10]:
            % > Wei Xu and Jane Mulligan. "Performance evaluation of color
            % > correction approaches for automatic multi-view image and video
            % > stitching". In Computer Vision and Pattern Recognition (CVPR),
            % > 2010 IEEE Conference on, pages 263-270. IEEE, 2010.
            %
            % [UES01]:
            % > Matthew Uyttendaele, Ashley Eden, and R Skeliski.
            % > "Eliminating ghosting and exposure artifacts in image mosaics".
            % > In Computer Vision and Pattern Recognition, 2001. CVPR 2001.
            % > Proceedings of the 2001 IEEE Computer Society Conference on,
            % > volume 2, pages II-509. IEEE, 2001.
            %
            % See also: cv.ExposureCompensator.apply
            %
            this.id = ExposureCompensator_(0, 'new', compensatorType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ExposureCompensator
            %
            if isempty(this.id), return; end
            ExposureCompensator_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = ExposureCompensator_(this.id, 'typeid');
        end
    end

    %% ExposureCompensator
    methods
        function feed(this, corners, images, masks)
            %FEED  Processes the images
            %
            %     obj.feed(corners, images, masks)
            %
            % ## Input
            % * __corners__ Source image top-left corners. Cell-array of 2D
            %   points `{[x,y], ...}`.
            % * __images__ Source cell-array of images.
            % * __masks__ Cell-array of image masks to update (the value 255
            %   is used to detect where image is).
            %
            % See also: cv.ExposureCompensator.apply
            %
            ExposureCompensator_(this.id, 'feed', corners, images, masks);
        end

        function image = apply(this, index, corner, image, mask)
            %APPLY  Compensate exposure in the specified image
            %
            %     image = obj.apply(index, corner, image, mask)
            %
            % ## Input
            % * __index__ Image index.
            % * __corner__ Image top-left corner `[x,y]`.
            % * __image__ Image to process.
            % * __mask__ Image 8-bit mask.
            %
            % ## Output
            % * __image__ processed image.
            %
            % See also: cv.ExposureCompensator.feed
            %
            image = ExposureCompensator_(this.id, 'apply', index, corner, image, mask);
        end
    end

    %% GainCompensator
    methods
        function g = gains(this)
            %GAINS  Gains
            %
            %     g = obj.gains()
            %
            % ## Output
            % * __g__ double vector of gains.
            %
            g = ExposureCompensator_(this.id, 'gains');
        end
    end

end
