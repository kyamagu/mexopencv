classdef TestGroupRectanglesMeanShift
    %TestGroupRectanglesMeanShift

    methods (Static)
        function test_cell
            rcts = {[ 0, 1,10,10], ...
                    [ 1, 1,11,11], ...
                    [10,10,20,20], ...
                    [12,12,21,21], ...
                    [30,40,10,20]};
            weights = ones(size(rcts));
            scales = ones(size(rcts));
            [rslts,w] = cv.groupRectangles_meanshift(rcts, weights, scales);
            if ~isempty(rslts)
                validateattributes(rslts, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), rslts);
                validateattributes(w, {'numeric'}, ...
                    {'vector', 'numel',numel(rslts)});
            end
        end

        function test_error_1
            try
                cv.groupRectangles_meanshift();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
