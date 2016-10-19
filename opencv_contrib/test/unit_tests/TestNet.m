classdef TestNet
    %TestNet
    properties (Constant)
        im1 = fullfile(mexopencv.root(), 'test', 'cat.jpg');
        im2 = fullfile(mexopencv.root(), 'test', 'space_shuttle.jpg');
    end

    methods (Static)
        function test_img
            % load net
            [modelTxt, modelBin] = load_bvlc_googlenet();
            if ~exist(modelTxt, 'file') || ~exist(modelBin, 'file')
                disp('SKIP');
                return;
            end
            net = cv.Net();
            net.importCaffe(modelTxt, modelBin);

            % set input blob (one image)
            img1 = cv.imread(TestNet.im1, 'FlipChannels',false);
            img1 = cv.resize(img1, [224 224]);
            net.setBlob('.data', single(img1));

            % verify we get same blob
            blob = net.getBlob('.data');
            blob = uint8(permute(blob, [3 4 2 1]));
            assert(isequal(blob,img1));

            % forward pass
            net.forward();
            prob = net.getBlob('prob');
            validateattributes(prob, {'numeric'}, ...
                {'vector', 'real', 'numel',1000, '>=',0, '<=',1});
            [p,idx] = max(prob,[],2);
            %assert(abs(sum(prob) - 1) < 1e-4);
        end

        function test_imgs
            [modelTxt, modelBin] = load_bvlc_googlenet();
            if ~exist(modelTxt, 'file') || ~exist(modelBin, 'file')
                disp('SKIP');
                return;
            end
            net = cv.Net();
            net.importCaffe(modelTxt, modelBin);

            img1 = cv.imread(TestNet.im1, 'FlipChannels',false);
            img2 = cv.imread(TestNet.im2, 'FlipChannels',false);
            img1 = cv.resize(img1, [224 224]);
            img2 = cv.resize(img2, [224 224]);
            net.setBlob('.data', {img1,img2});

            blob = net.getBlob('.data');
            blob = uint8(permute(blob, [3 4 2 1]));
            assert(isequal(blob(:,:,:,1),img1));
            assert(isequal(blob(:,:,:,2),img2));

            net.forward();
            prob = net.getBlob('prob');
            validateattributes(prob, {'numeric'}, ...
                {'size',[2 1000], 'real', '>=',0, '<=',1});
            [p,idx] = max(prob,[],2);
            %assert(all(abs(sum(prob,2) - 1) < 1e-4));
        end
    end

end

function [modelTxt, modelBin] = load_bvlc_googlenet()
    %TODO: download files (or run the sample "caffe_googlenet_demo.m")
    rootdir = fullfile(mexopencv.root(), 'test', 'dnn');
    modelTxt = fullfile(rootdir, 'bvlc_googlenet.prototxt');
    modelBin = fullfile(rootdir, 'bvlc_googlenet.caffemodel');
end
