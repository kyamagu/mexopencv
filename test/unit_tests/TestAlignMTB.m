classdef TestAlignMTB
    %TestAlignMTB

    methods (Static)
        function test_align
            % sequence of images
            fpath = fullfile(mexopencv.root(),'test');
            files = dir(fullfile(fpath,'memorial0*.png'));
            imgs = cell(1,numel(files));
            for i=1:numel(files)
                imgs{i} = imread(fullfile(fpath,files(i).name));
            end

            obj = cv.AlignMTB();
            out = obj.process(imgs);
            validateattributes(out, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(I) validateattributes(I, ...
                {class(imgs{1})}, {'size',size(imgs{1})}), out);
        end

        function test_shifting
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), 'Grayscale',true);

            shift = randi([0 32], [1 2]);

            obj = cv.AlignMTB('MaxBits',5);
            res = obj.shiftMat(img, shift);
            validateattributes(res, {class(img)}, {'size',size(img)});
            calc = obj.calculateShift(img, res);
            validateattributes(calc, {'numeric'}, ...
                {'vector', 'integer', 'numel',2});
            err = (shift ~= (-calc));
        end

        function test_3
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), 'Grayscale',true);
            obj = cv.AlignMTB();
            [tb, eb] = obj.computeBitmaps(img);
            validateattributes(tb, {class(img)}, {'size',size(img)});
            validateattributes(eb, {class(img)}, {'size',size(img)});
        end
    end
end
