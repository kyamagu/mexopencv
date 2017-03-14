classdef TestHoughPoint2Line
    %TestHoughPoint2Line

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','building.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            edges = cv.Canny(img, [50 200]);
            fht = cv.FastHoughTransform(edges, 'DDepth','int32', ...
                'AngleRange','ARO_315_135', 'Op','Addition');
            sz = size(fht);
            pts = [1 1; 1 sz(2); sz(1) 1; sz; round(sz./2)];
            for i=1:size(pts,1)
                lineSeg = cv.HoughPoint2Line(pts(i,:)-1, edges, ...
                    'AngleRange','ARO_315_135');
                validateattributes(lineSeg, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4});
            end
        end

        function test_error_argnum
            try
                cv.HoughPoint2Line();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
