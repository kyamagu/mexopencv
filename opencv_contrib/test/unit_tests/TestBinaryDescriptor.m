classdef TestBinaryDescriptor
    %TestBinaryDescriptor

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'angle', 'class_id', 'octave', 'pt', 'response', ...
            'size', 'startPoint', 'endPoint', 'startPointInOctave', ...
            'endPointInOctave', 'lineLength', 'numOfPixels'};
    end

    methods (Static)
        function test_detect_compute_img
            obj = cv.BinaryDescriptor('NumOfOctave',1);
            ntype = obj.defaultNorm();

            img = imread(TestBinaryDescriptor.im);
            klines = obj.detect(img);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(klines))));

            [desc, klines2] = obj.compute(img, klines);
            validateattributes(klines2, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(klines2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(klines2) 32]});
        end

        function test_detect_compute_imgset
            img = imread(TestBinaryDescriptor.im);
            imgs = {img, img};
            obj = cv.BinaryDescriptor();

            klines = obj.detect(imgs);
            validateattributes(klines, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), klines);
            cellfun(@(kpt) assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(kpt)))), klines);

            [descs, klines] = obj.compute(imgs, klines);
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) 32]}), descs, klines);
        end

        function test_detectAndCompute
            img = imread(TestBinaryDescriptor.im);
            obj = cv.BinaryDescriptor();

            [klines, desc] = obj.detectAndCompute(img, 'ReturnFloatDescr',false);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(klines))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(klines) 32]});  %NOTE: not obj.descriptorSize()

            [klines, desc] = obj.detectAndCompute(img, 'ReturnFloatDescr',true);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(klines))));
            validateattributes(desc, {'single'}, ...
                {'size',[numel(klines) 9*8]});  %NOTE: not obj.descriptorSize()
        end

        function test_detectAndCompute_providedKeyLines
            img = imread(TestBinaryDescriptor.im);
            obj = cv.BinaryDescriptor();

            klines = obj.detect(img);
            klines = klines(1:min(20,end));

            [~, desc] = obj.detectAndCompute(img, 'KeyLines',klines);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(klines) 32]});
        end

        function test_detect_mask
            img = imread(TestBinaryDescriptor.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.BinaryDescriptor();

            klines = obj.detect(img, 'Mask',mask);
            validateattributes(klines, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptor.kfields, fieldnames(klines))));
        end
    end

end
