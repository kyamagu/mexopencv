/**
 * @file estimateGlobalMotionRansac.cpp
 * @brief mex interface for cv::videostab::estimateGlobalMotionRansac
 * @ingroup videostab
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/videostab.hpp"
using namespace std;
using namespace cv;
using namespace cv::videostab;

namespace {
/// motion model types for option processing
const ConstMap<string,MotionModel> MotionModelMap = ConstMap<string,MotionModel>
    ("Translation",         cv::videostab::MM_TRANSLATION)
    ("TranslationAndScale", cv::videostab::MM_TRANSLATION_AND_SCALE)
    ("Rotation",            cv::videostab::MM_ROTATION)
    ("Rigid",               cv::videostab::MM_RIGID)
    ("Similarity",          cv::videostab::MM_SIMILARITY)
    ("Affine",              cv::videostab::MM_AFFINE)
    ("Homography",          cv::videostab::MM_HOMOGRAPHY)
    ("Unknown",             cv::videostab::MM_UNKNOWN);

/** Convert MxArray to RansacParams
 * @param arr input MxArray structure
 * @return output instance of RansacParams
 */
RansacParams toRansacParams(const MxArray &arr)
{
    return RansacParams(
        arr.at("Size").toInt(),
        arr.at("Thresh").toFloat(),
        arr.at("Eps").toFloat(),
        arr.at("Prob").toFloat());
}
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int model = cv::videostab::MM_AFFINE;
    RansacParams params = RansacParams::default2dMotion(cv::videostab::MM_AFFINE);
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MotionModel")
            model = MotionModelMap[rhs[i+1].toString()];
        else if (key == "RansacParams")
            params = (rhs[i+1].isStruct() ? toRansacParams(rhs[i+1]) :
                RansacParams::default2dMotion(MotionModelMap[rhs[i+1].toString()]));
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat M;
    float rmse = 0;
    int ninliers = 0;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points0(rhs[0].toMat(CV_32F)),
            points1(rhs[1].toMat(CV_32F));
        M = estimateGlobalMotionRansac(points0, points1, model, params,
            &rmse, &ninliers);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> points0(rhs[0].toVector<Point2f>()),
                        points1(rhs[1].toVector<Point2f>());
        M = estimateGlobalMotionRansac(points0, points1, model, params,
            &rmse, &ninliers);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid points argument");
    plhs[0] = MxArray(M);
    if (nlhs > 1)
        plhs[1] = MxArray(rmse);
    if (nlhs > 2)
        plhs[2] = MxArray(ninliers);
}
