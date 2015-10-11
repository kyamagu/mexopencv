/**
 * @file illuminationChange.cpp
 * @brief mex interface for cv::illuminationChange
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    float alpha = 0.2f;
    float beta = 0.4f;
    bool flip = true;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Alpha")
            alpha = rhs[i+1].toFloat();
        else if (key == "Beta")
            beta = rhs[i+1].toFloat();
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)),
        mask(rhs[1].toMat(CV_8U)),
        dst;
    // MATLAB's default is RGB while OpenCV's is BGR
    if (flip && src.channels() == 3)
        cvtColor(src, src, cv::COLOR_RGB2BGR);
    if (flip && mask.channels() == 3)
        cvtColor(mask, mask, cv::COLOR_RGB2BGR);
    illuminationChange(src, mask, dst, alpha, beta);
    // OpenCV's default is BGR while MATLAB's is RGB
    if (flip && dst.channels() == 3)
        cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    plhs[0] = MxArray(dst);
}
