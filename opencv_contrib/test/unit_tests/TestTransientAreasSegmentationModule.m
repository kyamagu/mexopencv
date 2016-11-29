classdef TestTransientAreasSegmentationModule
    %TestTransientAreasSegmentationModule

    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','balloon.jpg');
    end

    methods (Static)
        function test_run
            img = cv.imread(TestTransientAreasSegmentationModule.filename, 'Color',true);
            sz = [size(img,2) size(img,1)];

            retina = cv.Retina(sz);
            retina.run(img);
            magno = retina.getMagnoRAW();

            seg = cv.TransientAreasSegmentationModule(sz);
            seg.clearAllBuffers();
            seg.run(magno);

            sz = seg.getSize();
            validateattributes(sz, {'numeric'}, {'vector', 'integer', 'numel',2});

            transientAreas = seg.getSegmentationPicture();
            validateattributes(transientAreas, {'uint8'}, {'size',[sz(2) sz(1)]});
            transientAreas = logical(transientAreas);
        end

        function test_params
            img = cv.imread(TestTransientAreasSegmentationModule.filename, 'Color',true);
            seg = cv.TransientAreasSegmentationModule([size(img,2) size(img,1)]);

            fname = [tempname() '.xml'];
            cObj = onCleanup(@() TestTransientAreasSegmentationModule.deleteFile(fname));
            seg.write(fname);
            seg.setup(fname);

            seg.setupParameters('LocalEnergyTemporalConstant',0.5);

            str = seg.printSetup();
            validateattributes(str, {'char'}, {'row', 'nonempty'});

            params = seg.getParameters();
            validateattributes(params, {'struct'}, {'scalar'});
        end
    end

    %% helper functions
    methods (Static)
        function deleteFile(fname)
            if exist(fname, 'file') == 2
                delete(fname);
            end
        end
    end

end
