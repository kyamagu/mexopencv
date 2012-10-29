/**
 * @file VideoWriter_.cpp
 * @brief mex interface for VideoWriter_
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
map<int,VideoWriter> obj_;

// Local scope
namespace {
/// Option argument parser for constructor and open()
class open_options {
public:
    int fourcc;
    double fps;
    bool isColor;
    open_options(vector<MxArray>::iterator first,
                 vector<MxArray>::iterator last) :
        fourcc(CV_FOURCC('U','2','6','3')),  // H263 codec
        fps(25),
        isColor(true)
    {
        if (((last-first)%2)!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        for (; first < last; first+=2) {
            string key((*first).toString());
            MxArray& val = *(first+1);
            if (key=="fourcc") {
                if (val.isChar()) {                    
                    string x(val.toString());
                    fourcc = CV_FOURCC(x[0],x[1],x[2],x[3]);
                }
                else {
                    fourcc = val.toInt();
                }
            }
            else if (key=="FPS")
                fps = val.toDouble();
            else if (key=="Color")
                isColor = val.toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
    };
};
}


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
    if (rhs[0].isChar() && nrhs>=2) {
        // Constructor is called. Create a new object from argument
        string filename(rhs[0].toString());
        Size frameSize(rhs[1].toSize());
        open_options opts(rhs.begin()+2,rhs.end());
        obj_[++last_id] = VideoWriter(filename, opts.fourcc, opts.fps, frameSize, opts.isColor);
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
    VideoWriter& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "open") {
        if (nrhs<4)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string filename(rhs[2].toString());
        Size frameSize(rhs[3].toSize());
        open_options opts(rhs.begin()+4,rhs.end());
        bool b = obj.open(filename, opts.fourcc, opts.fps, frameSize, opts.isColor);
        plhs[0] = MxArray(b);
    }
    else if (method == "isOpened") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.isOpened());
    }
    else if (method == "write") {
        if (nrhs!=3 || nlhs>0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat frame(rhs[2].toMat());
        if (frame.type()==CV_8UC3)
            cvtColor(frame,frame,CV_RGB2BGR);
        obj.write(frame);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
