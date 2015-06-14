/**
 * @file compareHist.cpp
 * @brief mex interface for compareHist
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Histogram comparison methods
 */
const ConstMap<std::string,int> HistComp = ConstMap<std::string,int>
    ("Correlation",     cv::HISTCMP_CORREL)
    ("ChiSquare",       cv::HISTCMP_CHISQR)
    ("Intersection",    cv::HISTCMP_INTERSECT)
    ("Bhattacharyya",   cv::HISTCMP_BHATTACHARYYA)
    ("Hellinger",       cv::HISTCMP_HELLINGER)
    ("AltChiSquare",    cv::HISTCMP_CHISQR_ALT)
    ("KullbackLeibler", cv::HISTCMP_KL_DIV);

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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int method = cv::HISTCMP_CORREL;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Method")
            method = (rhs[i+1].isChar()) ?
                HistComp[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    MatND H1(rhs[0].toMat()), H2(rhs[1].toMat());
    double d = compareHist(H1, H2, method);
    plhs[0] = MxArray(d);
}
