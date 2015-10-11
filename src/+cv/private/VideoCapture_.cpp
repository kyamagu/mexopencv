/**
 * @file VideoCapture_.cpp
 * @brief mex interface for cv::VideoCapture
 * @ingroup videoio
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
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
    //("WhiteBalance",  cv::CAP_PROP_WHITE_BALANCE)
    ("Rectification", cv::CAP_PROP_RECTIFICATION);
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
        nargchk(nrhs==3 && nlhs<=1);
        obj_[++last_id] = (rhs[2].isChar()) ?
            makePtr<VideoCapture>(rhs[2].toString()) :
            makePtr<VideoCapture>(rhs[2].toInt());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<VideoCapture> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "open") {
        nargchk(nrhs==3 && nlhs<=1);
        bool b = (rhs[2].isChar()) ?
            obj->open(rhs[2].toString()) :
            obj->open(rhs[2].toInt());
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
        string prop(rhs[2].toString());
        double value = obj->get(CapProp[prop]);
        plhs[0] = MxArray(value);
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        double value = rhs[3].toDouble();
        bool success = obj->set(CapProp[prop], value);
        if (!success)
            mexWarnMsgIdAndTxt("mexopencv:error",
                "Error setting property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
