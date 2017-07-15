classdef TestMergeDebevec
    %TestMergeDebevec

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

            obj = cv.MergeDebevec();
            hdr = obj.process(imgs, etimes);
            validateattributes(hdr, {'single'}, ...
                {'size',size(imgs{1}), 'nonnegative'});

            calibrate = cv.CalibrateDebevec();
            response = calibrate.process(imgs, etimes);
            hdr = obj.process(imgs, etimes, response);
            validateattributes(hdr, {'single'}, ...
                {'size',size(imgs{1}), 'nonnegative'});
        end
    end

end
