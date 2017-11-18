classdef Utils
    %UTILS  Utility and system information functions
    %
    % See also: maxNumCompThreads, feature, ippl
    %

    methods (Static)
        function s = checkHardwareSupport()
            %CHECKHARDWARESUPPORT  Returns hardware CPU features
            %
            %     s = cv.Utils.checkHardwareSupport()
            %
            % ## Output
            % * __s__ Returns a structure for each CPU feature indicating if
            %   the feature is supported by the host hardware. When
            %   `setUseOptimized=false` is called, the subsequent calls to
            %   `checkHardwareSupport` will return false until
            %   `setUseOptimized=true` is called. This way user can
            %   dynamically switch on and off the optimized code in OpenCV.
            %
            s = Utils_('checkHardwareSupport');
        end

        function info = getBuildInformation()
            %GETBUILDINFORMATION  Returns full configuration time CMake output
            %
            %     info = cv.Utils.getBuildInformation()
            %
            % ## Output
            % * __info__ Returned value is raw CMake output including version
            %   control system revision, compiler version, compiler flags,
            %   enabled modules and third party libraries, etc. Output format
            %   depends on target architecture.
            %
            % See also: cv.Utils.version
            %
            info = Utils_('getBuildInformation');
        end

        function v = version()
            %VERSION  Returns OpenCV version
            %
            %     v = cv.Utils.version()
            %
            % ## Output
            % * __v__ current version of OpenCV, in the form
            %   'major.minor.revision'.
            %
            % See also: cv.Utils.getBuildInformation
            %
            v = Utils_('version');
        end

        function n = getNumberOfCPUs()
            %GETNUMBEROFCPUS  Return number of logical CPUs
            %
            %     n = cv.Utils.getNumberOfCPUs()
            %
            % ## Output
            % * __n__ Returns the number of logical CPUs available for the
            %   process.
            %
            n = Utils_('getNumberOfCPUs');
        end

        function n = getNumThreads()
            %GETNUMTHREADS  Returns number of threads used by OpenCV for parallel regions
            %
            %     n = cv.Utils.getNumThreads()
            %
            % ## Output
            % * __n__ number of threads.
            %
            % The exact meaning of the return value depends on the threading
            % framework used by OpenCV library:
            %
            % * __TBB__ The number of threads, that OpenCV will try to use for
            %   parallel regions. If there is any `tbb::thread_scheduler_init`
            %   in user code conflicting with OpenCV, then function returns
            %   default number of threads used by TBB library.
            % * __OpenMP__ An upper bound on the number of threads that could
            %   be used to form a new team.
            % * __Concurrency__ The number of threads, that OpenCV will try to
            %   use for parallel regions.
            % * __GCD__ Unsupported; returns the GCD thread pool limit (512)
            %   for compatibility.
            % * __C=__ The number of threads, that OpenCV will try to use for
            %   parallel regions, if before called `setNumThreads` with
            %   `threads > 0`, otherwise returns the number of logical CPUs,
            %   available for the process.
            %
            % See also: cv.Utils.setNumThreads
            %
            n = Utils_('getNumThreads');
        end

        function setNumThreads(n)
            %SETNUMTHREADS  Sets number of threads used by OpenCV for parallel regions
            %
            %     cv.Utils.setNumThreads(n)
            %
            % ## Input
            % * __n__ number of threads.
            %
            % OpenCV will try to set the number of threads for the next
            % parallel region.
            %
            % OpenCV will try to run its functions with specified threads
            % number, but some behaviour differs from framework:
            %
            % * __TBB__ User-defined parallel constructions will run with the
            %   same threads number, if another is not specified. If later
            %   on user creates their own scheduler, OpenCV will use it.
            % * __OpenMP__ No special defined behaviour.
            % * __Concurrency__ If `threads == 1`, OpenCV will disable
            %   threading optimizations and run its functions sequentially.
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
            %     tf = cv.Utils.useOptimized()
            %
            % ## Output
            % * __tf__ The function returns true if the optimized code is
            %   enabled. Otherwise, it returns false.
            %
            % See also: cv.Utils.setUseOptimized
            %
            tf = Utils_('useOptimized');
        end

        function setUseOptimized(tf)
            %SETUSEOPTIMIZED  Enables or disables the optimized code
            %
            %     cv.Utils.setUseOptimized(tf)
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
            % be sure that no other OpenCV function is currently executed. By
            % default, the optimized code is enabled unless you disable it in
            % CMake. The current status can be retrieved using `useOptimized`.
            %
            % See also: cv.Utils.useOptimized
            %
            Utils_('setUseOptimized', tf);
        end
    end

    % IPP
    methods (Static)
        function str = getIppVersion()
            %GETIPPVERSION  Return IPP version string
            %
            %     str = cv.Utils.getIppVersion()
            %
            % ## Output
            % * __str__ version string. Returns 'disabled' if OpenCV is
            %   compiled without IPP support.
            %
            % See also: cv.Utils.useIPP
            %
            str = Utils_('getIppVersion');
        end

        function tf = useIPP()
            %USEIPP  Check if use of IPP is enabled
            %
            %     tf = cv.Utils.useIPP()
            %
            % ## Output
            % * __tf__ status flag
            %
            % Intel Integrated Performance Primitives Library.
            %
            % See also: cv.Utils.setUseIPP
            %
            tf = Utils_('useIPP');
        end

        function setUseIPP(tf)
            %SETUSEIPP  Enable/disable use of IPP
            %
            %     cv.Utils.setUseIPP(tf)
            %
            % ## Input
            % * __tf__ flag
            %
            % See also: cv.Utils.useIPP
            %
            Utils_('setUseIPP', tf);
        end

        function tf = useIPP_NE()
            %USEIPP_NE  Check if use of IPP_NE is enabled
            %
            %     tf = cv.Utils.useIPP_NE()
            %
            % ## Output
            % * __tf__ status flag
            %
            % Intel IPP Not-Exact mode.
            %
            % See also: cv.Utils.setUseIPP_NE
            %
            tf = Utils_('useIPP_NE');
        end

        function setUseIPP_NE(tf)
            %SETUSEIPP_NE  Enable/disable use of IPP_NE
            %
            %     cv.Utils.setUseIPP_NE(tf)
            %
            % ## Input
            % * __tf__ flag
            %
            % IPP Not-Exact mode. This function may force use of IPP then both
            % IPP and OpenCV provide proper results but have internal accuracy
            % differences which have to much direct or indirect impact on
            % accuracy tests.
            %
            % See also: cv.Utils.useIPP_NE
            %
            Utils_('setUseIPP_NE', tf);
        end
    end

    % OpenVX
    methods (Static)
        function tf = haveOpenVX()
            %HAVEOPENVX  Check if use of OpenVX is possible
            %
            %     tf = cv.Utils.haveOpenVX()
            %
            % ## Output
            % * __tf__ status flag
            %
            % See also: cv.Utils.useOpenVX
            %
            tf = Utils_('haveOpenVX');
        end

        function tf = useOpenVX()
            %USEOPENVX  Check if use of OpenVX is enabled
            %
            %     tf = cv.Utils.useOpenVX()
            %
            % ## Output
            % * __tf__ status flag
            %
            % See also: cv.Utils.setUseOpenVX
            %
            tf = Utils_('useOpenVX');
        end

        function setUseOpenVX(tf)
            %SETUSEOPENVX  Enable/disable use of OpenVX
            %
            %     cv.Utils.setUseOpenVX(tf)
            %
            % ## Input
            % * __tf__ flag
            %
            % See also: cv.Utils.useOpenVX
            %
            Utils_('setUseOpenVX', tf);
        end
    end

    % OpenCL
    methods (Static)
        function tf = haveOpenCL()
            %HAVEOPENCL  Check if use of OpenCL is possible
            %
            %     tf = cv.Utils.haveOpenCL()
            %
            % ## Output
            % * __tf__ status flag
            %
            % See also: cv.Utils.useOpenCL
            %
            tf = Utils_('haveOpenCL');
        end

        function tf = haveAmdBlas()
            %HAVEAMDBLAS  Check if have clAmdBlas
            %
            %     tf = cv.Utils.haveAmdBlas()
            %
            % ## Output
            % * __tf__ status flag
            %
            % AMD's OpenCL Basic Linear Algebra Subprograms Library.
            %
            % See also: cv.Utils.haveAmdFft
            %
            tf = Utils_('haveAmdBlas');
        end

        function tf = haveAmdFft()
            %HAVEAMDFFT  Check if have clAmdFft
            %
            %     tf = cv.Utils.haveAmdFft()
            %
            % ## Output
            % * __tf__ status flag
            %
            % AMD's OpenCL Fast Fourier Transform Library.
            %
            % See also: cv.Utils.haveAmdBlas
            %
            tf = Utils_('haveAmdFft');
        end

        function tf = haveSVM()
            %HAVESVM  Check if have OpenCL Shared Virtual Memory (SVM)
            %
            %     tf = cv.Utils.haveSVM()
            %
            % ## Output
            % * __tf__ status flag
            %
            % See also: cv.Utils.haveOpenCL
            %
            tf = Utils_('haveSVM');
        end

        function tf = useOpenCL()
            %USEOPENCL  Check if use of OpenCL is enabled
            %
            %     tf = cv.Utils.useOpenCL()
            %
            % ## Output
            % * __tf__ status flag
            %
            % See also: cv.Utils.setUseOpenCL
            %
            tf = Utils_('useOpenCL');
        end

        function setUseOpenCL(tf)
            %SETUSEOPENCL  Enable/disable use of OpenCL
            %
            %     cv.Utils.setUseOpenCL(tf)
            %
            % ## Input
            % * __tf__ flag
            %
            % See also: cv.Utils.useOpenCL
            %
            Utils_('setUseOpenCL', tf);
        end
    end

    % CUDA
    methods (Static)
        function num = getCudaEnabledDeviceCount()
            %GETCUDAENABLEDDEVICECOUNT  Returns the number of installed CUDA-enabled devices
            %
            %     num = cv.Utils.getCudaEnabledDeviceCount()
            %
            % ## Output
            % * __num__ number of installed CUDA devices.
            %
            % Use this function before any other CUDA functions calls.
            % If OpenCV is compiled without CUDA support, this function
            % returns 0. If the CUDA driver is not installed, or is
            % incompatible, this function returns -1.
            %
            % Other CUDA functions will throw if no CUDA support.
            %
            % See also: cv.Utils.getDevice, cv.Utils.setDevice
            %
            num = Utils_('getCudaEnabledDeviceCount');
        end

        function device = getDevice()
            %GETDEVICE  Returns the current device index.
            %
            %     device = cv.Utils.getDevice()
            %
            % ## Output
            % * __device__ System index of current CUDA device.
            %
            % Returns the current device index set by cv.Utils.setDevice or
            % initialized by default.
            %
            % See also: cv.Utils.setDevice
            %
            device = Utils_('getDevice');
        end

        function setDevice(device)
            %SETDEVICE  Sets a device and initializes it for the current thread
            %
            %     cv.Utils.setDevice(device)
            %
            % ## Input
            % * __device__ System index of a CUDA device starting with 0.
            %
            % If the call of this function is omitted, a default device is
            % initialized at the fist CUDA usage.
            %
            % See also: cv.Utils.getDevice
            %
            Utils_('setDevice', device);
        end

        function resetDevice()
            %RESETDEVICE  Explicitly destroys and cleans up all resources associated with the current device in the current process
            %
            %     cv.Utils.resetDevice()
            %
            % Any subsequent API call to this device will reinitialize the
            % device.
            %
            % See also: cv.Utils.setDevice
            %
            Utils_('resetDevice');
        end

        function s = deviceSupports()
            %DEVICESUPPORTS  checks features support of the current device
            %
            %     s = cv.Utils.deviceSupports()
            %
            % ## Output
            % * __s__ Returns a structure for each CUDA computing feature
            %   indicating if the feature is supported by the CUDA device.
            %
            % See also: cv.Utils.setDevice
            %
            s = Utils_('deviceSupports');
        end

        function printCudaDeviceInfo(device)
            %PRINTCUDADEVICEINFO  Print CUDA device info
            %
            %     cv.Utils.printCudaDeviceInfo(device)
            %
            % ## Input
            % * __device__ System index of a CUDA device starting with 0.
            %
            % See also: cv.Utils.printShortCudaDeviceInfo
            %
            Utils_('printCudaDeviceInfo', device);
        end

        function printShortCudaDeviceInfo(device)
            %PRINTSHORTCUDADEVICEINFO  Print short CUDA device info
            %
            %     cv.Utils.printShortCudaDeviceInfo(device)
            %
            % ## Input
            % * __device__ System index of a CUDA device starting with 0.
            %
            % See also: cv.Utils.setDevice
            %
            Utils_('printCudaDeviceInfo', device);
        end
    end

    % Tegra
    methods (Static)
        function tf = useTegra()
            %USETEGRA  Check if use of Tegra is enabled
            %
            %     tf = cv.Utils.useTegra()
            %
            % ## Output
            % * __tf__ status flag
            %
            % Nvidia's Tegra system on a chip (SoC).
            %
            % See also: cv.Utils.setUseTegra
            %
            tf = Utils_('useTegra');
        end

        function setUseTegra(tf)
            %SETUSETEGRA  Enable/disable use of Tegra
            %
            %     cv.Utils.setUseTegra(tf)
            %
            % ## Input
            % * __tf__ flag
            %
            % See also: cv.Utils.useTegra
            %
            Utils_('setUseTegra', tf);
        end
    end

end
