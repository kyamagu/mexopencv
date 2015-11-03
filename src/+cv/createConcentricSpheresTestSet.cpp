/**
 * @file createConcentricSpheresTestSet.cpp
 * @brief mex interface for cv::ml::createConcentricSpheresTestSet
 * @ingroup ml
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/ml.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

//TODO: https://github.com/Itseez/opencv/issues/5469

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
    int num_samples = rhs[0].toInt(),
        num_features = rhs[1].toInt(),
        num_classes = rhs[2].toInt();
    Mat samples, responses;
    createConcentricSpheresTestSet(num_samples, num_features, num_classes,
        samples, responses);
    plhs[0] = MxArray(samples);
    if (nlhs > 1)
        plhs[1] = MxArray(responses);
}
