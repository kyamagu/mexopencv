classdef TestBIF
    %TestBIF

    methods (Static)
        function test_1
            img = rand(60, 'single')*2 - 1;
            obj = cv.BIF();
            feats = obj.compute(img);
            validateattributes(feats, {'numeric'}, {'vector', 'real'});
        end
    end

end
