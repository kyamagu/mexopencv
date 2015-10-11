classdef TestGroupRectangles
    %TestGroupRectangles

    methods (Static)
        function test_cell
            rcts = {[ 0, 1,10,10], ...
                    [ 1, 1,11,11], ...
                    [10,10,20,20], ...
                    [12,12,21,21], ...
                    [30,40,10,20]};
            rslts = cv.groupRectangles(rcts);
            if ~isempty(rslts)
                validateattributes(rslts, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), rslts);
            end
        end

        function test_numeric
            rcts = [ 0  1 10 10 ; ...
                     1  1 11 11 ; ...
                    10 10 20 20 ; ...
                    12 12 21 21 ; ...
                    30 40 10 20];
            rslts = cv.groupRectangles(rcts, 'Thresh',1, 'EPS',0.2);
            if ~isempty(rslts)
                validateattributes(rslts, {'numeric'}, ...
                    {'integer', 'size',[NaN 4]});
            end
        end

        function test_error_1
            try
                cv.groupRectangles();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
