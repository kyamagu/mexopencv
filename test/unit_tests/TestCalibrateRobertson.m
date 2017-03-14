classdef TestCalibrateRobertson
    %TestCalibrateRobertson

    methods (Static)
        function test_1
            fpath = fullfile(mexopencv.root(),'test');
            files = dir(fullfile(fpath,'memorial*.png'));
            imgs = cell(1,numel(files));
            for i=1:numel(files)
                imgs{i} = imread(fullfile(fpath,files(i).name));
            end
            etimes = 2.^(5:-1:-10);
            assert(numel(imgs) == numel(etimes));

            calibrate = cv.CalibrateRobertson();
            calibrate.MaxIter = 30;
            response = calibrate.process(imgs, etimes);
            validateattributes(response, {'single'}, ...
                {'size',[256 1 size(imgs{1},3)], 'real'});

            R = calibrate.getRadiance();
            validateattributes(R, {'single'}, {'size',size(imgs{1})});
        end
    end

end
