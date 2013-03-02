classdef TestImencode
    %TestImencode
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            buf = cv.imencode('.jpg', TestImencode.im);
            assert(~isempty(buf));
        end
        
        function test_error_1
            try
                cv.imencode();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

