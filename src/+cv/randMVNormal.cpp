/**
 * @file randMVNormal.cpp
 * @brief mex interface for cv::ml::randMVNormal
 * @ingroup ml
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/ml.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

//TODO: https://github.com/Itseez/opencv/issues/5469

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
    nargchk(nrhs==3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat mean(rhs[0].toMat(CV_32F)),
        cov(rhs[1].toMat(CV_32F)),
        samples;
    int nsamples = rhs[2].toInt();
    randMVNormal(mean, cov, nsamples, samples);
    plhs[0] = MxArray(samples);
}
