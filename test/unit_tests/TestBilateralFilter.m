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
        
        function test_error_1
            try
                bilateralFilter();
            catch e
                assert(strcmp(e.identifier,'bilateralFilter:invalidArgs'));
            end
        end
        
        function test_error_2
            try
                bilateralFilter(TestBilateralFilter.img,'foo','bar');
            catch e
                assert(strcmp(e.identifier,'bilateralFilter:invalidOption'));
            end
        end
    end
    
end

