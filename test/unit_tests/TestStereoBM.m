classdef TestStereoBM
    %TestStereoBM
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            bm = cv.StereoBM('Preset','Basic',...
                             'NDisparities',0,...
                             'SADWindowSize',21);
        end
    end
    
end

