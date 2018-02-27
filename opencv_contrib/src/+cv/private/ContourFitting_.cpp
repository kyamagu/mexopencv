/**
 * @file ContourFitting_.cpp
 * @brief mex interface for cv::ximgproc::ContourFitting
 * @ingroup ximgproc
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ContourFitting> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int ctr = 1024;
        int fd = 16;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "CtrSize")
                ctr = rhs[i+1].toInt();
            else if (key == "FDSize")
                fd = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createContourFitting(ctr, fd);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "contourSampling") {
        nargchk(nrhs==4 && nlhs<=1);
        int nbElt = rhs[3].toInt();
        if (rhs[2].isCell()) {
            vector<Point2f> src(rhs[2].toVector<Point2f>()), out;
            contourSampling(src, out, nbElt);
            plhs[0] = MxArray(out);
        }
        else {
            Mat src(rhs[2].toMat(CV_32F)), out;
            bool cn1 = (src.channels() == 1);
            if (cn1) src = src.reshape(2,0);
            contourSampling(src, out, nbElt);
            if (cn1) out = out.reshape(1,0);
            plhs[0] = MxArray(out);
        }
        return;
    }
    else if (method == "fourierDescriptor") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int nbElt = -1;
        int nbFD = -1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "NumElt")
                nbElt = rhs[i+1].toInt();
            else if (key == "NumFD")
                nbFD = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat dst;
        if (rhs[2].isCell()) {
            vector<Point2f> src(rhs[2].toVector<Point2f>());
            fourierDescriptor(src, dst, nbElt, nbFD);
        }
        else {
            Mat src(rhs[2].toMat(CV_32F).reshape(2,0));
            fourierDescriptor(src, dst, nbElt, nbFD);
        }
        plhs[0] = MxArray(dst);
        return;
    }
    else if (method == "transformFD") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        bool fdContour = true;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FD")
                fdContour = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat t(rhs[3].toMat(CV_64F));
        if (!fdContour) {
            vector<Point2f> src(rhs[2].toVector<Point2f>()), dst;
            transformFD(src, t, dst, fdContour);
            plhs[0] = MxArray(dst);
        }
        else {
            Mat src(rhs[2].toMat(CV_32F)), dst;
            bool cn1 = (src.channels() == 1);
            if (cn1) src = src.reshape(2,0);
            transformFD(src, t, dst, fdContour);
            if (cn1) dst = dst.reshape(1,0);
            plhs[0] = MxArray(dst);
        }
        return;
    }

    // Big operation switch
    Ptr<ContourFitting> obj = obj_[id];
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
            Algorithm::loadFromString<ContourFitting>(rhs[2].toString(), objname) :
            Algorithm::load<ContourFitting>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing ContourFitting::create()
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
    else if (method == "estimateTransformation") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        bool fdContour = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FD")
                fdContour = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat alphaPhiST;
        double dist = 0;
        if (!fdContour) {
            vector<Point2f> src(rhs[2].toVector<Point2f>()),
                            ref(rhs[3].toVector<Point2f>());
            obj->estimateTransformation(src, ref, alphaPhiST, dist, fdContour);
        }
        else {
            Mat src(rhs[2].toMat(CV_32F).reshape(2,0)),
                ref(rhs[3].toMat(CV_32F).reshape(2,0));
            obj->estimateTransformation(src, ref, alphaPhiST, dist, fdContour);
        }
        plhs[0] = MxArray(alphaPhiST);
        if (nlhs > 1)
            plhs[1] = MxArray(dist);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "CtrSize")
            plhs[0] = MxArray(obj->getCtrSize());
        else if (prop == "FDSize")
            plhs[0] = MxArray(obj->getFDSize());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "CtrSize")
            obj->setCtrSize(rhs[3].toInt());
        else if (prop == "FDSize")
            obj->setFDSize(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
