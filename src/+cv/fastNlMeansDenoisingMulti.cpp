/**
 * @file fastNlMeansDenoisingMulti.cpp
 * @brief mex interface for cv::fastNlMeansDenoisingMulti
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    vector<float> h(1, 3);
    int templateWindowSize = 7;
    int searchWindowSize = 21;
    int normType = cv::NORM_L2;
    for (int i=3; i<nrhs; i+=2) {
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
    vector<Mat> srcImgs;
    {
        vector<MxArray> arr(rhs[0].toVector<MxArray>());
        srcImgs.reserve(arr.size());
        for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
            srcImgs.push_back(it->toMat(it->isUint16() ? CV_16U : CV_8U));
    }
    int imgToDenoiseIndex = rhs[1].toInt();
    int temporalWindowSize = rhs[2].toInt();
    Mat dst;
    fastNlMeansDenoisingMulti(srcImgs, dst, imgToDenoiseIndex,
        temporalWindowSize, h, templateWindowSize, searchWindowSize, normType);
    plhs[0] = MxArray(dst);
}
