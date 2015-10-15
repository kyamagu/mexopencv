function tests = test_MxArray_toMat()
    tests = functiontests(localfunctions);
end

function test_row_vector(t)
    v = 1:10;
    success = testMxArray1_('toMat_row_vector', v);
    t.verifyTrue(success);
end

function test_col_vector(t)
    v = (1:10)';
    success = testMxArray1_('toMat_col_vector', v);
    t.verifyTrue(success);
end
