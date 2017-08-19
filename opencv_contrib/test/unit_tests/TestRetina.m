classdef TestRetina
    %TestRetina

    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_run
            img = cv.imread(TestRetina.filename, 'Color',true, 'ReduceScale',2);
            retina = cv.Retina([size(img,2) size(img,1)], ...
                'ColorMode',true, 'ColorSamplingMethod','Bayer', ...
                'UseRetinaLogSampling',false, 'ReductionFactor',1.0, ...
                'SamplingStrength',10);

            retina.clearBuffers();
            retina.run(img);

            %sz = [size(img,2) size(img,1)];
            sz = retina.getOutputSize();

            parvo = retina.getParvo();
            validateattributes(parvo, {'uint8'}, {'size',[sz(2) sz(1) 3]});

            magno = retina.getMagno();
            validateattributes(magno, {'uint8'}, {'size',[sz(2) sz(1)]});

            parvo = retina.getParvoRAW();
            validateattributes(parvo, {'single'}, {'vector', 'numel',prod(sz)*3});

            magno = retina.getMagnoRAW();
            validateattributes(magno, {'single'}, {'vector', 'numel',prod(sz)});
        end

        function test_methods
            img = cv.imread(TestRetina.filename, 'Color',true, 'ReduceScale',2);
            retina = cv.Retina([size(img,2) size(img,1)]);

            sz = retina.getInputSize();
            validateattributes(sz, {'numeric'}, {'vector', 'integer', 'numel',2});

            sz = retina.getOutputSize();
            validateattributes(sz, {'numeric'}, {'vector', 'integer', 'numel',2});

            retina.setColorSaturation('SaturateColors',true);
            retina.activateMovingContoursProcessing(true);
            retina.activateContoursProcessing(true);
        end

        function test_params
            img = cv.imread(TestRetina.filename, 'Color',true, 'ReduceScale',2);
            retina = cv.Retina([size(img,2) size(img,1)]);

            fname = [tempname() '.xml'];
            cObj = onCleanup(@() TestRetina.deleteFile(fname));
            retina.write(fname);
            retina.setup(fname);

            optsParvo = {'NormaliseOutput',true, 'PhotoreceptorsTemporalConstant',0.5};
            optsMagno = {'NormaliseOutput',true, 'ParasolCellsK',7};
            retina.setupParameters('OPLandIplParvo',optsParvo, 'IplMagno',optsMagno);

            retina.setupOPLandIPLParvoChannel(optsParvo{:});
            retina.setupIPLMagnoChannel(optsMagno{:});

            str = retina.printSetup();
            validateattributes(str, {'char'}, {'row', 'nonempty'});

            params = retina.getParameters();
            validateattributes(params, {'struct'}, {'scalar'});
            validateattributes(params.OPLandIplParvo, {'struct'}, {'scalar'});
            validateattributes(params.IplMagno, {'struct'}, {'scalar'});
        end

        function test_tonemap
            hdr = cv.imread(fullfile(mexopencv.root(),'test','memorial.hdr'), 'Flags',-1);
            hdr = cv.resize(hdr, 0.5, 0.5);
            retina = cv.Retina([size(hdr,2) size(hdr,1)]);

            %sz = [size(hdr,2) size(hdr,1)];
            sz = retina.getOutputSize();

            ldr = retina.applyFastToneMapping(hdr);
            validateattributes(ldr, {'uint8'}, {'size',[sz(2) sz(1) 3]});
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
