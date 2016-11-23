/**
 * @file drawLineMatches.cpp
 * @brief mex interface for cv::line_descriptor::drawLineMatches
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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    //TODO: cv::line_descriptor::drawLineMatches doesnt parse flags correctly,
    // they are parsed as mutually exclusive!

    // Option processing
    Mat outImg;
    Scalar matchColor(Scalar::all(-1));
    Scalar singleLineColor(Scalar::all(-1));
    vector<char> matchesMask;
    int flags = cv::line_descriptor::DrawLinesMatchesFlags::DEFAULT;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MatchColor")
            matchColor = (rhs[i+1].isChar()) ?
                ColorType[rhs[i+1].toString()] : rhs[i+1].toScalar();
        else if (key == "SingleLineColor")
            singleLineColor = (rhs[i+1].isChar()) ?
                ColorType[rhs[i+1].toString()] : rhs[i+1].toScalar();
        else if (key == "MatchesMask")
            rhs[i+1].toMat(CV_8S).reshape(1,1).copyTo(matchesMask);
        else if (key == "NotDrawSingleLines")
            UPDATE_FLAG(flags, rhs[i+1].toBool(),
                cv::line_descriptor::DrawLinesMatchesFlags::NOT_DRAW_SINGLE_LINES);
        else if (key == "OutImage") {
            outImg = rhs[i+1].toMat(CV_8U);
            flags |= cv::line_descriptor::DrawLinesMatchesFlags::DRAW_OVER_OUTIMG;
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img1(rhs[0].toMat(CV_8U)),
        img2(rhs[2].toMat(CV_8U));
    vector<KeyLine> keylines1(MxArrayToVectorKeyLine(rhs[1])),
                    keylines2(MxArrayToVectorKeyLine(rhs[3]));
    vector<DMatch> matches1to2(rhs[4].toVector<DMatch>());
    //HACK: drawLineMatches does not check size of mask, so we do it
    //HACK: also it doesnt like its default value!
    if (matchesMask.empty())
        matchesMask.assign(matches1to2.size(), 1);
    else if (matchesMask.size() != matches1to2.size())
        mexErrMsgIdAndTxt("mexopencv:error", "Incorrect mask size");
    drawLineMatches(img1, keylines1, img2, keylines2, matches1to2, outImg,
        matchColor, singleLineColor, matchesMask, flags);
    plhs[0] = MxArray(outImg);
}
