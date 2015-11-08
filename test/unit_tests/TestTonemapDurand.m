classdef TestTonemapDurand
    %TestTonemapDurand

    methods (Static)
        function test_1
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            obj = cv.TonemapDurand();
            obj.Gamma = 2.2;
            obj.Contrast = 4.0;
            obj.Saturation = 1.0;
            obj.SigmaSpace = 2.0;
            obj.SigmaColor = 2.0;
            ldr = obj.process(hdr);
            validateattributes(ldr, {'single'}, ...
                {'size',size(hdr), 'nonnegative'});
            %TODO: output HDR is not always in [0,1] range
        end
    end
end
