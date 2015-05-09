classdef TestStereoBM
    %TestStereoBM
    properties (Constant)
    end

    methods (Static)
        function test_1
            bm = cv.StereoBM('NumDisparities',0, 'BlockSize',21);
        end
    end

end
