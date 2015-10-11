/**
 * @file groupRectangles.cpp
 * @brief mex interface for cv::groupRectangles
 * @ingroup objdetect
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int groupThreshold = 1;
    double eps = 0.2;
    vector<int> weights;
    vector<double> levelWeights;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Thresh")
            groupThreshold = rhs[i+1].toInt();
        else if (key == "EPS")
            eps = rhs[i+1].toDouble();
        else if (key == "Weights")
            weights = rhs[i+1].toVector<int>();
        else if (key == "LevelWeights")
            levelWeights = rhs[i+1].toVector<double>();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Rect> rectList(rhs[0].toVector<Rect>());
    if ((!weights.empty() && weights.size() != rectList.size()) ||
        (!levelWeights.empty() && levelWeights.size() != rectList.size()))
        mexErrMsgIdAndTxt("mexopencv:error", "Vectors are the wrong size");
    groupRectangles(rectList, groupThreshold, eps,
        (nlhs>1 || !weights.empty() ? &weights : NULL),
        (nlhs>2 || !levelWeights.empty() ? &levelWeights : NULL));
    plhs[0] = (rhs[0].isNumeric()) ?
        MxArray(Mat(rectList, false).reshape(1,0)) :  // Nx4
        MxArray(rectList);  // {[x,y,w,h], ...}
    if (nlhs > 1)
        plhs[1] = MxArray(weights);
    if (nlhs > 2)
        plhs[2] = MxArray(levelWeights);
}
