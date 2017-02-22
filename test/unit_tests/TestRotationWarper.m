classdef TestRotationWarper
    %TestRotationWarper

    methods (Static)
        function test_1
            K = eye(3);
            R = eye(3);
            src = cv.imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            src_size = size(src);
            dst_size = [100 100];
            pt = [50 50];

            warperTypes = {'PlaneWarper', 'AffineWarper', 'CylindricalWarper', ...
                'SphericalWarper', 'FisheyeWarper', 'StereographicWarper', ...
                'CompressedRectilinearWarper', ...
                'CompressedRectilinearPortraitWarper', 'PaniniWarper', ...
                'PaniniPortraitWarper', 'MercatorWarper', 'TransverseMercatorWarper'};
            for i=1:numel(warperTypes)
                obj = cv.RotationWarper(warperTypes{i}, 1.0);
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                uv = obj.warpPoint(pt, K, R);
                validateattributes(uv, {'numeric'}, {'vector', 'numel',2});

                [dst,tl] = obj.warp(src, K, R);
                validateattributes(dst, {class(src)}, {});
                validateattributes(tl, {'numeric'}, {'vector', 'numel',2});

                [xmap,ymap,bbox] = obj.buildMaps(src_size, K, R);
                validateattributes(xmap, {'single'}, {});
                validateattributes(ymap, {'single'}, {});
                validateattributes(bbox, {'numeric'}, {'vector', 'numel',4});

                bbox = obj.warpRoi(src_size, K, R);
                validateattributes(bbox, {'numeric'}, {'vector', 'numel',4});
            end
        end
    end

end
