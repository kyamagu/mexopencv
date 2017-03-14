classdef TestTonemap
    %TestTonemap

    methods (Static)
        function test_1
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            hdr = cv.resize(hdr, 0.5, 0.5);

            obj = cv.Tonemap();
            obj.Gamma = 2.2;

            ldr = obj.process(hdr);
            validateattributes(ldr, {'single'}, ...
                {'size',size(hdr), 'nonnegative'});
        end
    end

end
