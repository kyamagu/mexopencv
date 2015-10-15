function tests = test_MxArray_fromMat()
    tests = functiontests(localfunctions);
end

function test_row_vector(t)
    v = 1:10;
    vv = testMxArray1_('fromMat_row_vector');
    t.verifyEqual(vv, v);
end

function test_col_vector(t)
    v = (1:10)';
    vv = testMxArray1_('fromMat_col_vector');
    t.verifyEqual(vv, v);
end
