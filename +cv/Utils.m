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
            % See also: cv.Utils.getHardwareFeatureName
            %
            s = Utils_('checkHardwareSupport');
        end

        function name = getHardwareFeatureName(feature)
            %GETHARDWAREFEATURENAME  Returns feature name by ID
            %
            %     name = cv.Utils.getHardwareFeatureName(feature)
            %
            % ## Input
            % * __feature__ feature ID (integer).
            %
            % ## Output
            % * __name__ feature name. It returns empty string if feature is
            %   not defined.
            %
            % See also: cv.Utils.checkHardwareSupport
            %
            name = Utils_('getHardwareFeatureName', feature);
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

        function platforms = getPlatfomsInfo()
            %GETPLATFOMSINFO  Get information about OpenCL devices
            %
            %     platforms = cv.Utils.getPlatfomsInfo()
            %
            % ## Output
            % * __platforms__ struct-array of information about OpenCL
            %   platforms:
            %   * __name__ Platform name string.
            %   * __vendor__ Platform vendor string.
            %   * __version__ OpenCL version string supported by the
            %     implementation.
            %   * __device__ struct-array of information about OpenCL device:
            %     * __name__ Device name string.
            %     * __extensions__ Space separated list of extension names.
            %     * __version__ OpenCL version string supported by the device.
            %     * __vendorName__ Vendor name string.
            %     * __vendorID__ Vendor ID string.
            %     * **OpenCL_C_Version** The highest OpenCL C version
            %       supported by the compiler for this device.
            %     * __OpenCLVersion__ OpenCL version string supported by the
            %       device.
            %     * __deviceVersionMajor__ OpenCL major version supported by
            %       the device.
            %     * __deviceVersionMinor__ OpenCL minor version supported by
            %       the device.
            %     * __driverVersion__ OpenCL software driver version string.
            %     * __type__ The OpenCL device type (CPU, GPU, etc.).
            %     * __addressBits__ The default compute device address space
            %       size, 32 or 64 bits.
            %     * __available__ true if the device is available and false if
            %       the device is not available.
            %     * __compilerAvailable__ Is false if the implementation does
            %       not have a compiler available to compile the program
            %       source. Is true if the compiler is available.
            %     * __linkerAvailable__ Is false if the implementation does
            %       not have a linker available. Is true if the linker is
            %       available.
            %     * __doubleFPConfig__ Describes double precision
            %       floating-point capability of the device.
            %     * __singleFPConfig__ Describes single precision
            %       floating-point capability of the device:
            %       * __Denorm__ denorms are supported.
            %       * __InfNaN__ INF and NaNs are supported.
            %       * __RoundToNearest__ round to nearest even rounding mode
            %         supported.
            %       * __RoundToZero__ round to zero rounding mode supported.
            %       * __RoundToInf__ round to positive and negative infinity
            %         rounding modes supported.
            %       * __FMA__ IEEE754-2008 fused multiply-add is supported.
            %       * __SoftFloat__ Basic floating-point operations (such as
            %         addition, subtraction, multiplication) are implemented
            %         in software.
            %       * __halfFPConfig__ Describes the optional half precision
            %         floating-point capability of the device.
            %     * __endianLittle__ Is true if the OpenCL device is a little
            %       endian device and false otherwise.
            %     * __errorCorrectionSupport__ Is true if the device
            %       implements error correction for all accesses to compute
            %       device memory (global and constant). Is false if the
            %       device does not implement such error correction.
            %     * __executionCapabilities__ Describes the execution
            %       capabilities of the device:
            %       * __Kernel__ The OpenCL device can execute OpenCL kernels.
            %       * __NativeKernel__ The OpenCL device can execute native
            %         kernels.
            %     * __globalMemCacheSize__ Size of global memory cache in
            %       bytes.
            %     * __globalMemCacheType__ Type of global memory cache
            %       supported, one of: 'NoCache', 'ReadOnlyCache',
            %       'ReadWriteCache'.
            %     * __globalMemCacheLineSize__ Size of global memory cache
            %       line in bytes.
            %     * __globalMemSize__ Size of global device memory in bytes.
            %     * __localMemSize__ Size of local memory arena in bytes.
            %     * __localMemType__ Type of local memory supported (local or
            %       global).
            %     * __hostUnifiedMemory__ Is true if the device and the host
            %       have a unified memory subsystem and is false otherwise.
            %     * __imageSupport__ Is CL_TRUE if images are supported by the
            %       OpenCL device and CL_FALSE otherwise.
            %     * __imageFromBufferSupport__ Is true if
            %       "cl_khr_image2d_from_buffer" extension is supported.
            %     * __imagePitchAlignment__ The row pitch alignment size in
            %       pixels for 2D images created from a buffer.
            %     * __imageBaseAddressAlignment__
            %     * __image2DMaxWidth__ Max width of 2D image or 1D image not
            %       created from a buffer object in pixels
            %     * __image2DMaxHeight__ Max height of 2D image in pixels.
            %     * __image3DMaxWidth__ Max width of 3D image in pixels.
            %     * __image3DMaxHeight__ Max height of 3D image in pixels.
            %     * __image3DMaxDepth__ Max depth of 3D image in pixels.
            %     * __imageMaxBufferSize__ Max number of pixels for a 1D image
            %       created from a buffer object.
            %     * __imageMaxArraySize__ Max number of images in a 1D or 2D
            %       image array.
            %     * __maxClockFrequency__ Maximum configured clock frequency
            %       of the device in MHz.
            %     * __maxComputeUnits__ The number of parallel compute units
            %       on the OpenCL device. A work-group executes on a single
            %       compute unit.
            %     * __maxConstantArgs__ Max number of arguments declared with
            %       the `__constant` qualifier in a kernel.
            %     * __maxConstantBufferSize__ Max size in bytes of a constant
            %       buffer allocation.
            %     * __maxMemAllocSize__ Max size of memory object allocation
            %       in bytes.
            %     * __maxParameterSize__ Max size in bytes of all arguments
            %       that can be passed to a kernel.
            %     * __maxReadImageArgs__ Max number of image objects arguments
            %       of a kernel declared with the `read_only` qualifier.
            %     * __maxWriteImageArgs__ Max number of image objects
            %       arguments of a kernel declared with the `write_only`
            %       qualifier.
            %     * __maxSamplers__ Maximum number of samplers that can be
            %       used in a kernel.
            %     * __maxWorkGroupSize__ Maximum number of work-items in a
            %       work-group executing a kernel on a single compute unit,
            %       using the data parallel execution model.
            %     * __maxWorkItemDims__ Maximum dimensions that specify the
            %       global and local work-item IDs used by the data parallel
            %       execution model.
            %     * __maxWorkItemSizes__ Maximum number of work-items that can
            %       be specified in each dimension of the work-group.
            %     * __memBaseAddrAlign__ The minimum value is the size
            %       (in bits) of the largest OpenCL built-in data type
            %       supported by the device.
            %     * __nativeVectorWidthChar__, __nativeVectorWidthShort__,
            %       __nativeVectorWidthInt__, __nativeVectorWidthLong__,
            %       __nativeVectorWidthFloat__, __nativeVectorWidthDouble__,
            %       __nativeVectorWidthHalf__ The native ISA vector width. The
            %       vector width is defined as the number of scalar elements
            %       that can be stored in the vector.
            %     * __preferredVectorWidthChar__, __preferredVectorWidthShort__,
            %       __preferredVectorWidthInt__, __preferredVectorWidthLong__,
            %       __preferredVectorWidthFloat__, __preferredVectorWidthDouble__,
            %       __preferredVectorWidthHalf__ Preferred native vector width
            %       size for built-in scalar types that can be put into
            %       vectors. The vector width is defined as the number of
            %       scalar elements that can be stored in the vector.
            %     * __printfBufferSize__ Maximum size in bytes of the internal
            %       buffer that holds the output of `printf` calls from a
            %       kernel.
            %     * __profilingTimerResolution__ Resolution of timer, i.e. the
            %       number of nanoseconds elapsed before the timer is
            %       incremented.
            %
            % See OpenCL
            % [docs](https://www.khronos.org/registry/OpenCL/sdk/2.0/docs/man/xhtml/clGetDeviceInfo.html).
            %
            % If OpenCV is compiled without OpenCL support, the function
            % returns an empty struct.
            %
            % See also: cv.Utils.haveOpenCL
            %
            platforms = Utils_('getPlatfomsInfo');
        end

        function dumpOpenCLInformation()
            %DUMPOPENCLINFORMATION  Dump OpenCL information
            %
            %     cv.Utils.dumpOpenCLInformation()
            %
            % See also: cv.Utils.getPlatfomsInfo
            %
            Utils_('dumpOpenCLInformation');
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

        function dinfo = deviceInfo(device)
            %DEVICEINFO  Return CUDA device info
            %
            %     dinfo = cv.Utils.deviceInfo(device)
            %
            % ## Input
            % * __device__ System index of a CUDA device starting with 0.
            %
            % ## Output
            % * __dinfo__ scalar struct of information about CUDA device:
            %   * __deviceID__ system index of the CUDA device starting with 0
            %   * __name__ ASCII string identifying device
            %   * __totalGlobalMem__ global memory available on device in bytes
            %   * __sharedMemPerBlock__ shared memory available per block in
            %     bytes
            %   * __regsPerBlock__ 32-bit registers available per block
            %   * __warpSize__ warp size in threads
            %   * __memPitch__ maximum pitch in bytes allowed by memory copies
            %   * __maxThreadsPerBlock__ maximum number of threads per block
            %   * __maxThreadsDim__ maximum size of each dimension of a block
            %   * __maxGridSize__ maximum size of each dimension of a grid
            %   * __clockRate__ clock frequency in kilohertz
            %   * __totalConstMem__ constant memory available on device in
            %     bytes
            %   * __majorVersion__ major compute capability
            %   * __minorVersion__ minor compute capability
            %   * __textureAlignment__ alignment requirement for textures
            %   * __texturePitchAlignment__ pitch alignment requirement for
            %     texture references bound to pitched memory
            %   * __multiProcessorCount__ number of multiprocessors on device
            %   * __kernelExecTimeoutEnabled__ specified whether there is a
            %     run time limit on kernels
            %   * __integrated__ device is integrated as opposed to discrete
            %   * __canMapHostMemory__ device can map host memory with
            %     `cudaHostAlloc`/`cudaHostGetDevicePointer`
            %   * __computeMode__ compute mode, one of:
            %     * __Default__ default compute mode (Multiple threads can use
            %       `cudaSetDevice` with this device)
            %     * __Exclusive__ compute-exclusive-thread mode (Only one
            %       thread in one process will be able to use `cudaSetDevice`
            %       with this device)
            %     * __Prohibited__ compute-prohibited mode (No threads can use
            %       `cudaSetDevice` with this device)
            %     * __ExclusiveProcess__ compute-exclusive-process mode (Many
            %       threads in one process will be able to use `cudaSetDevice`
            %       with this device)
            %   * __maxTexture1D__ maximum 1D texture size
            %   * __maxTexture1DMipmap__ maximum 1D mipmapped texture size
            %   * __maxTexture1DLinear__ maximum size for 1D textures bound to
            %     linear memory
            %   * __maxTexture2D__ maximum 2D texture dimensions
            %   * __maxTexture2DMipmap__ maximum 2D mipmapped texture
            %     dimensions
            %   * __maxTexture2DLinear__ maximum dimensions (width, height,
            %     pitch) for 2D textures bound to pitched memory
            %   * __maxTexture2DGather__ maximum 2D texture dimensions if
            %     texture gather operations have to be performed
            %   * __maxTexture3D__ maximum 3D texture dimensions
            %   * __maxTextureCubemap__ maximum Cubemap texture dimensions
            %   * __maxTexture1DLayered__ maximum 1D layered texture dimensions
            %   * __maxTexture2DLayered__ maximum 2D layered texture dimensions
            %   * __maxTextureCubemapLayered__ maximum Cubemap layered texture
            %     dimensions
            %   * __maxSurface1D__ maximum 1D surface size
            %   * __maxSurface2D__ maximum 2D surface dimensions
            %   * __maxSurface3D__ maximum 3D surface dimensions
            %   * __maxSurface1DLayered__ maximum 1D layered surface dimensions
            %   * __maxSurface2DLayered__ maximum 2D layered surface dimensions
            %   * __maxSurfaceCubemap__ maximum Cubemap surface dimensions
            %   * __maxSurfaceCubemapLayered__ maximum Cubemap layered surface
            %     dimensions
            %   * __surfaceAlignment__ alignment requirements for surfaces
            %   * __concurrentKernels__ device can possibly execute multiple
            %     kernels concurrently
            %   * __ECCEnabled__ device has ECC support enabled
            %   * __pciBusID__ PCI bus ID of the device
            %   * __pciDeviceID__ PCI device ID of the device
            %   * __pciDomainID__ PCI domain ID of the device
            %   * __tccDriver__ true if device is a Tesla device using TCC
            %     driver, false otherwise
            %   * __asyncEngineCount__ number of asynchronous engines
            %   * __unifiedAddressing__ device shares a unified address space
            %     with the host
            %   * __memoryClockRate__ peak memory clock frequency in kilohertz
            %   * __memoryBusWidth__ global memory bus width in bits
            %   * __l2CacheSize__ size of L2 cache in bytes
            %   * __maxThreadsPerMultiProcessor__ maximum resident threads per
            %     multiprocessor
            %   * __freeMemory__ gets free memory
            %   * __totalMemory__ gets total device memory
            %   * __supports__ Struct which provides information on CUDA
            %     feature support. Is true if the device has the specified
            %     CUDA feature. Otherwise, it is false:
            %     * __Compute10__ Compute Capability 1.0
            %     * __Compute11__ Compute Capability 1.1
            %     * __Compute12__ Compute Capability 1.2
            %     * __Compute13__ Compute Capability 1.3
            %     * __Compute20__ Compute Capability 2.0
            %     * __Compute21__ Compute Capability 2.1
            %     * __Compute30__ Compute Capability 3.0
            %     * __Compute32__ Compute Capability 3.2
            %     * __Compute35__ Compute Capability 3.5
            %     * __Compute50__ Compute Capability 5.0
            %     * __GlobalAtomics__ same as 'Compute11'
            %     * __SharedAtomics__ same as 'Compute12'
            %     * __NativeDouble__ same as 'Compute13'
            %     * __WarpShuffleFunctions__ same as 'Compute30'
            %     * __DynamicParallelism__ same as 'Compute35'
            %   * __isCompatible__ Checks the CUDA module and device
            %     compatibility. Is true if the CUDA module can be run on the
            %     specified device. Otherwise, it is false.
            %
            % See also: cv.Utils.printCudaDeviceInfo
            %
            dinfo = Utils_('deviceInfo', device);
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
