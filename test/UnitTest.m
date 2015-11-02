classdef UnitTest
    %UNITTEST  Helper class for unit testing
    %
    % ## Usage
    %
    %    cd test;
    %    UnitTest;
    %
    % See also: matlab.unittest
    %

    properties (Constant)
        % tests root directories
        TESTDIR1 = fullfile(mexopencv.root(),'test','unit_tests');
        TESTDIR2 = fullfile(mexopencv.root(),'opencv_contrib','test','unit_tests');

        % Tests to skip due to bugs in Octave
        SKIP = {
            % local functions in M-classes
            'TestConjGradSolver'
            'TestDownhillSolver'
            'TestNormalize'
            'TestSVM'
            'TestGeneralizedHoughBallard'
            'TestGeneralizedHoughGuil'
            'TestCalibrateCamera'
            'TestCascadeClassifier'
            'TestDenoise_TVL1'
            'TestHOGDescriptor'
            'TestRemap'
            'TestReprojectImageTo3D'
            'TestStereoCalibrate'
            'TestStereoRectify'
            'TestStereoRectifyUncalibrated'
            % codecs
            'TestVideoWriter'
        };
    end

    methods
        function obj = UnitTest(opencv_contrib)
            %UNITTEST  Execute all unit tests
            %
            % See also: UnitTest.all
            %

            %TODO: detect if opencv_contrib is available
            if nargin < 1, opencv_contrib = false; end

            % setup path to unit tests
            addpath(UnitTest.TESTDIR1);
            if opencv_contrib
                addpath(UnitTest.TESTDIR2);
            end

            % log output to timestamped file in current directory
            diary(sprintf('UnitTest_%s.log', datestr(now,'yyyymmddTHHMMSS')));
            cObj = onCleanup(@() diary('off'));  % turn off logging when done

            if ~mexopencv.isOctave()
                ver matlab;
            else
                ver octave;
                %disp(octave_config_info())
            end

            % get a list of all test classes
            d = dir(fullfile(UnitTest.TESTDIR1, 'Test*.m'));
            if opencv_contrib
                d = [d ; dir(fullfile(UnitTest.TESTDIR2, 'Test*.m'))];
            end

            % run test suite
            ntests = [0 0];
            tID = tic();
            for i=1:numel(d)
                if i>3; break; end
                klass = strrep(d(i).name, '.m', '');
                fprintf('== %s ==\n', klass);
                if mexopencv.isOctave() && any(strcmp(klass, UnitTest.SKIP))
                    disp('SKIP');
                    continue;
                end
                numtests = UnitTest.all(klass);
                ntests = ntests + numtests;
            end
            elapsed = toc(tID);

            % summary
            fprintf('\nTotals:\n');
            fprintf('  %d Passed, %d Failed\n', ntests(1), ntests(2));
            fprintf('  Elapsed time is %f seconds.\n', elapsed);
        end
    end

    methods (Static)
        function varargout = all(klass)
            %ALL  Execute all test methods in specified test class
            %
            % ## Input
            % * __klass__ Test class to run. This can be specified as:
            %       * name of class as a string
            %       * metaclass object associated with the test class
            %       * instance of test class itself as object
            %
            % ## Output
            % * __numtests__ optional output 2-element vector, containing
            %       number of tests that passed and failed respectively.
            %
            % ## Usage
            %
            %    UnitTest.all('TestBlur');
            %    UnitTest.all(?TestBlur);
            %    UnitTest.all(TestBlur);
            %
            % See also: meta.class
            %

            % get class metadata
            if nargin < 1, klass = mfilename; end
            if ischar(klass)
                mc = meta.class.fromName(klass);
            elseif isa(klass, 'meta.class')
                mc = klass;
            elseif isobject(klass)
                mc = metaclass(klass);
            else
                error('UnitTest:all', 'Invalid class argument');
            end
            assert(~isempty(mc), 'Test class not found');

            % get list of all method names
            if ~mexopencv.isOctave() && isprop(mc,'MethodList')
                mt = {mc.MethodList.Name};
            else
                mt = cellfun(@(x) x.Name, mc.Methods, 'UniformOutput',false);
            end
            mt = sort(mt(:))';

            % only keep methods starting with the 'test' prefix
            idx = strncmp('test', mt, length('test'));
            mt = mt(idx);

            % evaluate all test methods, and report success/failure
            npass = 0;
            nfail = 0;
            for i=1:numel(mt)
                fprintf('-- %s --\n', mt{i});
                fname = [mc.Name '.' mt{i}];
                try
                    if ~mexopencv.isOctave()
                        feval(fname);
                    else
                        eval(fname);
                    end
                    disp('PASS');
                    npass = npass + 1;
                catch ME
                    if ~mexopencv.isOctave()
                        disp(ME.getReport());
                    else
                        disp(ME.message);
                    end
                    disp('FAIL');
                    nfail = nfail + 1;
                end
            end

            if nargout > 0
                varargout{1} = [npass, nfail];
            end
        end
    end

end
