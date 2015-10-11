classdef TestWriteOpticalFlow
    %TestWriteOpticalFlow

    methods (Static)
        function test_1
            filename = [tempname '.flo'];
            cObj = onCleanup(@() TestWriteOpticalFlow.deleteFile(filename));
            flow = rand([100 100 2], 'single');
            success = cv.writeOpticalFlow(filename, flow);
            assert(success && exist(filename,'file')==2, 'Failed to write flow');
        end

        function test_error_1
            try
                cv.writeOpticalFlow();
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
