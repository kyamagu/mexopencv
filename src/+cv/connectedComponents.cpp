/**
 * @file connectedComponents.cpp
 * @brief mex interface for cv::connectedComponents
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

namespace {
/// Map type specification
const ConstMap<string,int> CCLAlgMap = ConstMap<string,int>
    ("Wu",      cv::CCL_WU)
    ("Default", cv::CCL_DEFAULT)
    ("Grana",   cv::CCL_GRANA);
}

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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int connectivity = 8;
    int ltype = CV_32S;
    int ccltype = cv::CCL_DEFAULT;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Connectivity")
            connectivity = rhs[i+1].toInt();
        else if (key == "LType")
            ltype = ClassNameMap[rhs[i+1].toString()];
        else if (key == "Method")
            ccltype = CCLAlgMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat(CV_8U)), labels;
    int N = 0;
    if (nlhs > 2) {
        Mat stats, centroids;
        N = connectedComponentsWithStats(img, labels, stats, centroids,
            connectivity, ltype, ccltype);
        plhs[2] = MxArray(stats);
        if (nlhs > 3)
            plhs[3] = MxArray(centroids);
    }
    else
        N = connectedComponents(img, labels, connectivity, ltype, ccltype);
    plhs[0] = MxArray(labels);
    if (nlhs > 1)
        plhs[1] = MxArray(N);
}
