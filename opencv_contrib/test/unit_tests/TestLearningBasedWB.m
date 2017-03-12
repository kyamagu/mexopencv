classdef TestLearningBasedWB
    %TestLearningBasedWB

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','cat.jpg'), ...
                'Color',true, 'ReduceScale',2);
            wb = cv.LearningBasedWB();
            out = wb.balanceWhite(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end
    end

end
