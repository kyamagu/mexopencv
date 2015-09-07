/**
 * @file kmeans.cpp
 * @brief mex interface for cv::kmeans
 * @ingroup core
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// KMeans initalization types for option processing
const ConstMap<string,int> Initialization = ConstMap<string,int>
    ("Random", cv::KMEANS_RANDOM_CENTERS)
    ("PP",     cv::KMEANS_PP_CENTERS);
}

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat bestLabels;
    TermCriteria criteria;
    int attempts = 10;
    int flags = cv::KMEANS_RANDOM_CENTERS;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="InitialLabels") {
            bestLabels = rhs[i+1].toMat(CV_32S);
            flags |= cv::KMEANS_USE_INITIAL_LABELS;
        }
        else if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else if (key=="Attempts")
            attempts = rhs[i+1].toInt();
        else if (key=="Initialization")
            flags = Initialization[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat data(rhs[0].toMat(CV_32F)), centers;
    int K = rhs[1].toInt();
    double compactness = kmeans(data, K, bestLabels, criteria, attempts,
        flags, (nlhs>1 ? centers : noArray()));
    plhs[0] = MxArray(bestLabels);
    if (nlhs>1)
        plhs[1] = MxArray(centers);
    if (nlhs>2)
        plhs[2] = MxArray(compactness);
}
