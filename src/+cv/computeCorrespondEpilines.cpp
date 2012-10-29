/**
 * @file computeCorrespondEpilines.cpp
 * @brief mex interface for computeCorrespondEpilines
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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat F(rhs[1].toMat(CV_32F));
    int whichImage = 1;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="WhichImage") {
            whichImage = rhs[i+1].toInt();
            if (whichImage!=1&&whichImage!=2)
                mexErrMsgIdAndTxt("mexopencv:error","Invalid WhichImage");
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    vector<Vec3f> lines;
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(CV_32F));
        computeCorrespondEpilines(points, whichImage, F, lines);
    }
    else if (rhs[0].isCell()) {
        vector<Point2f> points(rhs[0].toVector<Point2f>());
        computeCorrespondEpilines(points, whichImage, F, lines);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    vector<Mat> _lines;
    _lines.reserve(lines.size());
    for (vector<Vec3f>::iterator it=lines.begin(); it<lines.end(); ++it)
        _lines.push_back(Mat(*it));

    plhs[0] = MxArray(_lines);
}
