/**
 * @file imencode.cpp
 * @brief mex interface for cv::imencode
 * @ingroup imgcodecs
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
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
            int val = rhs[i+1].toInt();
            if (val < 0 || 100 < val)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "JPEG quality parameter must be in the range [0,100]");
            params.push_back(cv::IMWRITE_JPEG_QUALITY);
            params.push_back(val);
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
            int val = rhs[i+1].toInt();
            if (val < 0 || 65535 < val)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "JPEG restart interval must be in the range [0,65535]");
            params.push_back(cv::IMWRITE_JPEG_RST_INTERVAL);
            params.push_back(val);
        }
        else if (key == "JpegLumaQuality") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 100 < val)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "JPEG luma quality level must be in the range [0,100]");
            params.push_back(cv::IMWRITE_JPEG_LUMA_QUALITY);
            params.push_back(val);
        }
        else if (key == "JpegChromaQuality") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 100 < val)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "JPEG chroma quality level must be in the range [0,100]");
            params.push_back(cv::IMWRITE_JPEG_CHROMA_QUALITY);
            params.push_back(val);
        }
        else if (key == "PngCompression") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 9 < val)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "PNG compression level must be in the range [0,9]");
            params.push_back(cv::IMWRITE_PNG_COMPRESSION);
            params.push_back(val);
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
        else if (key == "WebpQuality") {
            int val = rhs[i+1].toInt();
            if (val < 1 /*|| 100 < val*/)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "WEBP quality must be in the range [0,100]");
            params.push_back(cv::IMWRITE_WEBP_QUALITY);
            params.push_back(val);
        }
        else if (key == "Params") {
            // append to parameters by directly passing a vector of integers
            vector<int> pvec = rhs[i+1].toVector<int>();
            if ((pvec.size()%2) != 0)
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Params vectors must contain pairs of id/value.");
            params.insert(params.end(), pvec.begin(), pvec.end());
        }
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    string ext(rhs[0].toString());
    Mat img(rhs[1].toMat(rhs[1].isFloat() ? CV_32F :
        (rhs[1].isUint16() ? CV_16U : CV_8U)));
    if (flip && (img.channels() == 3 || img.channels() == 4)) {
        // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
        cvtColor(img, img, (img.channels()==3 ?
            cv::COLOR_RGB2BGR : cv::COLOR_RGBA2BGRA));
    }
    vector<uchar> buf;
    bool success = imencode(ext, img, buf, params);
    if (!success)
        mexErrMsgIdAndTxt("mexopencv:error", "imencode failed");
    plhs[0] = MxArray(Mat(buf), mxUINT8_CLASS, false);
}
