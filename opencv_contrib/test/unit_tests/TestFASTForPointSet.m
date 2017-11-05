classdef TestFASTForPointSet
    %TestFASTForPointSet

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            kpts = [
                randi([0 size(img,2)-1], [100 1]), ...
                randi([0 size(img,1)-1], [100 1])
            ];
            kpts = cv.KeyPointsFilter.convertFromPoints(kpts);
            kpts = cv.FASTForPointSet(img, kpts, 'Threshold',10);
            validateattributes(kpts, {'struct'}, {'vector'});
        end

        function test_error_argnum
            try
                cv.FASTForPointSet();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
