classdef TestPCTSignaturesSQFD
    %TestPCTSignaturesSQFD

    methods (Static)
        function test_1
            img1 = imread(fullfile(mexopencv.root(),'test','books_left.jpg'));
            img2 = imread(fullfile(mexopencv.root(),'test','books_right.jpg'));

            pct = cv.PCTSignatures();
            sig1 = pct.computeSignature(img1);
            sig2 = pct.computeSignature(img2);

            sqfd = cv.PCTSignaturesSQFD();
            d = sqfd.computeQuadraticFormDistance(sig1, sig2);
            validateattributes(d, {'numeric'}, {'scalar'});
            d = sqfd.computeQuadraticFormDistances(sig1, {sig2, sig2});
            validateattributes(d, {'numeric'}, {'vector', 'numel',2});
        end
    end

end
