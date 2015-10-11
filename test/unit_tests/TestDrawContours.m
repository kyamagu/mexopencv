classdef TestDrawContours
    %TestDrawContours
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
            [contours, hierarchy] = cv.findContours(TestDrawContours.img);
            for i=-1:numel(contours)-1
                for j=0:5
                    for k=[-1 1]
                        im = cv.drawContours(TestDrawContours.img, contours, ...
                            'Hierarchy',hierarchy, 'ContourIdx',i, ...
                            'Thickness',k, 'LineType',8, 'MaxLevel',j);
                        validateattributes(im, {class(TestDrawContours.img)}, ...
                            {'size',size(TestDrawContours.img)});
                    end
                end
            end
        end

        function test_2
            [contours, hierarchy] = cv.findContours(TestDrawContours.img);
            contours = cellfun(@(c) cat(1,c{:}), contours, 'Uniform',false);
            hierarchy = cat(1, hierarchy{:});
            img = repmat(TestDrawContours.img, [1 1 3]);
            im = cv.drawContours(img, contours, ...
                'Hierarchy',hierarchy, 'ContourIdx',0, ...
                'Thickness','Filled', 'LineType',8, 'MaxLevel',0);
            validateattributes(im, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.drawContours();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
