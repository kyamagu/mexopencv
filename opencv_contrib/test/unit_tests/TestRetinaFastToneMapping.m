classdef TestRetinaFastToneMapping
    %TestRetinaFastToneMapping

    methods (Static)
        function test_tonemap
            %TODO: intermittent MATLAB crashes!
            if true
                error('mexopencv:testskip', 'todo');
            end

            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            hdr = cv.resize(hdr, 0.5, 0.5);
            sz = size(hdr);

            retina = cv.RetinaFastToneMapping([sz(2) sz(1)]);
            retina.setup('PhotoreceptorsNeighborhoodRadius',3, ...
                'GanglioncellsNeighborhoodRadius',1.5);

            ldr = retina.applyFastToneMapping(hdr);
            validateattributes(ldr, {'uint8'}, {'size',[sz(1) sz(2) 3]});
        end
    end

end
