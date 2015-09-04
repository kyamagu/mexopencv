/**
 * @file fastNlMeansDenoisingColoredMulti.cpp
 * @brief mex interface for cv::fastNlMeansDenoisingColoredMulti
 * @ingroup photo
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/photo.hpp"
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    float h = 3;
    float hColor = 3;
    int templateWindowSize = 7;
    int searchWindowSize = 21;
    bool flip = true;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "H")
            h = rhs[i+1].toFloat();
        else if (key == "HColor")
            hColor = rhs[i+1].toFloat();
        else if (key == "TemplateWindowSize")
            templateWindowSize = rhs[i+1].toInt();
        else if (key == "SearchWindowSize")
            searchWindowSize = rhs[i+1].toInt();
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Mat> srcImgs;
    {
        vector<MxArray> arr(rhs[0].toVector<MxArray>());
        srcImgs.reserve(arr.size());
        for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
            srcImgs.push_back(it->toMat(CV_8U));
    }
    for (vector<Mat>::iterator it = srcImgs.begin(); it != srcImgs.end(); ++it) {
        if (flip && (it->channels() == 3 || it->channels() == 4)) {
            // MATLAB's default is RGB/RGBA while OpenCV's is BGR/BGRA
            cvtColor(*it, *it, (it->channels()==3 ?
                cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
        }
    }
    int imgToDenoiseIndex = rhs[1].toInt();
    int temporalWindowSize = rhs[2].toInt();
    Mat dst;
    fastNlMeansDenoisingColoredMulti(srcImgs, dst, imgToDenoiseIndex,
        temporalWindowSize, h, hColor, templateWindowSize, searchWindowSize);
    if (flip && (dst.channels() == 3 || dst.channels() == 4)) {
        // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
        cvtColor(dst, dst, (dst.channels()==3 ?
            cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
    }
    plhs[0] = MxArray(dst);
}
