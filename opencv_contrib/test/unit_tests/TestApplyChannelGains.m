classdef TestApplyChannelGains
    %TestApplyChannelGains

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            gains = rand(1,3) + 1;
            out = cv.applyChannelGains(img, gains);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.applyChannelGains();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
