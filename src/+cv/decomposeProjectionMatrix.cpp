/**
 * @file decomposeProjectionMatrix.cpp
 * @brief mex interface for cv::decomposeProjectionMatrix
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from decomposed projection matrix.
 * @param rotMatrX Rotation matrix around x-axis.
 * @param rotMatrY Rotation matrix around y-axis.
 * @param rotMatrZ Rotation matrix around z-axis.
 * @param eulerAngles Euler angles of rotation.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& rotMatrX, const Mat& rotMatrY,
    const Mat& rotMatrZ, const Mat& eulerAngles)
{
    const char* fieldnames[] = {
        "rotMatrX", "rotMatrY", "rotMatrZ", "eulerAngles"};
    MxArray s = MxArray::Struct(fieldnames, 4);
    s.set("rotMatrX",    rotMatrX);
    s.set("rotMatrY",    rotMatrY);
    s.set("rotMatrZ",    rotMatrZ);
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
    nargchk(nrhs==1 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat projMatrix(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        cameraMatrix, rotMatrix, transVect,
        rotMatrX, rotMatrY, rotMatrZ, eulerAngles;
    decomposeProjectionMatrix(projMatrix, cameraMatrix, rotMatrix, transVect,
        (nlhs>3 ? rotMatrX : noArray()),
        (nlhs>3 ? rotMatrY : noArray()),
        (nlhs>3 ? rotMatrZ : noArray()),
        (nlhs>3 ? eulerAngles : noArray()));
    plhs[0] = MxArray(cameraMatrix);
    if (nlhs > 1)
        plhs[1] = MxArray(rotMatrix);
    if (nlhs > 2)
        plhs[2] = MxArray(transVect);
    if (nlhs > 3)
        plhs[3] = toStruct(rotMatrX, rotMatrY, rotMatrZ, eulerAngles);
}
