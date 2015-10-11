classdef TestFindCirclesGrid
    %TestFindCirclesGrid

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','acircles_pattern.png'));
            img = cv.resize(img, 0.5, 0.5);
            sz = [4 11];
            [centers,found] = cv.findCirclesGrid(img, sz, 'SymmetricGrid',false);
            validateattributes(centers, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'real'}), centers);
            validateattributes(found, {'logical'}, {'scalar'});
            if found
                assert(numel(centers) == prod(sz));
            end
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','acircles_pattern.png'));
            sz = [4 11];
            [centers,found] = cv.findCirclesGrid(img, sz, 'SymmetricGrid',false, ...
                'BlobDetector',{'SimpleBlobDetector', 'MaxArea',100000});
            validateattributes(centers, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'real'}), centers);
            validateattributes(found, {'logical'}, {'scalar'});
            if found
                assert(numel(centers) == prod(sz));
            end
        end

        function test_error_1
            try
                cv.findCirclesGrid();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
