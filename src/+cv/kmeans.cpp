/**
 * @file kmeans.cpp
 * @brief mex interface for kmeans
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** KMeans initalization types for option processing
 */
const ConstMap<std::string,int> Initialization = ConstMap<std::string,int>
    ("Random",KMEANS_RANDOM_CENTERS)
    ("PP",KMEANS_PP_CENTERS);

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat samples(rhs[0].toMat(CV_32F));
    int clusterCount = rhs[1].toInt();
    Mat labels;
    TermCriteria criteria;
    int attempts=10;
    int flags = KMEANS_RANDOM_CENTERS;
    Mat centers;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="InitialLabels")
            labels = rhs[i+1].toMat(CV_32S);
        else if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else if (key=="Attempts")
            attempts = rhs[i+1].toInt();
        else if (key=="Initialization")
            flags = Initialization[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    flags |= (labels.empty()) ? 0 : KMEANS_USE_INITIAL_LABELS;
    
    // Process
    double d = kmeans(samples, clusterCount, labels, criteria, attempts, flags,
        centers);
    plhs[0] = MxArray(labels);
    if (nlhs>1)
        plhs[1] = MxArray(centers);
    if (nlhs>2)
        plhs[2] = MxArray(d);
}
