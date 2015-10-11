/**
 * @file decolor.cpp
 * @brief mex interface for cv::decolor
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
    bool flip = true;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat color(rhs[0].toMat(CV_8U)), grayscale, color_boost;
    if (flip && color.channels()==3) {
        // MATLAB's default is RGB while OpenCV's is BGR
        cvtColor(color, color, cv::COLOR_RGB2BGR);
    }
    decolor(color, grayscale, color_boost);
    if (flip && color_boost.channels()==3) {
        // OpenCV's default is BGR while MATLAB's is RGB
        cvtColor(color_boost, color_boost, cv::COLOR_BGR2RGB);
    }
    plhs[0] = MxArray(grayscale);
    if (nlhs > 1)
        plhs[1] = MxArray(color_boost);
}
