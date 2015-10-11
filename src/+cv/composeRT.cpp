/**
 * @file composeRT.cpp
 * @brief mex interface for cv::composeRT
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from combined transformations.
 * @param rvec3 Rotation vector of the superposition.
 * @param tvec3 Translation vector of the superposition.
 * @param dr3dr1 Derivative of \p rvec3 with regard to \c rvec1.
 * @param dr3dt1 Derivative of \p rvec3 with regard to \c tvec1.
 * @param dr3dr2 Derivative of \p rvec3 with regard to \c rvec2.
 * @param dr3dt2 Derivative of \p rvec3 with regard to \c tvec2.
 * @param dt3dr1 Derivative of \p tvec3 with regard to \c rvec1.
 * @param dt3dt1 Derivative of \p tvec3 with regard to \c tvec1.
 * @param dt3dr2 Derivative of \p tvec3 with regard to \c rvec2.
 * @param dt3dt2 Derivative of \p tvec3 with regard to \c tvec2.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& rvec3, const Mat& tvec3, const Mat& dr3dr1,
    const Mat& dr3dt1, const Mat& dr3dr2, const Mat& dr3dt2, const Mat& dt3dr1,
    const Mat& dt3dt1, const Mat& dt3dr2, const Mat& dt3dt2)
{
    const char* fieldnames[] = {"rvec3", "tvec3", "dr3dr1", "dr3dt1",
        "dr3dr2", "dr3dt2", "dt3dr1", "dt3dt1", "dt3dr2", "dt3dt2"};
    MxArray s = MxArray::Struct(fieldnames, 10);
    s.set("rvec3",  rvec3);
    s.set("tvec3",  tvec3);
    s.set("dr3dr1", dr3dr1);
    s.set("dr3dt1", dr3dt1);
    s.set("dr3dr2", dr3dr2);
    s.set("dr3dt2", dr3dt2);
    s.set("dt3dr1", dt3dr1);
    s.set("dt3dt1", dt3dt1);
    s.set("dt3dr2", dt3dr2);
    s.set("dt3dt2", dt3dt2);
    return s;
}
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs==4 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat rvec1(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        tvec1(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        rvec2(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
        tvec2(rhs[3].toMat(rhs[3].isSingle() ? CV_32F : CV_64F)),
        rvec3, tvec3,
        dr3dr1, dr3dt1, dr3dr2, dr3dt2,
        dt3dr1, dt3dt1, dt3dr2, dt3dt2;
    composeRT(rvec1, tvec1, rvec2, tvec2, rvec3, tvec3,
        dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2);
    plhs[0] = toStruct(rvec3, tvec3,
        dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2);
}
