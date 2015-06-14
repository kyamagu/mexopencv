/**
 * @file decomposeProjectionMatrix.cpp
 * @brief mex interface for decomposeProjectionMatrix
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
MxArray valueStruct(const Mat& rotMatrX, const Mat& rotMatrY,
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs!=1 || nlhs>4)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Process
    Mat projMatrix(rhs[0].toMat(CV_32F));
    Mat cameraMatrix, rotMatrix, transVect,
        rotMatrX, rotMatrY, rotMatrZ, eulerAngles;
    decomposeProjectionMatrix(projMatrix, cameraMatrix, rotMatrix, transVect,
        rotMatrX, rotMatrY, rotMatrZ, eulerAngles);
    plhs[0] = MxArray(cameraMatrix);
    if (nlhs > 1)
        plhs[1] = MxArray(rotMatrix);
    if (nlhs > 2)
        plhs[2] = MxArray(transVect);
    if (nlhs > 3)
        plhs[3] = valueStruct(rotMatrX, rotMatrY, rotMatrZ, eulerAngles);
}
