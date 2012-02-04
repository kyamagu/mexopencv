classdef TestPutText
    %TestPutText
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = 255*ones(128,128,3,'uint8');
            a = cv.putText(im, 'foo', [5,30], 'FontFace','HersheySimplex',...
                                              'FontStyle','Regular',...
                                              'Thickness', 2,...
                                              'LineType', 'AA');
        end
        
        function test_error_1
            try
                cv.putText();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

