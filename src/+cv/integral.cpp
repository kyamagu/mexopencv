/**
 * @file integral.cpp
 * @brief mex interface for cv::integral
 * @ingroup imgproc
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int sdepth = -1;
    int sqdepth = -1;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="SDepth")
            sdepth = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (nlhs>1 && key=="SQDepth")
            sqdepth = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat()), sum, sqsum, tilted;
    switch (nlhs) {
        case 0:
        case 1:
            integral(src, sum, sdepth);
            plhs[0] = MxArray(sum);
            break;
        case 2:
            integral(src, sum, sqsum, sdepth, sqdepth);
            plhs[0] = MxArray(sum);
            plhs[1] = MxArray(sqsum);
            break;
        case 3:
            integral(src, sum, sqsum, tilted, sdepth, sqdepth);
            plhs[0] = MxArray(sum);
            plhs[1] = MxArray(sqsum);
            plhs[2] = MxArray(tilted);
            break;
    }
}
