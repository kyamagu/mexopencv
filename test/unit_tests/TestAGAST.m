classdef TestAGAST
    %TestAGAST
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            kpts = cv.AGAST(TestAGAST.img, ...
                'Threshold',10, 'NonmaxSuppression',true);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAGAST.kfields, fieldnames(kpts))));
        end

        function test_detect_types
            types = {'AGAST_5_8', 'AGAST_7_12d', 'AGAST_7_12s', 'OAST_9_16'};
            for i=1:numel(types)
                kpts = cv.AGAST(TestAGAST.img, 'Type',types{i});
                validateattributes(kpts, {'struct'}, {'vector'});
            end
        end

        function test_error_1
            try
                cv.AGAST();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
