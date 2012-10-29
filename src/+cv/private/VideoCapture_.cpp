/**
 * @file VideoCapture_.cpp
 * @brief mex interface for VideoCapture_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,VideoCapture> obj_;

/** Capture Property map for option processing
 */
const ConstMap<std::string,int> CapProp = ConstMap<std::string,int>
    ("PosMsec",CV_CAP_PROP_POS_MSEC)  // Current position of the video file in milliseconds or video capture timestamp.
    ("PosFrames",CV_CAP_PROP_POS_FRAMES)  // 0-based index of the frame to be decoded/captured next.
    ("AVIRatio",CV_CAP_PROP_POS_AVI_RATIO)  // Relative position of the video file: 0 - start of the film, 1 - end of the film.
    ("FrameWidth",CV_CAP_PROP_FRAME_WIDTH)  // Width of the frames in the video stream.
    ("FrameHeight",CV_CAP_PROP_FRAME_HEIGHT)  // Height of the frames in the video stream.
    ("FPS",CV_CAP_PROP_FPS)  // Frame rate.
    ("FourCC",CV_CAP_PROP_FOURCC)  // 4-character code of codec.
    ("FrameCount",CV_CAP_PROP_FRAME_COUNT)  // Number of frames in the video file.
    ("Format",CV_CAP_PROP_FORMAT)  // Format of the Mat objects returned by retrieve() .
    ("Mode",CV_CAP_PROP_MODE)  // Backend-specific value indicating the current capture mode.
    ("Brightness",CV_CAP_PROP_BRIGHTNESS)  // Brightness of the image (only for cameras).
    ("Contrast",CV_CAP_PROP_CONTRAST)  // Contrast of the image (only for cameras).
    ("Saturation",CV_CAP_PROP_SATURATION)  // Saturation of the image (only for cameras).
    ("Hue",CV_CAP_PROP_HUE)  // Hue of the image (only for cameras).
    ("Gain",CV_CAP_PROP_GAIN)  // Gain of the image (only for cameras).
    ("Exposure",CV_CAP_PROP_EXPOSURE)  // Exposure (only for cameras).
    ("ConvertRGB",CV_CAP_PROP_CONVERT_RGB)  // Boolean flags indicating whether images should be converted to RGB.
    //("WhiteBalance",CV_CAP_PROP_WHITE_BALANCE)  // Currently not supported
    ("Rectification",CV_CAP_PROP_RECTIFICATION)  // Rectification flag for stereo cameras (note: only supported by DC1394 v 2.x backend currently)
;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    if (nrhs<1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (nrhs==1) {
        // Constructor is called. Create a new object from argument
        obj_[++last_id] = (rhs[0].isChar()) ? 
            VideoCapture(rhs[0].toString()) : VideoCapture(rhs[0].toInt());
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Big operation switch
    VideoCapture& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "open") {
        if (nrhs!=3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        bool b = (rhs[2].isChar()) ?
            obj.open(rhs[2].toString()) : obj.open(rhs[2].toInt());
        plhs[0] = MxArray(b);
    }
    else if (method == "isOpened") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.isOpened());
    }
    else if (method == "release") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj.release();
    }
    else if (method == "grab") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.grab());
    }
    else if (method == "retrieve") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat frame;
        if (obj.retrieve(frame)) {
            if (frame.type()==CV_8UC3)
                cvtColor(frame,frame,CV_BGR2RGB);
            plhs[0] = MxArray(frame);
        }
        else
            plhs[0] = MxArray(mxCreateNumericMatrix(0,0,mxUINT8_CLASS,mxREAL));
    }
    else if (method == "read") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat frame;
        if (obj.read(frame)) {
            if (frame.type()==CV_8UC3)
                cvtColor(frame,frame,CV_BGR2RGB);
            plhs[0] = MxArray(frame);
        }
        else
            plhs[0] = MxArray(mxCreateNumericMatrix(0,0,mxUINT8_CLASS,mxREAL));
    }
    else if (method == "get") {
        if (nrhs!=3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get(CapProp[rhs[2].toString()]));
    }
    else if (method == "set") {
        if (nrhs!=4)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.set(CapProp[rhs[2].toString()],rhs[3].toDouble()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
