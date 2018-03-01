classdef TestInferBbox
    %TestInferBbox

    properties (Constant)
        fields = {'bbox', 'class_idx', 'label_name', 'class_prob'};
    end

    methods (Static)
        function test_1
            net = load_squeezedet();

            im = fullfile(mexopencv.root(), 'test', 'rgb.jpg');
            img = cv.imread(im, 'Color',true, 'FlipChannels',false);
            blob = cv.Net.blobFromImages(img, ...
                'SwapRB',false, 'Size',[416 416], 'Mean',[104 117 123]);

            net.setInput(blob);
            out = net.forwardAndRetrieve('slice');
            delta_bboxs = permute(out{3}, [2 3 4 1]);
            net.setInput(blob);
            out = net.forward({'softmax', 'sigmoid'});
            class_scores = permute(out{1}, [2 3 4 1]);
            conf_scores = permute(out{2}, [2 3 4 1]);

            detections = cv.InferBbox(delta_bboxs, class_scores, conf_scores, ...
                'Threshold',0.5);
            validateattributes(detections, {'struct'}, {'vector'});
            assert(all(ismember(TestInferBbox.fields, fieldnames(detections))));
            if ~isempty(detections)
                arrayfun(@(d) validateattributes(d.bbox, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), detections);
                arrayfun(@(d) validateattributes(d.class_idx, {'numeric'}, ...
                    {'scalar', 'integer'}), detections);
                arrayfun(@(d) validateattributes(d.label_name, {'char'}, ...
                    {'vector', 'row'}), detections);
                arrayfun(@(d) validateattributes(d.class_prob, {'numeric'}, ...
                    {'scalar', 'real'}), detections);
            end
        end

        function test_error_argnum
            try
                cv.InferBbox();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function net = load_squeezedet()
    %TODO: download files (or run the sample "dnn_objectdetect_demo.m")
    rootdir = fullfile(mexopencv.root(), 'test', 'dnn', 'SqueezeDet');
    modelTxt = fullfile(rootdir, 'SqueezeDet_deploy.prototxt');
    modelBin = fullfile(rootdir, 'SqueezeDet.caffemodel');
    if exist(modelTxt, 'file') ~= 2 || exist(modelBin, 'file') ~= 2
        error('mexopencv:testskip', 'missing data');
    end

    net = cv.Net('Caffe', modelTxt, modelBin);
    assert(~net.empty());
end
