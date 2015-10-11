/**
 * @file findCirclesGrid.cpp
 * @brief mex interface for cv::findCirclesGrid
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
using namespace std;
using namespace cv;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool symmetricGrid = true;
    bool clustering = false;
    Ptr<FeatureDetector> blobDetector;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="SymmetricGrid")
            symmetricGrid = rhs[i+1].toBool();
        else if (key=="Clustering")
            clustering = rhs[i+1].toBool();
        else if (key=="BlobDetector") {
            if (rhs[i+1].isChar())
                blobDetector = createFeatureDetector(rhs[i+1].toString(),
                    rhs.end(), rhs.end());
            else if (rhs[i+1].isCell() && rhs[i+1].numel() >= 2) {
                vector<MxArray> args(rhs[i+1].toVector<MxArray>());
                blobDetector = createFeatureDetector(args[0].toString(),
                    args.begin() + 1, args.end());
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = (symmetricGrid ? cv::CALIB_CB_SYMMETRIC_GRID :
                                 cv::CALIB_CB_ASYMMETRIC_GRID) |
                (clustering    ? cv::CALIB_CB_CLUSTERING : 0);
    if (blobDetector.empty())
        blobDetector = SimpleBlobDetector::create();

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    Size patternSize(rhs[1].toSize());
    vector<Point2f> centers;
    bool patternFound = findCirclesGrid(image, patternSize, centers, flags,
        blobDetector);
    plhs[0] = MxArray(centers);
    if (nlhs > 1)
        plhs[1] = MxArray(patternFound);
}
