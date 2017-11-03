classdef WBDetector < handle
    %WBDETECTOR  WaldBoost detector - Object Detection using Boosted Features
    %
    % Class for object detection using WaldBoost from [Sochman05].
    % Uses a Waldboost cascade and local binary patterns computed as integral
    % features for 2D object detection.
    %
    % ## Example
    % The basic usage is the following:
    %
    %     % train
    %     detector = cv.WBDetector();
    %     detector.train('/path/to/pos/', '/path/to/neg/');
    %     detector.write('model.xml');
    %
    %     % detect
    %     detector = cv.WBDetector();
    %     detector.read('model.xml');
    %     img = cv.imread('image.png', 'Grayscale',true);
    %     [bboxes,conf] = detector.detect(img);
    %     for i=1:numel(bboxes)
    %         img = cv.rectangle(img, bboxes{i}, 'Color',[0 255 0]);
    %     end
    %     imshow(img)
    %
    % ## References
    % [Sochman05]:
    % > J. Sochman and J. Matas. "WaldBoost - Learning for Time Constrained
    % > Sequential Detection", IEEE Conference on CVPR 2005, Vol 2, p. 150-156
    % > [PDF](https://dspace.cvut.cz/bitstream/handle/10467/9494/2005-Waldboost-learning-for-time-constrained-sequential-detection.pdf?sequence=1)
    %
    % See also: cv.WBDetector.WBDetector, cv.WBDetector.detect,
    %  detectPeopleACF, peopleDetectorACF, trainACFObjectDetector
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = WBDetector()
            %WBDETECTOR  Create instance of WBDetector
            %
            %     detector = cv.WBDetector()
            %
            % See also: cv.WBDetector, cv.WBDetector.train, cv.WBDetector.read
            %
            this.id = WBDetector_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     detector.delete()
            %
            % See also: cv.WBDetector
            %
            if isempty(this.id), return; end
            WBDetector_(this.id, 'delete');
        end

        function read(this, fname_or_str, varargin)
            %READ  Read detector from file
            %
            %     detector.read(filename)
            %     detector.read(str, 'FromString',true)
            %     detector.read(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the file to read from.
            % * __str__ String containing serialized detector you want to load.
            %
            % ## Options
            % * __FromString__ Logical flag to indicate whether the input is a
            %   a filename or a string containing the serialized detector.
            %   default false
            %
            % See also: cv.WBDetector.write
            %
            WBDetector_(this.id, 'read', fname_or_str, varargin{:});
        end

        function varargout = write(this, filename)
            %WRITE  Write detector to file
            %
            %     detector.write(filename)
            %     str = detector.write(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % ## Output
            % * __str__ optional output. If requested, the object is persisted
            %   to a string in memory instead of writing to disk.
            %
            % See also: cv.WBDetector.read
            %
            [varargout{1:nargout}] = WBDetector_(this.id, 'write', filename);
        end

        function train(this, pos_samples, neg_imgs)
            %TRAIN  Train WaldBoost detector
            %
            %     detector.train(pos_samples, neg_imgs)
            %
            % ## Input
            % * **pos_samples** Path to directory with cropped positive
            %   samples.
            % * **neg_imgs** Path to directory with negative (background)
            %   images.
            %
            % See also: cv.WBDetector.detect
            %
            WBDetector_(this.id, 'train', pos_samples, neg_imgs);
        end

        function [bboxes,confidences] = detect(this, img)
            %DETECT  Detect objects on image using WaldBoost detector
            %
            %     [bboxes,confidences] = detector.detect(img)
            %
            % ## Input
            % * __img__ Input image for detection.
            %
            % ## Output
            % * __bboxes__ Bounding boxes coordinates.
            % * __confidences__ Confidence values for bounding boxes.
            %
            % See also: cv.WBDetector.WBDetector
            %
            [bboxes,confidences] = WBDetector_(this.id, 'detect', img);
        end
    end

end
