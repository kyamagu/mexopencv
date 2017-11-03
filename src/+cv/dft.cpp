/**
 * @file dft.cpp
 * @brief mex interface for cv::dft
 * @ingroup core
 * @author Amro
 * @date 2017
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = 0;
    int nonzeroRows = 0;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Inverse")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_INVERSE);
        else if (key == "Scale")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_SCALE);
        else if (key == "Rows")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_ROWS);
        else if (key == "ComplexOutput")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_COMPLEX_OUTPUT);
        else if (key == "RealOutput")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_REAL_OUTPUT);
        else if (key == "ComplexInput")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::DFT_COMPLEX_INPUT);
        else if (key == "NonzeroRows")
            nonzeroRows = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        dst;
    dft(src, dst, flags, nonzeroRows);
    plhs[0] = MxArray(dst);
}
