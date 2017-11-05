classdef TestPeiLinNormalization
    %TestPeiLinNormalization

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','shape03.png'), 'Grayscale',true);
            T = cv.PeiLinNormalization(img);
            validateattributes(T, {'double'}, {'size',[2 3]});
        end

        function test_error_argnum
            try
                cv.PeiLinNormalization();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
