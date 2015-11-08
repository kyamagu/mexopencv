classdef TestBuildOpticalFlowPyramid
    %TestBuildOpticalFlowPyramid
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            im = cv.imread(TestBuildOpticalFlowPyramid.img, 'Grayscale',true);
            [pyramid,mxLvl] = cv.buildOpticalFlowPyramid(im, ...
                'WithDerivatives',true, 'MaxLevel',3);
            validateattributes(mxLvl, {'numeric'}, ...
                {'integer', 'nonnegative', 'scalar', '<=',3});
            validateattributes(pyramid, {'cell'}, {'vector', 'numel',(3+1)*2});
            cellfun(@(pyr) validateattributes(pyr, {class(im)}, ...
                {'2d'}), pyramid(1:2:end));
            cellfun(@(deriv) validateattributes(deriv, {'int16'}, ...
                {'3d', 'size',[NaN NaN 2]}), pyramid(2:2:end));
            [sz1,sz2,~] = cellfun(@size, pyramid);
            arrayfun(@(i) assert(isequal(sz1(i),sz1(i+1))), 1:2:numel(sz1));
            arrayfun(@(i) assert(isequal(sz2(i),sz2(i+1))), 1:2:numel(sz2));
        end

        function test_2
            im = cv.imread(TestBuildOpticalFlowPyramid.img, 'Grayscale',true);
            [pyramid,mxLvl] = cv.buildOpticalFlowPyramid(im, ...
                'WithDerivatives',false, 'MaxLevel',3);
            validateattributes(mxLvl, {'numeric'}, ...
                {'integer', 'nonnegative', 'scalar', '<=',3});
            validateattributes(pyramid, {'cell'}, {'vector', 'numel',(3+1)});
            cellfun(@(pyr) validateattributes(pyr, {class(im)}, ...
                {'2d'}), pyramid);
        end

        function test_error_1
            try
                cv.buildOpticalFlowPyramid();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
