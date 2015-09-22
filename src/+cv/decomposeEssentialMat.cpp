/**
 * @file decomposeEssentialMat.cpp
 * @brief mex interface for cv::decomposeEssentialMat
 * @ingroup calib3d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from decomposed essential matrix.
 * @param R1 one possible rotation matrix.
 * @param R2 another possible rotation matrix.
 * @param t one possible translation vector.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& R1, const Mat& R2, const Mat& t)
{
    const char* fieldnames[] = {"R1", "R2", "t"};
    MxArray s = MxArray::Struct(fieldnames, 3);
    s.set("R1", R1);
    s.set("R2", R2);
    s.set("t",  t);
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
    nargchk(nrhs==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat E(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        R1, R2, t;
    decomposeEssentialMat(E, R1, R2, t);
    plhs[0] = toStruct(R1, R2, t);
}
