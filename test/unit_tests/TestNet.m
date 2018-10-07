classdef TestNet
    %TestNet

    properties (Constant)
        im1 = fullfile(mexopencv.root(), 'test', 'cat.jpg');
        im2 = fullfile(mexopencv.root(), 'test', 'space_shuttle.jpg');
    end

    methods (Static)
        function test_blobs
            imgs = cell(1,4);
            for i=1:numel(imgs)
                imgs{i} = rand(50, 50, 3, 'single');
            end
            blob = cv.Net.blobFromImages(imgs, 'SwapRB',false, 'Crop',false);
            out = cv.Net.imagesFromBlob(blob);
            assert(isequal(out, imgs));
        end

        function test_caffe_googlenet
            % load net and images
            net = load_bvlc_googlenet();
            img1 = cv.imread(TestNet.im1, 'FlipChannels',false);
            img2 = cv.imread(TestNet.im2, 'FlipChannels',false);

            % forward pass (blob from one image)
            blob = cv.Net.blobFromImages(img1, 'Size',[224 224]);
            net.setInput(blob, 'data');
            prob = net.forward('prob');
            validateattributes(prob, {'numeric'}, ...
                {'vector', 'real', 'numel',1000, '>=',0, '<=',1});
            [p,idx] = max(prob,[],2);
            %assert(abs(sum(prob) - 1) < 1e-4);

            % forward pass (blob from multiple images)
            blob = cv.Net.blobFromImages({img1,img2}, 'Size',[224 224]);
            net.setInput(blob);
            prob = net.forward();
            validateattributes(prob, {'numeric'}, ...
                {'size',[2 1000], 'real', '>=',0, '<=',1});
            [p,idx] = max(prob,[],2);
            %assert(all(abs(sum(prob,2) - 1) < 1e-4));
        end

        function test_intermediate_blobs
            net = load_bvlc_googlenet();
            img1 = cv.imread(TestNet.im1, 'FlipChannels',false);
            img2 = cv.imread(TestNet.im2, 'FlipChannels',false);

            blob = cv.Net.blobFromImages(img1, 'Size',[224 224]);
            net.setInput(blob, 'data');
            blobs = net.forward({
                'conv1/7x7_s2'
                'conv1/relu_7x7'
                'inception_4c/1x1'
                'inception_4c/relu_1x1'
            });

            blob = cv.Net.blobFromImages({img1,img2}, 'Size',[224 224]);
            net.setInput(blob, 'data');
            blobs = net.forwardAndRetrieve('conv1/7x7_s2');
        end

        function test_shrink_caffe_fp16
            model = fullfile(mexopencv.root(), 'test', 'dnn', 'GoogLeNet', ...
                'bvlc_googlenet.caffemodel');
            model_fp16 = fullfile(tempdir(), 'bvlc_googlenet_fp16.caffemodel');
            if exist(model, 'file') ~= 2
                error('mexopencv:testskip', 'missing data');
            end

            cObj = onCleanup(@() delete(model_fp16));
            cv.Net.shrinkCaffeModel(model, model_fp16);
            assert(exist(model_fp16, 'file') == 2);
        end

        function test_layers
            % Convolution layer
            % (64 filters each of size 7x7, 3x3 padding, 2x2 stride)
            % output size of convolution is: (H + 2*pad - kernel_size)/stride + 1
            lp = struct();
            lp.name = 'conv/7x7_s2';
            lp.type = 'Convolution';
            lp.dict.num_output = int32(64);
            lp.dict.kernel_size = int32(7);
            lp.dict.stride = int32(2);
            lp.dict.pad = int32(3);
            lp.dict.bias_term = true;
            lp.blobs = {
                rand(64,3,7,7,'single')*2-1,  % weights
                rand(1,1,1,64,'single')*2-1   % biases
            };

            % add layer
            net = cv.Net();
            lp_id = net.addLayer(lp.name, lp.type, lp);
            validateattributes(lp_id, {'int32'}, {'scalar', 'integer'});
            assert(lp_id ~= -1);

            % connect input layer to conv layer
            net.setInputsNames('data');
            if true
                net.connect(0, 0, lp_id, 0);
            elseif true
                %net.connect('_input.0', lp.name);
                net.connect('_input', lp.name);
            else
                net.connect('_input.data', lp.name);
            end

            % feed net batch of two 224x224 BGR images, and run forward pass
            net.setInput(rand(2,3,224,224,'single')*255, 'data');
            out = net.forward(lp.name);
            assert(isequal(size(out), [2 64 112 112]))

            b0 = net.getParam(lp_id, 0);
            validateattributes(b0, {'numeric'}, {'real'});
            %assert(isequal(b0, lp.blobs{1}));

            b1 = net.getParam(lp.name, 1);
            validateattributes(b1, {'numeric'}, {'real'});
            %assert(isequal(b1, lp.blobs{2}));

            net.setParam(lp_id, 0, lp.blobs{1});
            net.setParam(lp.name, 1, lp.blobs{2});

            net.setPreferableBackend('Default') % 'Halide'
            net.setPreferableTarget('CPU')      % 'OpenCL'
            net.enableFusion(true);

            id = net.getUnconnectedOutLayers();
            validateattributes(id, {'numeric'}, {'vector', 'integer'});
            %assert(isequal(id, lp_id))  % output layer

            id = net.getLayerId('_input');
            assert(id == 0);  % special input layer with id=0

            types = net.getLayerTypes();
            assert(iscellstr(types));

            counts = cellfun(@(t) net.getLayersCount(t), types);
            validateattributes(counts, {'numeric'}, {'vector', 'integer'});

            names = net.getLayerNames();
            assert(iscellstr(names));
            %assert(isequal(names{1}, lp.name))

            id = net.getLayerId(names{1});
            validateattributes(id, {'numeric'}, {'scalar', 'integer'});
            assert(lp_id ~= -1);
            %assert(isequal(id, lp_id))

            if true
                layer = net.getLayer(id);
            else
                layer = net.getLayer(names{1});
            end
            assert(isstruct(layer) && isscalar(layer));
            validateattributes(layer.blobs, {'cell'}, {'vector', 'numel',2});
            %assert(isequal(layer.name, lp.name))
            %assert(isequal(layer.type, lp.type))
            %assert(isequal(layer.blobs(:), lp.blobs(:)))

            layers = net.getLayerInputs(id);
            assert(isstruct(layers));

            %if true
            %    net.deleteLayer(lp_id);
            %else
            %    net.deleteLayer(lp.name);
            %end
        end
    end

end

function net = load_bvlc_googlenet()
    %TODO: download files (or run the sample "caffe_googlenet_demo.m")
    rootdir = fullfile(mexopencv.root(), 'test', 'dnn', 'GoogLeNet');
    modelTxt = fullfile(rootdir, 'deploy.prototxt');
    modelBin = fullfile(rootdir, 'bvlc_googlenet.caffemodel');
    if exist(modelTxt, 'file') ~= 2 || exist(modelBin, 'file') ~= 2
        error('mexopencv:testskip', 'missing data');
    end

    net = cv.Net('Caffe', modelTxt, modelBin);
    assert(~net.empty());
end
