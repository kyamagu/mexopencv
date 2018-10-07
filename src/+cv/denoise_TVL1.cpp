/**
 * @file denoise_TVL1.cpp
 * @brief mex interface for cv::denoise_TVL1
 * @ingroup photo
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/photo.hpp"
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
    double lambda = 1.0;
    int niters = 30;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Lambda")
            lambda = rhs[i+1].toDouble();
        else if (key == "NIters")
            niters = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Mat> observations;
    {
        vector<MxArray> arr(rhs[0].toVector<MxArray>());
        observations.reserve(arr.size());
        for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
            observations.push_back(it->toMat(CV_8U));
    }
    Mat result;
    denoise_TVL1(observations, result, lambda, niters);
    plhs[0] = MxArray(result);
}
