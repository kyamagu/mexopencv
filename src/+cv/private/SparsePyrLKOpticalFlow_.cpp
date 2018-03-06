/**
 * @file SparsePyrLKOpticalFlow_.cpp
 * @brief mex interface for cv::SparsePyrLKOpticalFlow
 * @ingroup video
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/video.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<SparsePyrLKOpticalFlow> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // constructor call
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = SparsePyrLKOpticalFlow::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SparsePyrLKOpticalFlow> obj = obj_[id];
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
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)!=0 && nlhs==0);
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
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<SparsePyrLKOpticalFlow>(rhs[2].toString(), objname) :
            Algorithm::load<SparsePyrLKOpticalFlow>(rhs[2].toString(), objname));
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "calc") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=3);
        vector<Point2f> nextPts;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "InitialFlow")
                nextPts = rhs[i+1].toVector<Point2f>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat prevImg(rhs[2].toMat(CV_8U)),
            nextImg(rhs[3].toMat(CV_8U));
        vector<Point2f> prevPts(rhs[4].toVector<Point2f>());
        Mat status, err;
        obj->calc(prevImg, nextImg, prevPts, nextPts, status,
            (nlhs>2 ? err : noArray()));
        plhs[0] = MxArray(nextPts);
        if (nlhs>1)
            plhs[1] = MxArray(status);
        if (nlhs>2)
            plhs[2] = MxArray(err);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "WinSize")
            plhs[0] = MxArray(obj->getWinSize());
        else if (prop == "MaxLevel")
            plhs[0] = MxArray(obj->getMaxLevel());
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else if (prop == "Flags")
            plhs[0] = MxArray(obj->getFlags());
        else if (prop == "MinEigThreshold")
            plhs[0] = MxArray(obj->getMinEigThreshold());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "WinSize")
            obj->setWinSize(rhs[3].toSize());
        else if (prop == "MaxLevel")
            obj->setMaxLevel(rhs[3].toInt());
        else if (prop == "TermCriteria") {
            //HACK: method defined as: setTermCriteria(TermCriteria& crit)
            // rvalue should be passed either by-value or by-const-ref
            // (GCC complains when rvalue is passed by-non-const-ref)
            TermCriteria tc(rhs[3].toTermCriteria());
            obj->setTermCriteria(tc);
        }
        else if (prop == "Flags")  //TODO: expose props for flag values
            obj->setFlags(rhs[3].toInt());
        else if (prop == "MinEigThreshold")
            obj->setMinEigThreshold(rhs[3].toDouble());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
