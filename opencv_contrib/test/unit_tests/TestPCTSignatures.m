classdef TestPCTSignatures
    %TestPCTSignatures

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','books_left.jpg'));

            pct = cv.PCTSignatures();
            sig = pct.computeSignature(img);
            validateattributes(sig, {'numeric'}, {'2d', 'size',[NaN 8]});

            sigs = pct.computeSignatures({img, img});
            validateattributes(sigs, {'cell'}, {'vector', 'numel',2});

            out = cv.PCTSignatures.drawSignature(img, sig);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            initPoints = cv.PCTSignatures.generateInitPoints(2000, 'Uniform');
            pct = cv.PCTSignatures(initPoints, 400);
            pct.GrayscaleBits = 4;
            assert(isequal(pct.GrayscaleBits, 4));
        end
    end

end
