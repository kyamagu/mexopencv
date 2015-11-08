classdef TestTonemapDrago
    %TestTonemapDrago

    methods (Static)
        function test_1
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            obj = cv.TonemapDrago();
            obj.Gamma = 2.2;
            obj.Saturation = 1.0;
            obj.Bias = 0.85;
            ldr = obj.process(hdr);
            validateattributes(ldr, {'single'}, ...
                {'size',size(hdr), 'nonnegative'});
        end
    end
end
