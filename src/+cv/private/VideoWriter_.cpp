/**
 * @file VideoWriter_.cpp
 * @brief mex interface for cv::VideoWriter
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
map<int,Ptr<VideoWriter> > obj_;

/// Capture Property map for option processing
const ConstMap<string,int> VidWriterProp = ConstMap<string,int>
    ("Quality",    cv::VIDEOWRITER_PROP_QUALITY)
    ("FrameBytes", cv::VIDEOWRITER_PROP_FRAMEBYTES);

/// Option arguments parser used by constructor and open method
struct OptionsParser
{
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
        : fourcc(CV_FOURCC('U','2','6','3')),  // H263 codec
          fps(25),
          isColor(true)
    {
        nargchk(((last-first) % 2) == 0);
        for (; first != last; first += 2) {
            string key((*first).toString());
            const MxArray& val = *(first + 1);
            if (key == "FourCC") {
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
    };
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
        nargchk(nrhs==2 && nlhs==1);
        obj_[++last_id] = makePtr<VideoWriter>();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<VideoWriter> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "open") {
        nargchk(nrhs>=4 && nlhs<=1);
        string filename(rhs[2].toString());
        Size frameSize(rhs[3].toSize());
        OptionsParser opts(rhs.begin() + 4, rhs.end());
        bool b = obj->open(filename, opts.fourcc, opts.fps, frameSize,
            opts.isColor);
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
        string prop(rhs[2].toString());
        double value = obj->get(VidWriterProp[prop]);
        plhs[0] = MxArray(value);
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        double value = rhs[3].toDouble();
        bool success = obj->set(VidWriterProp[prop], value);
        if (!success)
            mexWarnMsgIdAndTxt("mexopencv:error",
                "Error setting property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
