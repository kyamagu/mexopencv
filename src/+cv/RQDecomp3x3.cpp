/**
 * @file RQDecomp3x3.cpp
 * @brief mex interface for cv::RQDecomp3x3
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from decomposed matrix.
 * @param Qx Rotation matrix around x-axis.
 * @param Qy Rotation matrix around y-axis.
 * @param Qz Rotation matrix around z-axis.
 * @param eulerAngles Euler angles of rotation.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& Qx, const Mat& Qy, const Mat& Qz,
    const Vec3d& eulerAngles)
{
    const char* fieldnames[] = {"Qx", "Qy", "Qz", "eulerAngles"};
    MxArray s = MxArray::Struct(fieldnames, 4);
    s.set("Qx",          Qx);
    s.set("Qy",          Qy);
    s.set("Qz",          Qz);
    s.set("eulerAngles", eulerAngles);
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
    nargchk(nrhs==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat M(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        R, Q, Qx, Qy, Qz;
    Vec3d eulerAngles = RQDecomp3x3(M, R, Q,
        (nlhs>2 ? Qx : noArray()),
        (nlhs>2 ? Qy : noArray()),
        (nlhs>2 ? Qz : noArray()));
    plhs[0] = MxArray(R);
    if (nlhs>1)
        plhs[1] = MxArray(Q);
    if (nlhs>2)
        plhs[2] = toStruct(Qx, Qy, Qz, eulerAngles);
}
