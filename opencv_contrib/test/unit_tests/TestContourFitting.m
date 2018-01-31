classdef TestContourFitting
    %TestContourFitting

    methods (Static)
        function test_contourSampling
            c = get_contour();

            % cell array
            c2 = cv.ContourFitting.contourSampling(c, 100);
            validateattributes(c2, {'cell'}, {'numel',100});

            % Nx2
            c = cat(1, c{:});
            c2 = cv.ContourFitting.contourSampling(c, 100);
            validateattributes(c2, {'numeric'}, {'size',[100 2]});

            % Nx1x2
            c = permute(c, [1 3 2]);
            c2 = cv.ContourFitting.contourSampling(c, 100);
            validateattributes(c2, {'numeric'}, {'size',[100 1 2]});
        end

        function test_fourierDescriptor
            c = get_contour();

            % cell array
            fd = cv.ContourFitting.fourierDescriptor(c, 'NumFD',30);
            validateattributes(fd, {'numeric'}, {});
            assert(length(fd)==30 && size(fd,3)==2);

            % Nx2
            c = cat(1, c{:});
            fd = cv.ContourFitting.fourierDescriptor(c, 'NumFD',30);
            validateattributes(fd, {'numeric'}, {});
            assert(length(fd)==30 && size(fd,3)==2);

            % Nx1x2
            c = permute(c, [1 3 2]);
            fd = cv.ContourFitting.fourierDescriptor(c, 'NumFD',30);
            validateattributes(fd, {'numeric'}, {});
            assert(length(fd)==30 && size(fd,3)==2);
        end

        function test_transformFD
            c = get_contour();
            t = [0 pi/2 1 10 20];  % [alpha, phi, s, Tx, Ty]

            % cell array
            c2 = cv.ContourFitting.transformFD(c, t, 'FD',false);
            validateattributes(c2, {'cell'}, {'nonempty'});

            % Nx2
            c = cat(1, c{:});
            c2 = cv.ContourFitting.transformFD(c, t, 'FD',false);
            validateattributes(c2, {'cell'}, {'nonempty'});

            % Nx1x2
            c = permute(c, [1 3 2]);
            c2 = cv.ContourFitting.transformFD(c, t, 'FD',false);
            validateattributes(c2, {'cell'}, {'nonempty'});
        end

        function test_transformFD_2
            c = get_contour();
            t = [0 pi/2 1 10 20];  % [alpha, phi, s, Tx, Ty]

            n = cv.getOptimalDFTSize(numel(c));
            cc = cv.ContourFitting.contourSampling(c, n);
            fd = cv.ContourFitting.fourierDescriptor(cc);

            fd2 = cv.ContourFitting.transformFD(fd, t, 'FD',true);
            validateattributes(fd2, {'numeric'}, {'nonempty'});
            assert(length(fd2)==length(fd) && size(fd2,3)==2);
        end

        function test_estimateTransformation
            c1 = get_contour();
            c2 = cellfun(@(pt) pt+[10 20], c1, 'UniformOutput',false);

            obj = cv.ContourFitting();
            [t, d] = obj.estimateTransformation(c1, c2, 'FD',false);
            validateattributes(t, {'double'}, {'vector', 'numel',5});
            validateattributes(d, {'numeric'}, {'scalar', 'nonnegative'});
        end

        function test_estimateTransformation_2
            c1 = get_contour();
            c2 = cellfun(@(pt) pt+[10 20], c1, 'UniformOutput',false);

            n = cv.getOptimalDFTSize(numel(c1));
            cc1 = cv.ContourFitting.contourSampling(c1, n);
            cc2 = cv.ContourFitting.contourSampling(c2, n);
            fd1 = cv.ContourFitting.fourierDescriptor(cc1);
            fd2 = cv.ContourFitting.fourierDescriptor(cc2);
            fd1 = reshape(fd1, [], 1, 2);
            fd2 = reshape(fd2, [], 1, 2);

            obj = cv.ContourFitting();
            [t, d] = obj.estimateTransformation(fd1, fd2, 'FD',true);
            validateattributes(t, {'double'}, {'vector', 'numel',5});
            validateattributes(d, {'numeric'}, {'scalar', 'nonnegative'});
        end
    end

end

function [c, img] = get_contour()
    im = fullfile(mexopencv.root(),'test','shape06.png');
    img = cv.imread(im, 'Grayscale',true);
    c = cv.findContours(img, 'Mode','List', 'Method','None');
    [~,idx] = max(cellfun(@numel,c));
    c = c{idx};
end
