classdef TestScharr
    %TestScharr
    properties (Constant)
        img = uint8([...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
        ]);
    end

    methods (Static)
        function test_1
            result = cv.Scharr(TestScharr.img);
            validateattributes(result, {class(TestScharr.img)}, ...
                {'size',size(TestScharr.img)});
        end

        function test_2
            result = cv.Scharr(TestScharr.img, ...
                'XOrder',0, 'YOrder',1, 'Scale',1, 'Delta',0, ...
                'BorderType','Default', 'DDepth','double');
            validateattributes(result, {'double'}, ...
                {'size',size(TestScharr.img)});
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.Scharr(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_4
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), 'Grayscale',true);
            result = cv.Scharr(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.Scharr();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
