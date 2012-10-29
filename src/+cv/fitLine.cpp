/**
 * @file fitLine.cpp
 * @brief mex interface for fitLine
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
    int distType=CV_DIST_L2;
    double param=0;
    double reps=0.01;
    double aeps=0.01;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DistType")
            distType = DistType[rhs[i+1].toString()];
        else if (key=="Param")
            param = rhs[i+1].toDouble();
        else if (key=="REps")
            reps = rhs[i+1].toDouble();
        else if (key=="AEps")
            aeps = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat());
        Vec4f line;
        fitLine(points, line, distType, param, reps, aeps);
        plhs[0] = MxArray(Mat(line));
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> points(rhs[0].toVector<Point2f>());
        Vec4f line;
        fitLine(points, line, distType, param, reps, aeps);
        plhs[0] = MxArray(Mat(line));
    }
}
