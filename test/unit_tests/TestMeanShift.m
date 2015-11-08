classdef TestMeanShift
    %TestMeanShift

    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            im = im(:,:,1:2);
            edges = {linspace(0,256,32+1), linspace(0,256,32+1)};
            H = cv.calcHist(im, edges);
            B = cv.calcBackProject(single(im), H, edges);
            win = [150 330 190 130];
            [win2,iter] = cv.meanShift(B, win);
            validateattributes(win2, {'numeric'}, {'vector', 'numel',4});
            validateattributes(iter, {'numeric'}, {'scalar', 'nonnegative'});
            assert(isequal(win2(3:4), win(3:4)), ...
                'search window size should not change');
        end

        function test_error_1
            try
                cv.meanShift();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
