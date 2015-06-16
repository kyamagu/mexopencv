classdef Utils
    %UTILS  Utility and system information functions.
    %

    methods (Static)
        function s = checkHardwareSupport()
            %CHECKHARDWARESUPPORT  Returns hardware CPU features
            %
            %    s = cv.Utils.checkHardwareSupport()
            %
            % ## Output
            % * __s__ Returns a structure for each CPU feature indicating if
            %       the feature is supported by the host hardware. When
            %       `setUseOptimized=false` is called, the subsequent calls to
            %       `checkHardwareSupport` will return false until
            %       `setUseOptimized=true` is called. This way user can
            %       dynamically switch on and off the optimized code in OpenCV.
            %
            s = Utils_('checkHardwareSupport');
        end

        function info = getBuildInformation()
            %GETBUILDINFORMATION  Returns full configuration time CMake output
            %
            %    info = cv.Utils.getBuildInformation()
            %
            % ## Output
            % * __info__ Returned value is raw CMake output including version
            %       control system revision, compiler version, compiler flags,
            %       enabled modules and third party libraries, etc. Output
            %       format depends on target architecture.
            %
            info = Utils_('getBuildInformation');
        end

        function n = getNumberOfCPUs()
            %GETNUMBEROFCPUS  Return number of logical CPUs
            %
            %    n = cv.Utils.getNumberOfCPUs()
            %
            % ## Output
            % * __n__ Returns the number of logical CPUs available for the
            %       process.
            %
            n = Utils_('getNumberOfCPUs');
        end

        function n = getNumThreads()
            %GETNUMTHREADS  Returns number of threads used by OpenCV for parallel regions
            %
            %    n = cv.Utils.getNumThreads()
            %
            % ## Output
            % * __n__ number of threads.
            %
            % The exact meaning of return value depends on the threading
            % framework used by OpenCV library:
            %
            % * __TBB__ The number of threads, that OpenCV will try to use for
            %       parallel regions. If there is any
            %       `tbb::thread_scheduler_init` in user code conflicting with
            %       OpenCV, then function returns default number of threads
            %       used by TBB library.
            % * __OpenMP__ An upper bound on the number of threads that could
            %       be used to form a new team.
            % * __Concurrency__ The number of threads, that OpenCV will try to
            %       use for parallel regions.
            % * __GCD__ Unsupported; returns the GCD thread pool limit (512)
            %       for compatibility.
            % * __C=__ The number of threads, that OpenCV will try to use for
            %       parallel regions, if before called `setNumThreads` with
            %       `threads > 0`, otherwise returns the number of logical
            %       CPUs, available for the process.
            %
            % See also: cv.Utils.setNumThreads
            %
            n = Utils_('getNumThreads');
        end

        function setNumThreads(n)
            %SETNUMTHREADS  Sets number of threads used by OpenCV for parallel regions
            %
            %    cv.Utils.setNumThreads(n)
            %
            % ## Input
            % * __n__ number of threads.
            %
            % OpenCV will try to set the number of threads for the next
            % parallel region.
            %
            % OpenCV will try to run it's functions with specified threads
            % number, but some behaviour differs from framework:
            %
            % * __TBB__ User-defined parallel constructions will run with the
            %       same threads number, if another does not specified. If
            %       If late on user creates own scheduler, OpenCV will be use
            %       it.
            % * __OpenMP__ No special defined behaviour.
            % * __Concurrency__ If `threads == 1`, OpenCV will disable
            %       threading optimizations and run it's functions
            %       sequentially.
            % * __GCD__ Supports only values <= 0.
            % * __C=__ No special defined behaviour.
            %
            % See also: cv.Utils.getNumThreads
            %
            Utils_('setNumThreads', n);
        end

        function tf = useOptimized()
            %USEOPTIMIZED  Returns the status of optimized code usage
            %
            %    tf = cv.Utils.useOptimized()
            %
            % ## Output
            % * __tf__ The function returns true if the optimized code is
            %       enabled. Otherwise, it returns false.
            %
            % See also: cv.Utils.setUseOptimized
            %
            tf = Utils_('useOptimized');
        end

        function setUseOptimized(tf)
            %SETUSEOPTIMIZED  Enables or disables the optimized code
            %
            %    cv.Utils.setUseOptimized(tf)
            %
            % ## Input
            % * __tf__ true or false value.
            %
            % The function can be used to dynamically turn on and off
            % optimized code (code that uses SSE2, AVX, and other instructions
            % on the platforms that support it). It sets a global flag that is
            % further checked by OpenCV functions. Since the flag is not
            % checked in the inner OpenCV loops, it is only safe to call the
            % function on the very top level in your application where you can
            % be sure that no other OpenCV function is currently executed.
            % By default, the optimized code is enabled unless you disable it
            % in CMake. The current status can be retrieved using
            % `useOptimized`.
            %
            % See also: cv.Utils.useOptimized
            %
            Utils_('setUseOptimized', tf);
        end
    end

end
