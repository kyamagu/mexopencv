classdef TextDetectorCNN < handle
    %TEXTDETECTORCNN  Class providing functionality of text detection
    %
    % This class provides the functionality of text bounding box detection
    % (finds bounding boxes of text words given an input image).
    %
    % This class uses OpenCV dnn module to load pre-trained model described in
    % [LiaoSBWL17].
    % The original repository with the modified SSD Caffe version:
    % [GitHub](https://github.com/MhLiao/TextBoxes).
    %
    % Model (90.68 MB) can be downloaded from
    % [DropBox](https://www.dropbox.com/s/g8pjzv2de9gty8g/TextBoxes_icdar13.caffemodel?dl=0).
    %
    % Modified `.prototxt` file with the model description can be obtained from
    % [GitHub](https://github.com/opencv/opencv_contrib/raw/3.4.1/modules/text/samples/textbox.prototxt).
    %
    % ## References
    % [LiaoSBWL17]:
    % > Minghui Liao, Baoguang Shi, Xiang Bai, Xinggang Wang, and Wenyu Liu.
    % > "Textboxes: A fast text detector with a single deep neural network".
    % > In AAAI, 2017.
    %
    % See also: cv.TextDetectorCNN.TextDetectorCNN, cv.Net
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% TextDetectorCNN
    methods
        function this = TextDetectorCNN(varargin)
            %TEXTDETECTORCNN  Creates an instance using the provided parameters
            %
            %     obj = cv.TextDetectorCNN(modelArchFilename, modelWeightsFilename)
            %     obj = cv.TextDetectorCNN(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __modelArchFilename__ path to the prototxt file describing the
            %   classifiers architecture (the `.prototxt` file).
            % * __modelWeightsFilename__ path to the file containing the
            %   pretrained weights of the model in caffe-binary form
            %   (the `.caffemodel` file).
            %
            % ## Options
            % * __DetectionSizes__ a list of sizes for multiscale detection.
            %   The values
            %   `{[300,300], [700,500], [700,300], [700,700], [1600,1600]}`
            %   are recommended in [LiaoSBWL17] to achieve the best quality.
            %   default `{[300,300]}`.
            %
            % See also: cv.TextDetectorCNN
            %
            this.id = TextDetectorCNN_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.TextDetectorCNN
            %
            if isempty(this.id), return; end
            TextDetectorCNN_(this.id, 'delete');
        end
    end

    %% TextDetector
    methods
        function [bbox, conf] = detect(this, img)
            %DETECT  Detect text inside an image
            %
            %     [bbox, conf] = obj.detect(img)
            %
            % ## Input
            % * __img__ an image to process, expected to be a 8-bit color
            %   image of any size.
            %
            % ## Output
            % * __bbox__ a vector of rectangles of the detected word bounding
            %   boxes.
            % * __conf__ a vector of float of the confidences the classifier
            %   has for the corresponding bounding boxes.
            %
            % See also: cv.TextDetectorCNN.TextDetectorCNN
            %
            [bbox, conf] = TextDetectorCNN_(this.id, 'detect', img);
        end
    end

end
