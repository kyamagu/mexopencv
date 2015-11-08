classdef TestPhaseCorrelate
    %TestPhaseCorrelate

    methods (Static)
        function test_1
            im1 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), 'Grayscale',true);
            im2 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), 'Grayscale',true);
            im1 = double(im1) / 255;
            im2 = double(im2) / 255;
            [pshift,resp] = cv.phaseCorrelate(im1, im2);
            validateattributes(pshift, {'numeric'}, {'vector', 'numel',2});
            validateattributes(resp, {'double'}, {'scalar'});
        end

        function test_2
            im1 = rand(10);
            im2 = circshift(im1, [1 2]);
            win = cv.createHanningWindow([10 10]);
            pshift = cv.phaseCorrelate(im1, im2, 'Window',win);
        end

        function test_error_1
            try
                cv.phaseCorrelate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
