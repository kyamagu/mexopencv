classdef TestMergeDebevec
    %TestMergeDebevec

    methods (Static)
        function test_1
            fpath = fullfile(mexopencv.root(),'test');
            files = dir(fullfile(fpath,'memorial*.png'));
            imgs = cell(1,numel(files));
            for i=1:numel(files)
                imgs{i} = imread(fullfile(fpath,files(i).name));
            end
            times = 2.^(5:-1:-10);
            assert(numel(imgs) == numel(times));

            obj = cv.MergeDebevec();
            hdr = obj.process(imgs, times);
            validateattributes(hdr, {'single'}, ...
                {'size',size(imgs{1}), 'nonnegative'});

            calibrate = cv.CalibrateDebevec();
            response = calibrate.process(imgs, times);
            hdr = obj.process(imgs, times, response);
            validateattributes(hdr, {'single'}, ...
                {'size',size(imgs{1}), 'nonnegative'});
        end
    end
end
