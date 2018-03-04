classdef TestUtils
    %TestUtils

    methods (Static)
        function test_version
            info = cv.Utils.getBuildInformation();
            validateattributes(info, {'char'}, {'nonempty'});

            v = cv.Utils.version();
            validateattributes(v, {'char'}, {'row', 'nonempty'});
        end

        function test_cpu
            s = cv.Utils.checkHardwareSupport();
            validateattributes(s, {'struct'}, {'scalar'});

            name = cv.Utils.getHardwareFeatureName(int32(1));
            validateattributes(name, {'char'}, {'row', 'nonempty'});
        end

        function test_num_cpu
            n = cv.Utils.getNumberOfCPUs();
            validateattributes(n, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
        end

        function test_num_threads
            n = cv.Utils.getNumThreads();
            validateattributes(n, {'numeric'}, {'scalar', 'integer'});
            cv.Utils.setNumThreads(n);
        end

        function test_optimization
            b = cv.Utils.useOptimized();
            validateattributes(b, {'logical'}, {'scalar'});
            cv.Utils.setUseOptimized(b);
        end

        function test_ipp
            str = cv.Utils.getIppVersion();
            validateattributes(str, {'char'}, {'row', 'nonempty'});

            if ~strcmpi(str, 'disabled')
                b = cv.Utils.useIPP();
                validateattributes(b, {'logical'}, {'scalar'});
                cv.Utils.setUseIPP(b);
            end
        end

        function test_ovx
            b = cv.Utils.haveOpenVX();
            validateattributes(b, {'logical'}, {'scalar'});

            if b
                b = cv.Utils.useOpenVX();
                validateattributes(b, {'logical'}, {'scalar'});
                cv.Utils.setUseOpenVX(b);
            end
        end

        function test_ocl_1
            b = cv.Utils.haveOpenCL();
            validateattributes(b, {'logical'}, {'scalar'});

            b = cv.Utils.haveAmdBlas();
            validateattributes(b, {'logical'}, {'scalar'});

            b = cv.Utils.haveAmdFft();
            validateattributes(b, {'logical'}, {'scalar'});

            b = cv.Utils.haveSVM();
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_ocl_2
            if cv.Utils.haveOpenCL()
                b = cv.Utils.useOpenCL();
                validateattributes(b, {'logical'}, {'scalar'});
                cv.Utils.setUseOpenCL(b);
            end
        end

        function test_ocl_3
            if cv.Utils.haveOpenCL()
                p = cv.Utils.getPlatfomsInfo();
                validateattributes(p, {'struct'}, {'vector'});
            end
        end

        function test_cuda
            n = cv.Utils.getCudaEnabledDeviceCount();
            validateattributes(n, {'numeric'}, {'scalar', 'integer'});
            if n > 0
                id = cv.Utils.getDevice();
                validateattributes(id, {'numeric'}, {'scalar', 'integer'});
                cv.Utils.setDevice(id);

                s = cv.Utils.deviceSupports();
                validateattributes(s, {'struct'}, {'scalar'});

                cv.Utils.printShortCudaDeviceInfo(id);
                cv.Utils.printCudaDeviceInfo(id);

                s = cv.Utils.deviceInfo(id);
                validateattributes(s, {'struct'}, {'scalar'});

                cv.Utils.resetDevice();
            end
        end

        function test_tega
            % functions only defined for Tegra SoC
            if false
                b = cv.Utils.useTegra();
                validateattributes(b, {'logical'}, {'scalar'});
                cv.Utils.setUseTegra(b);
            end
        end
    end

end
