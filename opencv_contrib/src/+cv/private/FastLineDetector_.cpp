/**
 * @file FastLineDetector_.cpp
 * @brief mex interface for cv::ximgproc::FastLineDetector
 * @ingroup ximgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<FastLineDetector> > obj_;
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int length_threshold = 10;
        float distance_threshold = 1.414213562f;
        double canny_th1 = 50.0;
        double canny_th2 = 50.0;
        int canny_aperture_size = 3;
        bool do_merge = false;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "LengthThreshold")
                length_threshold = rhs[i+1].toInt();
            else if (key == "DistanceThreshold")
                distance_threshold = rhs[i+1].toFloat();
            else if (key == "CannyThreshold1")
                canny_th1 = rhs[i+1].toDouble();
            else if (key == "CannyThreshold2")
                canny_th2 = rhs[i+1].toDouble();
            else if (key == "CannyApertureSize")
                canny_aperture_size = rhs[i+1].toInt();
            else if (key == "DoMerge")
                do_merge = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createFastLineDetector(
            length_threshold, distance_threshold, canny_th1, canny_th2,
            canny_aperture_size, do_merge);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<FastLineDetector> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<FastLineDetector>(rhs[2].toString(), objname) :
            Algorithm::load<FastLineDetector>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing FastLineDetector::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "detect") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat image(rhs[2].toMat(CV_8U));
        vector<Vec4f> lines;
        obj->detect(image, lines);
        plhs[0] = MxArray(lines);
    }
    else if (method == "drawSegments") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        bool draw_arrow = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "DrawArrow")
                draw_arrow = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat());
        //vector<Vec4f> lines(MxArrayToVectorVec<float,4>(rhs[3]));
        vector<Vec4f> lines(rhs[3].toVector<Vec4f>());
        obj->drawSegments(image, lines, draw_arrow);
        plhs[0] = MxArray(image);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
