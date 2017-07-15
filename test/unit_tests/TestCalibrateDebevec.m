classdef TestCalibrateDebevec
    %TestCalibrateDebevec

    methods (Static)
        function test_1
            N = 3; % use first N images only
            fpath = fullfile(mexopencv.root(),'test');
            files = dir(fullfile(fpath,'memorial*.png'));
            files = files(1:N);
            imgs = cell(1,numel(files));
            for i=1:numel(files)
                imgs{i} = cv.imread(fullfile(fpath,files(i).name), 'ReduceScale',2);
            end
            etimes = 2.^(5:-1:-10);
            etimes = etimes(1:N);
            assert(numel(imgs) == numel(etimes));

            calibrate = cv.CalibrateDebevec();
            calibrate.Samples = 30;
            response = calibrate.process(imgs, etimes);
            validateattributes(response, {'single'}, ...
                {'size',[256 1 size(imgs{1},3)], 'real'});
        end
    end

end
