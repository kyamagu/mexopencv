/**
 * @file imdecode.cpp
 * @brief mex interface for imdecode
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

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
    if (nrhs<1 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    int flags = 1;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key == "Flags")
            flags = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat buf(rhs[0].toMat(CV_8U));
    Mat m = imdecode(buf, flags);
    if (m.data == NULL)
        mexErrMsgIdAndTxt("mexopencv:error","imdecode failed");
    // OpenCV's default is BGR while Matlab's is RGB
    if (m.type() == CV_8UC3)
        cvtColor(m, m, CV_BGR2RGB);
    plhs[0] = MxArray(m);
}
