classdef TestValidateDisparity
    %TestValidateDisparity

    methods (Static)
        function test_1
            im1 = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            im2 = imread(fullfile(mexopencv.root(),'test','tsukuba_r.png'));
            bm = cv.StereoBM('NumDisparities',16, 'BlockSize',15);
            disparity = bm.compute(im1, im2);
            cost = randi([0 1000], size(disparity), 'int16');
            D = cv.validateDisparity(disparity, cost, ...
                'MinDisparity',0, 'NumDisparities',64, 'Disp12MaxDiff',1);
            validateattributes(D, {class(disparity)}, ...
                {'size',size(disparity)});
        end

        function test_error_1
            try
                cv.validateDisparity();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
