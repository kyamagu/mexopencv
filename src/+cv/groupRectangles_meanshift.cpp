/**
 * @file groupRectangles_meanshift.cpp
 * @brief mex interface for cv::groupRectangles_meanshift
 * @ingroup objdetect
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double detectThreshold = 0.0;
    Size winDetSize(64,128);
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DetectThreshold")
            detectThreshold = rhs[i+1].toDouble();
        else if (key == "WinDetSize")
            winDetSize = rhs[i+1].toSize();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Rect> rectList(rhs[0].toVector<Rect>());
    vector<double> foundWeights(rhs[1].toVector<double>()),
                   foundScales(rhs[2].toVector<double>());
    if (foundWeights.size() != rectList.size() ||
        foundScales.size() != rectList.size())
        mexErrMsgIdAndTxt("mexopencv:error", "Vectors are the wrong size");
    groupRectangles_meanshift(rectList, foundWeights, foundScales,
        detectThreshold, winDetSize);
    plhs[0] = (rhs[0].isNumeric()) ?
        MxArray(Mat(rectList, false).reshape(1,0)) :  // Nx4
        MxArray(rectList);  // {[x,y,w,h], ...}
    if (nlhs > 1)
        plhs[1] = MxArray(foundWeights);
}
