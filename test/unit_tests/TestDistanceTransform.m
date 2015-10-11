classdef TestDistanceTransform
    %TestDistanceTransform

    methods (Static)
        function test_correctness
            img = uint8([...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 1 1 1 0 0 0 0;...
                0 0 0 1 1 1 0 0 0 0;...
                0 0 0 1 1 1 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
            ]);
            rslt = single([...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 1 1 1 0 0 0 0;...
                0 0 0 1 2 1 0 0 0 0;...
                0 0 0 1 1 1 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
                0 0 0 0 0 0 0 0 0 0;...
            ]);
            result = cv.distanceTransform(img, ...
                'DistanceType','L1', 'MaskSize',3, 'DstType','single');
            assert(isequal(rslt,result));
        end

        function test_distance_types
            img = cv.getStructuringElement('Shape','Ellipse', 'KSize',[10 10]);

            result = cv.distanceTransform(img, 'DistanceType','L2');
            validateattributes(result, {'single'}, {'size',size(img), 'real', 'nonnegative'});

            result = cv.distanceTransform(img, 'DistanceType','L1');
            validateattributes(result, {'single'}, {'size',size(img), 'integer', 'nonnegative'});

            result = cv.distanceTransform(img, 'DistanceType','C');
            validateattributes(result, {'single'}, {'size',size(img), 'integer', 'nonnegative'});
        end

        function test_label_types
            img = cv.getStructuringElement('Shape','Ellipse', 'KSize',[10 10]);

            [result,labels] = cv.distanceTransform(img, 'LabelType','CComp');
            validateattributes(labels, {'int32'}, {'size',size(img), 'nonnegative'});

            [result,labels] = cv.distanceTransform(img, 'LabelType','Pixel');
            validateattributes(labels, {'int32'}, {'size',size(img), 'nonnegative'});
        end

        function test_options1
            img = uint8(rand(10)>0.7);
            distType = {'L1', 'L2', 'C'};
            maskSizes = {3, '5', 'Precise'};
            for i=1:numel(distType)
                for j=1:numel(maskSizes)
                    result = cv.distanceTransform(img, ...
                        'DistanceType',distType{i}, 'MaskSize',maskSizes{j});
                end
            end
        end

        function test_options2
            img = uint8(rand(10)>0.7);
            distType = {'L1', 'L2', 'C'};
            maskSizes = {3, '5', 'Precise'};
            labelTypes = {'CComp', 'Pixel'};
            for i=1:numel(distType)
                for j=1:numel(maskSizes)
                    for k=1:numel(labelTypes)
                        [result,labels] = cv.distanceTransform(img, ...
                            'DistanceType',distType{i}, 'MaskSize',maskSizes{j}, ...
                            'LabelType',labelTypes{k});
                    end
                end
            end
        end

        function test_error_1
            try
                cv.distanceTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
