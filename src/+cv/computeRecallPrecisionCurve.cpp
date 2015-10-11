/**
 * @file computeRecallPrecisionCurve.cpp
 * @brief mex interface for cv::computeRecallPrecisionCurve
 * @ingroup features2d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
#include "opencv2/features2d.hpp"
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    //vector<vector<DMatch>> matches1to2(rhs[0].toVector<vector<DMatch>>());
    vector<vector<DMatch> > matches1to2(rhs[0].toVector(
        const_mem_fun_ref_t<vector<DMatch>, MxArray>(
            &MxArray::toVector<DMatch>)));
    vector<vector<uchar> > correctMatches1to2Mask(
        MxArrayToVectorVectorPrimitive<uchar>(rhs[1]));
    vector<Point2f> recallPrecisionCurve;
    computeRecallPrecisionCurve(
        matches1to2, correctMatches1to2Mask, recallPrecisionCurve);
    plhs[0] = MxArray(Mat(recallPrecisionCurve,false).reshape(1,0)); // Nx2
}
