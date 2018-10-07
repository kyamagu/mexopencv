/**
 * @file Canny2.cpp
 * @brief mex interface for cv::Canny
 * @ingroup imgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
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
    bool L2gradient = false;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "L2Gradient")
            L2gradient = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    double threshold1 = 0, threshold2 = 0;
    if (rhs[2].numel() == 2) {
        Scalar s(rhs[2].toScalar());
        threshold1 = s[0];
        threshold2 = s[1];
    }
    else {
        threshold2 = rhs[2].toDouble();
        threshold1 = 0.4 * threshold2;
    }

    // Process
    Mat dx(rhs[0].toMat(CV_16S)),
        dy(rhs[1].toMat(CV_16S)),
        edges;
    Canny(dx, dy, edges, threshold1, threshold2, L2gradient);
    plhs[0] = MxArray(edges);
}
