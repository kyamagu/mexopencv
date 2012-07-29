/**
 * @file initUndistortRectifyMap.cpp
 * @brief mex interface for initUndistortRectifyMap
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Type specification
 */
const ConstMap<std::string,int> M1Type = ConstMap<std::string,int>
    ("int16",  CV_16SC2)
    ("single", CV_32F);

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
    if (nrhs<4 || ((nrhs%2)!=0) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat cameraMatrix(rhs[0].toMat(CV_32F));
    Mat distCoeffs(rhs[1].toMat(CV_32F));
    Mat newCameraMatrix(rhs[2].toMat(CV_32F));
    Size size(rhs[3].toSize());
    Mat R;
    int m1type = CV_32F;
    for (int i=4; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="R")
            R = rhs[i+1].toMat(CV_32F);
        else if (key=="M1Type")
            m1type = M1Type[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    if (m1type != CV_16SC2)
        m1type = (m1type==CV_32F && nlhs>1) ? CV_32FC2 : CV_32FC1;
    
    // Process
    Mat map1, map2;
    initUndistortRectifyMap(cameraMatrix, distCoeffs, R, newCameraMatrix, size,
        m1type, map1, map2);
    plhs[0] = MxArray(map1);
    if (nlhs>1)
        plhs[1] = MxArray(map2);
}
