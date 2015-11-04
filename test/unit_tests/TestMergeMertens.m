classdef TestMergeMertens
    %TestMergeMertens

    methods (Static)
        function test_1
            fpath = fullfile(mexopencv.root(),'test');
            files = dir(fullfile(fpath,'memorial*.png'));
            imgs = cell(1,numel(files));
            for i=1:numel(files)
                imgs{i} = imread(fullfile(fpath,files(i).name));
            end

            obj = cv.MergeMertens();
            ldr = obj.process(imgs);
            validateattributes(ldr, {'single'}, {'size',size(imgs{1})});
            %TODO: output LDR is not always in [0,1] range
        end
    end
end
