/**
 * @file findCirclesGrid.cpp
 * @brief mex interface for findCirclesGrid
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
    
    Mat image(rhs[0].toMat());
    Size patternSize(rhs[1].toSize());
    
    // Option processing
    bool symmetricGrid=true;
    bool clustering=false;
    Ptr<FeatureDetector> blobDetector(new SimpleBlobDetector());
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="SymmetricGrid")
            symmetricGrid = rhs[i+1].toBool();
        else if (key=="Clustering")
            clustering = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = ((symmetricGrid) ? CALIB_CB_SYMMETRIC_GRID : CALIB_CB_ASYMMETRIC_GRID) |
        ((clustering) ? CALIB_CB_CLUSTERING : 0);
    // Process
    vector<Point2f> centers;
    bool b = findCirclesGrid(image, patternSize, centers, flags);
    plhs[0] = MxArray((b) ? centers : Mat());
}
