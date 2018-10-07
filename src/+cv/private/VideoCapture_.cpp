/**
 * @file VideoCapture_.cpp
 * @brief mex interface for cv::VideoCapture
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
map<int,Ptr<VideoCapture> > obj_;

/// Capture Property map for option processing
const ConstMap<string,int> CapProp = ConstMap<string,int>
    ("PosMsec",       cv::CAP_PROP_POS_MSEC)
    ("PosFrames",     cv::CAP_PROP_POS_FRAMES)
    ("PosAviRatio",   cv::CAP_PROP_POS_AVI_RATIO)
    ("FrameWidth",    cv::CAP_PROP_FRAME_WIDTH)
    ("FrameHeight",   cv::CAP_PROP_FRAME_HEIGHT)
    ("FPS",           cv::CAP_PROP_FPS)
    ("FourCC",        cv::CAP_PROP_FOURCC)
    ("FrameCount",    cv::CAP_PROP_FRAME_COUNT)
    ("Format",        cv::CAP_PROP_FORMAT)
    ("Mode",          cv::CAP_PROP_MODE)
    ("Brightness",    cv::CAP_PROP_BRIGHTNESS)
    ("Contrast",      cv::CAP_PROP_CONTRAST)
    ("Saturation",    cv::CAP_PROP_SATURATION)
    ("Hue",           cv::CAP_PROP_HUE)
    ("Gain",          cv::CAP_PROP_GAIN)
    ("Exposure",      cv::CAP_PROP_EXPOSURE)
    ("ConvertRGB",    cv::CAP_PROP_CONVERT_RGB)
    //("WhiteBalanceBlue",  cv::CAP_PROP_WHITE_BALANCE_BLUE_U)
    ("Rectification", cv::CAP_PROP_RECTIFICATION)
    //TODO: other undocumented properties
    ("Monochrome",    cv::CAP_PROP_MONOCHROME)
    ("Sharpness",     cv::CAP_PROP_SHARPNESS)
    ("AutoExposure",  cv::CAP_PROP_AUTO_EXPOSURE)
    ("Gamma",         cv::CAP_PROP_GAMMA)
    ("Temperature",   cv::CAP_PROP_TEMPERATURE)
    ("Trigger",       cv::CAP_PROP_TRIGGER)
    ("TriggerDelay",  cv::CAP_PROP_TRIGGER_DELAY)
    //("WhiteBalanceRed",  cv::CAP_PROP_WHITE_BALANCE_RED_V)
    ("Zoom",          cv::CAP_PROP_ZOOM)
    ("Focus",         cv::CAP_PROP_FOCUS)
    ("GUID",          cv::CAP_PROP_GUID)
    ("ISOSpeed",      cv::CAP_PROP_ISO_SPEED)
    ("Backlight",     cv::CAP_PROP_BACKLIGHT)
    ("Pan",           cv::CAP_PROP_PAN)
    ("Tilt",          cv::CAP_PROP_TILT)
    ("Roll",          cv::CAP_PROP_ROLL)
    ("Iris",          cv::CAP_PROP_IRIS)
    ("Settings",      cv::CAP_PROP_SETTINGS)
    ("Buffersize",    cv::CAP_PROP_BUFFERSIZE)
    ("Autofocus",     cv::CAP_PROP_AUTOFOCUS)
    ("SARNum",        cv::CAP_PROP_SAR_NUM)
    ("SARDen",        cv::CAP_PROP_SAR_DEN);

/// Camera API map for option processing
const ConstMap<string,int> CameraApiMap = ConstMap<string,int>
    ("Any",             cv::CAP_ANY)
    ("VfW",             cv::CAP_VFW)
    ("V4L",             cv::CAP_V4L)
    ("V4L2",            cv::CAP_V4L2)
    ("FireWire",        cv::CAP_FIREWIRE)
    ("FireWare",        cv::CAP_FIREWARE)
    ("IEEE1394",        cv::CAP_IEEE1394)
    ("DC1394",          cv::CAP_DC1394)
    ("CMU1394",         cv::CAP_CMU1394)
    ("QuickTime",       cv::CAP_QT)
    ("Unicap",          cv::CAP_UNICAP)
    ("DirectShow",      cv::CAP_DSHOW)
    ("PvAPI",           cv::CAP_PVAPI)
    ("OpenNI",          cv::CAP_OPENNI)
    ("OpenNIAsus",      cv::CAP_OPENNI_ASUS)
    ("Android",         cv::CAP_ANDROID)
    ("XIMEA",           cv::CAP_XIAPI)
    ("AVFoundation",    cv::CAP_AVFOUNDATION)
    ("Giganetix",       cv::CAP_GIGANETIX)
    ("MediaFoundation", cv::CAP_MSMF)
    ("WinRT",           cv::CAP_WINRT)
    ("IntelPerC",       cv::CAP_INTELPERC)
    ("OpenNI2",         cv::CAP_OPENNI2)
    ("OpenNI2Asus",     cv::CAP_OPENNI2_ASUS)
    ("gPhoto2",         cv::CAP_GPHOTO2)
    ("GStreamer",       cv::CAP_GSTREAMER)
    ("FFMPEG",          cv::CAP_FFMPEG)
    ("Images",          cv::CAP_IMAGES)
    ("Aravis",          cv::CAP_ARAVIS)
    ("MotionJPEG",      cv::CAP_OPENCV_MJPEG)
    ("MediaSDK",        cv::CAP_INTEL_MFX);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from arguments
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<VideoCapture>();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<VideoCapture> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "open") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int pref = cv::CAP_ANY;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "API")
                pref = CameraApiMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        // index should be within 0-99, and pref is multiples of 100
        bool b = (rhs[2].isChar()) ?
            obj->open(rhs[2].toString(), pref) :
            obj->open(rhs[2].toInt() + pref);
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
    else if (method == "grab") {
        nargchk(nrhs==2 && nlhs<=1);
        bool b = obj->grab();
        plhs[0] = MxArray(b);
    }
    else if (method == "retrieve") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int idx = 0;
        bool flip = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else if (key == "StreamIdx")
                idx = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image;
        bool b = obj->retrieve(image, idx);
        if (b && flip && image.channels()==3)
            cvtColor(image, image, cv::COLOR_BGR2RGB);
        plhs[0] = MxArray(b ? image : Mat());
    }
    else if (method == "read") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        bool flip = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image;
        bool b = obj->read(image);
        if (b && flip && image.channels()==3)
            cvtColor(image, image, cv::COLOR_BGR2RGB);
        plhs[0] = MxArray(b ? image : Mat());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        int propId = (rhs[2].isChar()) ?
            CapProp[rhs[2].toString()] : rhs[2].toInt();
        double value = obj->get(propId);
        plhs[0] = MxArray(value);
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        int propId = (rhs[2].isChar()) ?
            CapProp[rhs[2].toString()] : rhs[2].toInt();
        double value = rhs[3].toDouble();
        bool success = obj->set(propId, value);
        if (!success)
            mexWarnMsgIdAndTxt("mexopencv:error",
                "Error setting property %d", propId);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
