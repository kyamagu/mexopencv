/**
 * @file segmentMotion.cpp
 * @brief mex interface for cv::motempl::segmentMotion
 * @ingroup optflow
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/optflow.hpp"
using namespace std;
using namespace cv;
using namespace cv::motempl;

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
    nargchk(nrhs==3 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat mhi(rhs[0].toMat(CV_32F)), segmask;
    vector<Rect> boundingRects;
    double timestamp = rhs[1].toDouble(),
           segThresh = rhs[2].toDouble();
    segmentMotion(mhi, segmask, boundingRects, timestamp, segThresh);
    plhs[0] = MxArray(segmask);
    if (nlhs>1)
        plhs[1] = MxArray(boundingRects);
}
