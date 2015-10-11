/**
 * @file eigen.cpp
 * @brief mex interface for cv::eigen
 * @ingroup core
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
    nargchk(nrhs==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F));
    Mat eigenvalues, eigenvectors;
    bool b = eigen(src, eigenvalues, (nlhs>1 ? eigenvectors : noArray()));
    plhs[0] = MxArray(eigenvalues);
    if (nlhs > 1)
        plhs[1] = MxArray(eigenvectors);
    if (nlhs > 2)
        plhs[2] = MxArray(b);
}
