/**
 * @file calibrationMatrixValues.cpp
 * @brief mex interface for calibrationMatrixValues
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Field names for struct
const char* _fieldnames[] = {"fovx","fovy","focalLength",
    "principalPoint","aspectRatio"};
/// Create a struct
mxArray* valueStruct(double& fovx, double& fovy, double& focalLength,
    Point2d& principalPoint, double& aspectRatio)
{
    mxArray* p = mxCreateStructMatrix(1,1,5,_fieldnames);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(p,0,"fovx",MxArray(fovx));
    mxSetField(p,0,"fovy",MxArray(fovy));
    mxSetField(p,0,"focalLength",MxArray(focalLength));
    mxSetField(p,0,"principalPoint",MxArray(principalPoint));
    mxSetField(p,0,"aspectRatio",MxArray(aspectRatio));
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
    if (nrhs!=4 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat cameraMatrix(rhs[0].toMat(CV_32F));
    Size imageSize(rhs[1].toSize());
    double apertureWidth = rhs[2].toDouble();
    double apertureHeight = rhs[3].toDouble();
    double fovx, fovy, focalLength;
    Point2d principalPoint;
    double aspectRatio;
    
    // Process
    calibrationMatrixValues(cameraMatrix, imageSize,
        apertureWidth, apertureHeight, fovx, fovy, focalLength,
        principalPoint, aspectRatio);

    plhs[0] = valueStruct(fovx,fovy,focalLength,principalPoint,aspectRatio);
}
