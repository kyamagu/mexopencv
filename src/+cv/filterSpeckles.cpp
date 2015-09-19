/**
 * @file filterSpeckles.cpp
 * @brief mex interface for cv::filterSpeckles
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs==4 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat img(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_16S));
    double newVal = rhs[1].toDouble();
    int maxSpeckleSize = rhs[2].toInt();
    double maxDiff = rhs[3].toDouble();
    filterSpeckles(img, newVal, maxSpeckleSize, maxDiff);
    plhs[0] = MxArray(img);
}
