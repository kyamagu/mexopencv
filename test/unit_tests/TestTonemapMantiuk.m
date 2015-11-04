classdef TestTonemapMantiuk
    %TestTonemapMantiuk

    methods (Static)
        function test_1
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            obj = cv.TonemapMantiuk();
            obj.Gamma = 2.2;
            obj.Scale = 0.7;
            obj.Saturation = 1.0;
            ldr = obj.process(hdr);
            validateattributes(ldr, {'single'}, ...
                {'size',size(hdr), 'nonnegative'});
        end
    end
end
