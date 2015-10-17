classdef MxArrayTest < matlab.unittest.TestCase

    properties
        vec = 1:10;
    end

    methods (TestClassSetup)
        function setupClass(t)
        end
    end

    methods (TestMethodSetup)
        function setupMethod(t)
        end
    end

    methods (TestMethodTeardown)
        function teardownMethod(t)
        end
    end

    %% MxArray::toMat
    methods (Test)  % TestTags = {'toMat'}
        function toMat_row_vector(t)
            success = testMxArray1_('toMat_row_vector', t.vec);
            t.verifyTrue(success);
        end

        function toMat_col_vector(t)
            success = testMxArray1_('toMat_col_vector', t.vec');
            t.verifyTrue(success);
        end
    end

    %% MxArray::MxArray(cv::Mat)
    methods (Test)  % TestTags = {'fromMat'}
        function fromMat_row_vector(t)
            v = testMxArray1_('fromMat_row_vector');
            t.verifyEqual(v, t.vec);
        end

        function fromMat_col_vector(t)
            v = testMxArray1_('fromMat_col_vector');
            t.verifyEqual(v, t.vec');
        end
    end

    %% MxArray::MxArray(T), T = int,double,bool
    methods (Test)  % TestTags = {'from_scalar'}
        function from_scalar_int(t)
            x = testMxArray1_('from_scalar_int');
            t.verifyEqual(x, 5);
        end

        function from_scalar_double(t)
            x = testMxArray1_('from_scalar_double');
            t.verifyEqual(x, 3.14);
        end

        function from_scalar_bool(t)
            x = testMxArray1_('from_scalar_bool');
            t.verifyEqual(x, true);
        end

        function from_string(t)
            x = testMxArray1_('from_string');
            t.verifyEqual(x, 'test');
        end
    end

end
