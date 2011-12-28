classdef TestBilateralFilter
    %TestBilateralFilter
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestBilateralFilter.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
        function test_1
            result = bilateralFilter(TestBilateralFilter.img);
        end
        
        function test_2
			result = bilateralFilter(TestBilateralFilter.img,'BorderType','Wrap');
        end
        
        function test_error_1
            try
                bilateralFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_2
            try
                bilateralFilter(TestBilateralFilter.img,'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_3
            try
                bilateralFilter(TestBilateralFilter.img,'BorderType','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

