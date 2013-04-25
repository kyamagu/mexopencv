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

    Size winSize = Size(21,21);
    int maxLevel = 3;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 30, 0.01);
    int flags = 0;
    double minEigThreshold = 1e-4;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="InitialFlow") {
            nextPts = rhs[i+1].toVector<Point2f>();
            flags |= OPTFLOW_USE_INITIAL_FLOW;
        }
        else if (key=="WinSize")
            winSize = rhs[i+1].toSize();
        else if (key=="MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else if (key=="GetMinEigenvals")
            flags |= (rhs[i+1].toBool()) ? OPTFLOW_LK_GET_MIN_EIGENVALS : 0;
        else if (key=="MinEigThreshold")
            minEigThreshold = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    vector<uchar> status(prevPts.size());
    vector<float> err(prevPts.size());

    if (prevPts.size()>0) {
        calcOpticalFlowPyrLK(prevImg, nextImg, prevPts, nextPts, status, err,
        winSize, maxLevel, criteria, flags, minEigThreshold);
    }

    plhs[0] = MxArray(nextPts);
    if (nlhs>1)
        plhs[1] = MxArray(Mat(status));
    if (nlhs>2)
        plhs[2] = MxArray(Mat(err));
}
