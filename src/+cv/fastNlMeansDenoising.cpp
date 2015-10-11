/**
 * @file fastNlMeansDenoising.cpp
 * @brief mex interface for cv::fastNlMeansDenoising
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
    vector<float> h(1, 3);
    int templateWindowSize = 7;
    int searchWindowSize = 21;
    int normType = cv::NORM_L2;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "H")
            h = rhs[i+1].toVector<float>();
        else if (key == "TemplateWindowSize")
            templateWindowSize = rhs[i+1].toInt();
        else if (key == "SearchWindowSize")
            searchWindowSize = rhs[i+1].toInt();
        else if (key == "NormType")
            normType = NormType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint16() ? CV_16U : CV_8U)), dst;
    fastNlMeansDenoising(src, dst, h,
        templateWindowSize, searchWindowSize, normType);
    plhs[0] = MxArray(dst);
}
