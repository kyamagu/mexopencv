/**
 * @file matchShapes.cpp
 * @brief mex interface for matchShapes
 * @author Kota Yamaguchi
 * @date 2012
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
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int method=CV_CONTOURS_MATCH_I1;
    double parameter=0;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Method") {
            string val(rhs[i+1].toString());
            if (val=="I1")
                method = CV_CONTOURS_MATCH_I1;
            else if (val=="I2")
                method = CV_CONTOURS_MATCH_I2;
            else if (val=="I3")
                method = CV_CONTOURS_MATCH_I3;
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized method");
        }
        else if (key=="Parameter")
            parameter = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat object1(rhs[0].toMat(CV_8U)), object2(rhs[1].toMat(CV_8U));
        double d = matchShapes(object1,object2,method,parameter);
        plhs[0] = MxArray(d);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> object1(rhs[0].toVector<Point2f>());
        vector<Point2f> object2(rhs[1].toVector<Point2f>());
        double d = matchShapes(object1,object2,method,parameter);
        plhs[0] = MxArray(d);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
}
