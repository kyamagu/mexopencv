classdef TestTonemapReinhard
    %TestTonemapReinhard

    methods (Static)
        function test_1
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            obj = cv.TonemapReinhard();
            obj.Gamma = 2.2;
            obj.Intensity = 0.0;
            obj.LightAdaptation = 1.0;
            obj.ColorAdaptation = 0.0;
            ldr = obj.process(hdr);
            validateattributes(ldr, {'single'}, ...
                {'size',size(hdr), 'nonnegative'});
        end
    end
end
