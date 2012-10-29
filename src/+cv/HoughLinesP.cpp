/**
 * @file HoughLinesP.cpp
 * @brief mex interface for HoughLinesP
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat image(rhs[0].toMat(CV_8U));
    vector<Vec4i> lines;
    double rho=1;
    double theta=CV_PI/180;
    int threshold=80;
    double minLineLength=0;
    double maxLineGap=0;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Rho")
            rho = rhs[i+1].toDouble();
        else if (key=="Theta")
            theta = rhs[i+1].toDouble();
        else if (key=="Threshold")
            threshold = rhs[i+1].toInt();
        else if (key=="MinLineLength")
            minLineLength = rhs[i+1].toDouble();
        else if (key=="MaxLineGap")
            maxLineGap = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    HoughLinesP(image, lines, rho, theta, threshold, minLineLength, maxLineGap);
    vector<Mat> vl(lines.size());
    for (int i=0;i<vl.size();++i)
        vl[i] = Mat(1,4,CV_32SC1,&lines[i][0]);
    plhs[0] = MxArray(vl);
}
