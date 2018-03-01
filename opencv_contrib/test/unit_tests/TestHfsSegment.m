classdef TestHfsSegment
    %TestHfsSegment

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','fruits.jpg'), ...
                'Color',true, 'ReduceScale',2);
            sz = size(img);
            hfs = cv.HfsSegment(sz(1), sz(2));

            res = hfs.performSegment(img, 'Draw',true);
            validateattributes(res, {class(img)}, {'size',sz});

            seg = hfs.performSegment(img, 'Draw',false);
            validateattributes(seg, {'uint16'}, {'size',sz(1:2)});
        end
    end

end
