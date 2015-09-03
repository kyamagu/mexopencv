/**
 * @file calcGlobalOrientation.cpp
 * @brief mex interface for cv::motempl::calcGlobalOrientation
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
    nargchk(nrhs==5 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat orientation(rhs[0].toMat(CV_32F)),
        mask(rhs[1].toMat(CV_8U)),
        mhi(rhs[2].toMat(CV_32F));
    double timestamp = rhs[3].toDouble(),
           duration = rhs[4].toDouble();
    double fbaseOrient = calcGlobalOrientation(orientation, mask, mhi,
        timestamp, duration);
    plhs[0] = MxArray(fbaseOrient);
}
