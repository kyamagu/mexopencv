/**
 * @file pencilSketch.cpp
 * @brief mex interface for cv::pencilSketch
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    float sigma_s = 60;
    float sigma_r = 0.07f;
    float shade_factor = 0.02f;
    bool flip = true;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "SigmaS")
            sigma_s = rhs[i+1].toFloat();
        else if (key == "SigmaR")
            sigma_r = rhs[i+1].toFloat();
        else if (key == "ShadeFactor")
            shade_factor = rhs[i+1].toFloat();
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst1, dst2;
    if (flip && src.channels() == 3) {
        // MATLAB's default is RGB while OpenCV's is BGR
        cvtColor(src, src, cv::COLOR_RGB2BGR);
    }
    pencilSketch(src, dst1, dst2, sigma_s, sigma_r, shade_factor);
    if (flip && dst2.channels() == 3) {
        // OpenCV's default is BGR while MATLAB's is RGB
        cvtColor(dst2, dst2, cv::COLOR_BGR2RGB);
    }
    plhs[0] = MxArray(dst1);
    if (nlhs > 1)
        plhs[1] = MxArray(dst2);
}
