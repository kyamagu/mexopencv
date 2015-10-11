/**
 * @file validateDisparity.cpp
 * @brief mex interface for cv::validateDisparity
 * @ingroup calib3d
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int minDisparity = 0;
    int numberOfDisparities = 64;
    int disp12MaxDiff = 1;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MinDisparity")
            minDisparity = rhs[i+1].toInt();
        else if (key == "NumDisparities")
            numberOfDisparities = rhs[i+1].toInt();
        else if (key == "Disp12MaxDiff")
            disp12MaxDiff = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat disparity(rhs[0].toMat(CV_16S)),
        cost(rhs[1].toMat(rhs[1].isInt32() ? CV_32S : CV_16S));
    validateDisparity(disparity, cost,
        minDisparity, numberOfDisparities, disp12MaxDiff);
    plhs[0] = MxArray(disparity);
}
