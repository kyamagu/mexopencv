/**
 * @file drawKeylines.cpp
 * @brief mex interface for cv::line_descriptor::drawKeylines
 * @ingroup line_descriptor
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/line_descriptor.hpp"
using namespace std;
using namespace cv;
using namespace cv::line_descriptor;

namespace {
/** Convert an MxArray to cv::line_descriptor::KeyLine
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return keyline object
 */
KeyLine MxArrayToKeyLine(const MxArray& arr, mwIndex idx = 0)
{
    KeyLine keyline;
    keyline.angle           = arr.at("angle",              idx).toFloat();
    keyline.class_id        = arr.at("class_id",           idx).toInt();
    keyline.octave          = arr.at("octave",             idx).toInt();
    keyline.pt              = arr.at("pt",                 idx).toPoint2f();
    keyline.response        = arr.at("response",           idx).toFloat();
    keyline.size            = arr.at("size",               idx).toFloat();
    keyline.startPointX     = arr.at("startPoint",         idx).toPoint2f().x;
    keyline.startPointY     = arr.at("startPoint",         idx).toPoint2f().y;
    keyline.endPointX       = arr.at("endPoint",           idx).toPoint2f().x;
    keyline.endPointY       = arr.at("endPoint",           idx).toPoint2f().y;
    keyline.sPointInOctaveX = arr.at("startPointInOctave", idx).toPoint2f().x;
    keyline.sPointInOctaveY = arr.at("startPointInOctave", idx).toPoint2f().y;
    keyline.ePointInOctaveX = arr.at("endPointInOctave",   idx).toPoint2f().x;
    keyline.ePointInOctaveY = arr.at("endPointInOctave",   idx).toPoint2f().y;
    keyline.lineLength      = arr.at("lineLength",         idx).toFloat();
    keyline.numOfPixels     = arr.at("numOfPixels",        idx).toInt();
    return keyline;
}

/** Convert an MxArray to std::vector<cv::line_descriptor::KeyLine>
 * @param arr struct-array MxArray object
 * @return vector of keyline objects
 */
vector<KeyLine> MxArrayToVectorKeyLine(const MxArray& arr)
{
    const mwSize n = arr.numel();
    vector<KeyLine> vk;
    vk.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            vk.push_back(MxArrayToKeyLine(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            vk.push_back(MxArrayToKeyLine(arr,i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::line_descriptor::KeyLine>");
    return vk;
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    //TODO: cv::line_descriptor::drawKeylines doesnt parse flags correctly,
    // they are parsed as mutually exclusive!

    // Option processing
    Mat outImage;
    Scalar color(Scalar::all(-1));
    int flags = cv::line_descriptor::DrawLinesMatchesFlags::DEFAULT;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Color")
            color = (rhs[i+1].isChar()) ?
                ColorType[rhs[i+1].toString()] : rhs[i+1].toScalar();
        else if (key == "OutImage") {
            outImage = rhs[i+1].toMat(CV_8U);
            flags |= cv::line_descriptor::DrawLinesMatchesFlags::DRAW_OVER_OUTIMG;
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<KeyLine> keylines(MxArrayToVectorKeyLine(rhs[1]));
    drawKeylines(image, keylines, outImage, color, flags);
    plhs[0] = MxArray(outImage);
}
