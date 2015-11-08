classdef TestPencilSketch
    %TestPencilSketch

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            [out1,out2] = cv.pencilSketch(img);
            validateattributes(out1, {class(img)}, {'size',[size(img,1) size(img,2)]});
            validateattributes(out2, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            [out1,out2] = cv.pencilSketch(img, 'SigmaS',60 ,'SigmaR',0.07, ...
                'ShadeFactor',0.02);
            validateattributes(out1, {class(img)}, {'size',[size(img,1) size(img,2)]});
            validateattributes(out2, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.pencilSketch();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
