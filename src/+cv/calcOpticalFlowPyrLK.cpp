/**
 * @file calcOpticalFlowPyrLK.cpp
 * @brief mex interface for calcOpticalFlowPyrLK
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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat prevImg(rhs[0].toMat(CV_8U)), nextImg(rhs[1].toMat(CV_8U));
    vector<Point2f> prevPts(rhs[2].toVector<Point2f>()), nextPts;
    
    Size winSize=Size(15,15);
    int maxLevel=3;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 30, 0.01);
    double derivLambda=0.5;
    int flags=0;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="InitialFlow") {
            vector<MxArray> _nextPts(rhs[i+1].toVector<MxArray>());
            nextPts.reserve(_nextPts.size());
            for (vector<MxArray>::iterator it=_nextPts.begin();it<_nextPts.end();++it)
                nextPts.push_back((*it).toPoint_<float>());
            flags = OPTFLOW_USE_INITIAL_FLOW;
        }
        else if (key=="WinSize")
            winSize = rhs[i+1].toSize();
        else if (key=="MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else if (key=="DerivLambda")
            derivLambda = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    vector<uchar> status(prevPts.size());
    vector<float> err(prevPts.size());
    calcOpticalFlowPyrLK(prevImg, nextImg, prevPts, nextPts, status, err,
        winSize, maxLevel, criteria, derivLambda, flags);
    plhs[0] = MxArray(nextPts);
    if (nlhs>1)
        plhs[1] = MxArray(Mat(status));
    if (nlhs>2)
        plhs[2] = MxArray(Mat(err));
}
