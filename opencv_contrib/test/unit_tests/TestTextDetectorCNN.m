classdef TestTextDetectorCNN
    %TestTextDetectorCNN

    methods (Static)
        function test_1
            im = fullfile(mexopencv.root(), 'test', 'books_right.jpg');
            img = cv.imread(im, 'FlipChannels',false);

            net = load_textdetecotr_cnn();
            [rects, confs] = net.detect(img);

            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
                validateattributes(confs, {'numeric'}, ...
                    {'vector', 'real', 'numel',numel(rects)});
            end
        end
    end

end

function net = load_textdetecotr_cnn()
    %TODO: download files (or run the sample "textboxes_demo.m")
    rootdir = fullfile(mexopencv.root(), 'test', 'dnn', 'TextBoxes');
    modelTxt = fullfile(rootdir, 'textbox.prototxt');
    modelBin = fullfile(rootdir, 'TextBoxes_icdar13.caffemodel');
    if exist(modelTxt, 'file') ~= 2 || exist(modelBin, 'file') ~= 2
        error('mexopencv:testskip', 'missing data');
    end
    net = cv.TextDetectorCNN(modelTxt, modelBin);
end
