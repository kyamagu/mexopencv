/**
 * @file imwrite.cpp
 * @brief mex interface for cv::imwrite
 * @ingroup imgcodecs
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/imgcodecs.hpp"
using namespace std;
using namespace cv;

namespace {
/// PNG encoding strategies for option processing
const ConstMap<string,int> PngStrategyMap = ConstMap<string,int>
    ("Default",     cv::IMWRITE_PNG_STRATEGY_DEFAULT)
    ("Filtered",    cv::IMWRITE_PNG_STRATEGY_FILTERED)
    ("HuffmanOnly", cv::IMWRITE_PNG_STRATEGY_HUFFMAN_ONLY)
    ("RLE",         cv::IMWRITE_PNG_STRATEGY_RLE)
    ("Fixed",       cv::IMWRITE_PNG_STRATEGY_FIXED);

/// EXR storage types for option processing
const ConstMap<string,int> ExrTypeMap = ConstMap<string,int>
    //("Int",   cv::IMWRITE_EXR_TYPE_UNIT)
    ("Half",  cv::IMWRITE_EXR_TYPE_HALF)
    ("Float", cv::IMWRITE_EXR_TYPE_FLOAT);

/// PAM tuple types for option processing
const ConstMap<string,int> PamFormatMap = ConstMap<string,int>
    ("Null",           cv::IMWRITE_PAM_FORMAT_NULL)
    ("BlackWhite",     cv::IMWRITE_PAM_FORMAT_BLACKANDWHITE)
    ("Grayscale",      cv::IMWRITE_PAM_FORMAT_GRAYSCALE)
    ("GrayscaleAlpha", cv::IMWRITE_PAM_FORMAT_GRAYSCALE_ALPHA)
    ("RGB",            cv::IMWRITE_PAM_FORMAT_RGB)
    ("RGBA",           cv::IMWRITE_PAM_FORMAT_RGB_ALPHA);
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

    // Option processing
    vector<int> params;
    bool flip = true;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "JpegQuality") {
            params.push_back(cv::IMWRITE_JPEG_QUALITY);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "JpegProgressive") {
            params.push_back(cv::IMWRITE_JPEG_PROGRESSIVE);
            params.push_back(rhs[i+1].toBool() ? 1 : 0);
        }
        else if (key == "JpegOptimize") {
            params.push_back(cv::IMWRITE_JPEG_OPTIMIZE);
            params.push_back(rhs[i+1].toBool() ? 1 : 0);
        }
        else if (key == "JpegResetInterval") {
            params.push_back(cv::IMWRITE_JPEG_RST_INTERVAL);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "JpegLumaQuality") {
            params.push_back(cv::IMWRITE_JPEG_LUMA_QUALITY);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "JpegChromaQuality") {
            params.push_back(cv::IMWRITE_JPEG_CHROMA_QUALITY);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "PngCompression") {
            params.push_back(cv::IMWRITE_PNG_COMPRESSION);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "PngStrategy") {
            params.push_back(cv::IMWRITE_PNG_STRATEGY);
            params.push_back(PngStrategyMap[rhs[i+1].toString()]);
        }
        else if (key == "PngBilevel") {
            params.push_back(cv::IMWRITE_PNG_BILEVEL);
            params.push_back(rhs[i+1].toBool() ? 1 : 0);
        }
        else if (key == "PxmBinary") {
            params.push_back(cv::IMWRITE_PXM_BINARY);
            params.push_back(rhs[i+1].toBool() ? 1 : 0);
        }
        else if (key == "ExrType") {
            params.push_back(cv::IMWRITE_EXR_TYPE);
            params.push_back(ExrTypeMap[rhs[i+1].toString()]);
        }
        else if (key == "WebpQuality") {
            params.push_back(cv::IMWRITE_WEBP_QUALITY);
            params.push_back(rhs[i+1].toInt());
        }
        else if (key == "PamTupleType") {
            params.push_back(cv::IMWRITE_PAM_TUPLETYPE);
            params.push_back(PamFormatMap[rhs[i+1].toString()]);
        }
        else if (key == "Params") {
            // append to parameters by directly passing a vector of integers
            vector<int> pvec(rhs[i+1].toVector<int>());
            if ((pvec.size()%2) != 0)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Params vectors must contain pairs of id/value.");
            params.insert(params.end(), pvec.begin(), pvec.end());
        }
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    string filename(rhs[0].toString());
    bool success;
    if (rhs[1].isNumeric()) {
        Mat img(rhs[1].toMat(rhs[1].isFloat() ? CV_32F :
            (rhs[1].isUint16() ? CV_16U : CV_8U)));
        if (flip && (img.channels() == 3 || img.channels() == 4)) {
            // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
            cvtColor(img, img, (img.channels()==3 ?
                cv::COLOR_RGB2BGR : cv::COLOR_RGBA2BGRA));
        }
        success = imwrite(filename, img, params);
    }
    else if (rhs[1].isCell()) {
        //vector<Mat> img_vec(rhs[1].toVector<Mat>());
        vector<MxArray> vec(rhs[1].toVector<MxArray>());
        vector<Mat> img_vec;
        img_vec.reserve(vec.size());
        for (vector<MxArray>::const_iterator it = vec.begin(); it != vec.end(); ++it) {
            Mat img(it->toMat(it->isFloat() ? CV_32F :
                (it->isUint16() ? CV_16U : CV_8U)));
            if (flip && (img.channels() == 3 || img.channels() == 4)) {
                // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
                cvtColor(img, img, (img.channels()==3 ?
                    cv::COLOR_RGB2BGR : cv::COLOR_RGBA2BGRA));
            }
            img_vec.push_back(img);
        }
        success = imwrite(filename, img_vec, params);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid image argument");
    if (nlhs > 0)
        plhs[0] = MxArray(success);
    else if (!success)
        mexErrMsgIdAndTxt("mexopencv:error", "imwrite failed");
}
