/**
 * @file BrightEdges.cpp
 * @brief mex interface for cv::ximgproc::BrightEdges
 * @ingroup ximgproc
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

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
    int contrast = 1;
    int shortrange = 3;
    int longrange = 9;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Contrast")
            contrast = rhs[i+1].toInt();
        else if (key == "ShortRange")
            shortrange = rhs[i+1].toInt();
        else if (key == "LongRange")
            longrange = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat()), edge;
    BrightEdges(image, edge, contrast, shortrange, longrange);
    plhs[0] = MxArray(edge);
}
