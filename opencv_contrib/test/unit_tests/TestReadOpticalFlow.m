classdef TestReadOpticalFlow
    %TestReadOpticalFlow

    methods (Static)
        function test_1
            filename = [tempname '.flo'];
            cObj = onCleanup(@() TestReadOpticalFlow.deleteFile(filename));
            flow = rand([100 100 2], 'single');
            success = cv.writeOpticalFlow(filename, flow);
            if success
                flow2 = cv.readOpticalFlow(filename);
                validateattributes(flow2, {'single'}, {'3d', 'size',size(flow)});
                assert(max(abs(flow(:) - flow2(:))) < 1e-6);
            end
        end

        function test_error_1
            try
                cv.readOpticalFlow();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

    %% helper functions
    methods (Static)
        function deleteFile(fname)
            if exist(fname, 'file') == 2
                delete(fname);
            end
        end
    end

end
