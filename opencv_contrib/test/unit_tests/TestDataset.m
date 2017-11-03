classdef TestDataset
    %TestDataset

    methods (Static)
        function test_1
            klass = {'AR_hmdb', 'AR_sports', 'FR_adience', 'FR_lfw', ...
                'GR_chalearn', 'GR_skig', 'HPE_humaneva', 'HPE_parse', ...
                'IR_affine', 'IR_robot', 'IS_bsds', 'IS_weizmann', ...
                'MSM_epfl', 'MSM_middlebury', 'OR_imagenet', 'OR_mnist', ...
                'OR_pascal', 'OR_sun', 'PD_caltech', 'PD_inria', ...
                'SLAM_kitti', 'SLAM_tumindoor', 'TR_chars', 'TR_icdar', ...
                'TR_svt', 'TRACK_vot', 'TRACK_alov'};
            for i=1:numel(klass)
                ds = cv.Dataset(klass{i});
                tname = ds.typeid();
                validateattributes(tname, {'char'}, {'row', 'nonempty'});
            end
        end

        function test_mnist
            %TODO: sometimes segfaults, most likely an opencv bug
            if true
                error('mexopencv:testskip', 'todo');
            end

            % see: dataset_mnist_demo.m
            dirMNIST = fullfile(mexopencv.root(), 'test', 'mnist', filesep());
            if ~isdir(dirMNIST)
                error('mexopencv:testskip', 'missing data');
            end

            ds = cv.Dataset('OR_mnist');
            ds.load(dirMNIST);

            num = ds.getNumSplits();
            validateattributes(num, {'numeric'}, {'scalar', 'integer'});

            data = ds.getValidation();
            validateattributes(data, {'struct'}, {'vector'});

            data = ds.getTrain();
            validateattributes(data, {'struct'}, {'vector'});

            data = ds.getTest();
            validateattributes(data, {'struct'}, {'vector'});

            if ~isempty(data)
                validateattributes(data(1).image, {'uint8'}, {'size',[28 28]});
                assert(all(ismember(unique([data.label]), 0:9)));
            end
        end
    end

end
