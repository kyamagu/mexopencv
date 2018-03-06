/**
 * @file VideoWriter_.cpp
 * @brief mex interface for cv::VideoWriter
 * @ingroup videoio
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/videoio.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<VideoWriter> > obj_;

/// API backends map for option processing
const ConstMap<string,int> ApiPreferenceMap = ConstMap<string,int>
    ("Any",             cv::CAP_ANY)
    ("VfW",             cv::CAP_VFW)
    ("QuickTime",       cv::CAP_QT)
    ("AVFoundation",    cv::CAP_AVFOUNDATION)
    ("MediaFoundation", cv::CAP_MSMF)
    ("GStreamer",       cv::CAP_GSTREAMER)
    ("FFMPEG",          cv::CAP_FFMPEG)
    ("Images",          cv::CAP_IMAGES)
    ("MotionJPEG",      cv::CAP_OPENCV_MJPEG)
    ("MediaSDK",        cv::CAP_INTEL_MFX);

/// Capture Property map for option processing
const ConstMap<string,int> VidWriterProp = ConstMap<string,int>
    ("Quality",    cv::VIDEOWRITER_PROP_QUALITY)
    ("FrameBytes", cv::VIDEOWRITER_PROP_FRAMEBYTES)
    ("NStripes",   cv::VIDEOWRITER_PROP_NSTRIPES)
    ("Images",     cv::CAP_PROP_IMAGES_BASE);

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

/// Option arguments parser used by constructor and open method
struct OptionsParser
{
    /// API preference.
    int apiPreference;
    /// 4-character code of codec used to compress the frames.
    int fourcc;
    /// Framerate of the created video stream.
    double fps;
    /// Flag to indicate whether to expect color or grayscale frames.
    bool isColor;

    /** Parse input arguments.
     * @param first iterator at the beginning of the arguments vector.
     * @param last iterator at the end of the arguments vector.
     */
    OptionsParser(vector<MxArray>::const_iterator first,
                  vector<MxArray>::const_iterator last)
        : apiPreference(cv::CAP_ANY),
          fourcc(CV_FOURCC('M','J','P','G')),
          fps(25),
          isColor(true)
    {
        nargchk((std::distance(first, last) % 2) == 0);
        for (; first != last; first += 2) {
            string key((*first).toString());
            const MxArray& val = *(first + 1);
            if (key == "API")
                apiPreference = ApiPreferenceMap[val.toString()];
            else if (key == "FourCC") {
                if (val.isChar() && val.numel()==4) {
                    string cc(val.toString());
                    fourcc = VideoWriter::fourcc(cc[0], cc[1], cc[2], cc[3]);
                }
                else
                    fourcc = val.toInt();
            }
            else if (key == "FPS")
                fps = val.toDouble();
            else if (key == "Color")
                isColor = val.toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
    }
};

/// Option arguments parser for imwrite options used by set method
struct ImwriteOptionsParser
{
    /// vector of parameters as key/value pairs
    vector<int> params;

    /** Parse input arguments.
     * @param first iterator at the beginning of the arguments vector.
     * @param last iterator at the end of the arguments vector.
     */
    ImwriteOptionsParser(vector<MxArray>::const_iterator first,
                         vector<MxArray>::const_iterator last)
    {
        nargchk((std::distance(first, last) % 2) == 0);
        for (; first != last; first += 2) {
            string key((*first).toString());
            const MxArray& val = *(first + 1);
            if (key == "JpegQuality") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_QUALITY);
                params.push_back(val.toInt());
            }
            else if (key == "JpegProgressive") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_PROGRESSIVE);
                params.push_back(val.toBool() ? 1 : 0);
            }
            else if (key == "JpegOptimize") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_OPTIMIZE);
                params.push_back(val.toBool() ? 1 : 0);
            }
            else if (key == "JpegResetInterval") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_RST_INTERVAL);
                params.push_back(val.toInt());
            }
            else if (key == "JpegLumaQuality") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_LUMA_QUALITY);
                params.push_back(val.toInt());
            }
            else if (key == "JpegChromaQuality") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_JPEG_CHROMA_QUALITY);
                params.push_back(val.toInt());
            }
            else if (key == "PngCompression") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_PNG_COMPRESSION);
                params.push_back(val.toInt());
            }
            else if (key == "PngStrategy") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_PNG_STRATEGY);
                params.push_back(PngStrategyMap[val.toString()]);
            }
            else if (key == "PngBilevel") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_PNG_BILEVEL);
                params.push_back(val.toBool() ? 1 : 0);
            }
            else if (key == "PxmBinary") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_PXM_BINARY);
                params.push_back(val.toBool() ? 1 : 0);
            }
            else if (key == "ExrType") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_EXR_TYPE);
                params.push_back(ExrTypeMap[val.toString()]);
            }
            else if (key == "WebpQuality") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_WEBP_QUALITY);
                params.push_back(val.toInt());
            }
            else if (key == "PamTupleType") {
                params.push_back(cv::CAP_PROP_IMAGES_BASE +
                    cv::IMWRITE_PAM_TUPLETYPE);
                params.push_back(PamFormatMap[val.toString()]);
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
    }
};
}  // anonymous namespace

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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from arguments
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<VideoWriter>();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<VideoWriter> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "open") {
        nargchk(nrhs>=4 && nlhs<=1);
        string filename(rhs[2].toString());
        Size frameSize(rhs[3].toSize());
        OptionsParser opts(rhs.begin() + 4, rhs.end());
        bool b = obj->open(filename, opts.apiPreference,
            opts.fourcc, opts.fps, frameSize, opts.isColor);
        plhs[0] = MxArray(b);
    }
    else if (method == "isOpened") {
        nargchk(nrhs==2 && nlhs<=1);
        bool b = obj->isOpened();
        plhs[0] = MxArray(b);
    }
    else if (method == "release") {
        nargchk(nrhs==2 && nlhs==0);
        obj->release();
    }
    else if (method == "write") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        bool flip = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat frame(rhs[2].toMat());
        if (flip && frame.channels() == 3)
            cvtColor(frame, frame, cv::COLOR_RGB2BGR);
        obj->write(frame);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        int propId = (rhs[2].isChar()) ?
            VidWriterProp[rhs[2].toString()] : rhs[2].toInt();
        double value = obj->get(propId);
        plhs[0] = MxArray(value);
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        int propId = (rhs[2].isChar()) ?
            VidWriterProp[rhs[2].toString()] : rhs[2].toInt();
        if (propId == cv::CAP_PROP_IMAGES_BASE) {
            vector<MxArray> args(rhs[3].toVector<MxArray>());
            ImwriteOptionsParser opts(args.begin(), args.end());
            nargchk((opts.params.size() % 2) == 0);
            for (size_t i = 0; i < opts.params.size(); i+=2) {
                bool success = obj->set(opts.params[i], opts.params[i+1]);
                if (!success)
                    mexWarnMsgIdAndTxt("mexopencv:error",
                        "Error setting property %d", opts.params[i]);
            }
        }
        else {
            double value = rhs[3].toDouble();
            bool success = obj->set(propId, value);
            if (!success)
                mexWarnMsgIdAndTxt("mexopencv:error",
                    "Error setting property %d", propId);
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
