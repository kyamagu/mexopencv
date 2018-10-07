/**
 * @file sampsonDistance.cpp
 * @brief mex interface for cv::sampsonDistance
 * @ingroup calib3d
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
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
    nargchk(nrhs==3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Vec3d pt1(rhs[0].toVec<double,3>()),
          pt2(rhs[1].toVec<double,3>());
    Matx33d F(rhs[2].toMatx<double,3,3>());
    double sd = sampsonDistance(pt1, pt2, F);
    plhs[0] = MxArray(sd);
}
