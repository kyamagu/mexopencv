/**
 * @file decomposeProjectionMatrix.cpp
 * @brief mex interface for decomposeProjectionMatrix
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Field names for struct
const char* _fieldnames[] = {"cameraMatrix", "rotMatrix", "transVect",
    "rotMatrX", "rotMatrY", "rotMatrZ", "eulerAngles"};
/// Create a struct
mxArray* valueStruct(const Mat& cameraMatrix, const Mat& rotMatrix, const Mat& transVect,
    const Mat& rotMatrX, const Mat& rotMatrY, const Mat& rotMatrZ, const Mat& eulerAngles)
{
    mxArray* p = mxCreateStructMatrix(1,1,7,_fieldnames);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(p,0,"cameraMatrix",MxArray(cameraMatrix));
    mxSetField(p,0,"rotMatrix",MxArray(rotMatrix));
    mxSetField(p,0,"transVect",MxArray(transVect));
    mxSetField(p,0,"rotMatrX",MxArray(rotMatrX));
    mxSetField(p,0,"rotMatrY",MxArray(rotMatrY));
    mxSetField(p,0,"rotMatrZ",MxArray(rotMatrZ));
    mxSetField(p,0,"eulerAngles",MxArray(eulerAngles));
    return p;
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
    if (nrhs!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Process
    Mat projMatrix(rhs[0].toMat(CV_32F));
    Mat cameraMatrix, rotMatrix, transVect, rotMatrX, rotMatrY, rotMatrZ, eulerAngles;
    decomposeProjectionMatrix(projMatrix, cameraMatrix, rotMatrix, transVect,
        rotMatrX, rotMatrY, rotMatrZ, eulerAngles);
    plhs[0] = valueStruct(cameraMatrix, rotMatrix, transVect, rotMatrX,
        rotMatrY, rotMatrZ, eulerAngles);
}
