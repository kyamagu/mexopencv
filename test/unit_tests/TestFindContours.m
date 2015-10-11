classdef TestFindContours
    %TestFindContours
    properties (Constant)
        img = uint8([...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 1 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 1 1 0 0;...
            0 0 0 0 0 1 1 1 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
        ]);
    end

    methods (Static)
        function test_1
            contours = cv.findContours(TestFindContours.img);
            [contours, hierarchy] = cv.findContours(TestFindContours.img);
            assert(iscell(contours) && iscell(hierarchy));
            assert(numel(contours) == numel(hierarchy));
            if ~isempty(contours)
                assert(all(cellfun(@iscell, contours)));
                assert(all(cellfun(@(c) all(cellfun(@isvector,c)), contours)));
                assert(all(cellfun(@(c) all(cellfun(@numel,c)==2), contours)));
            end
            if ~isempty(hierarchy)
                validateattributes(hierarchy, {'cell'}, {'vector'});
                cellfun(@(h) validateattributes(h, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer', '<',numel(contours)}), ...
                    hierarchy);
            end
            contours = cellfun(@(c) cat(1,c{:}), contours, 'Uniform',false);
            hierarchy = cat(1, hierarchy{:});
        end

        function test_2
            modes = {'External', 'List', 'CComp', 'Tree'};
            approx = {'None', 'Simple', 'TC89_L1', 'TC89_KCOS'};
            for i=1:numel(modes)
                for j=1:numel(approx)
                    [c,h] = cv.findContours(TestFindContours.img, ...
                        'Mode',modes{i}, 'Method',approx{j});
                end
            end
        end

        function test_3
            labels = int32(kron([0 1; 2 3], ones(3)));
            labels = cv.copyMakeBorder(labels, [1 1 1 1], ...
                'BorderType','Constant', 'Value',0);
            [C, H] = cv.findContours(labels, 'Mode','CComp');
            [C, H] = cv.findContours(labels, 'Mode','FloodFill');
        end

        function test_error_1
            try
                cv.findContours();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
