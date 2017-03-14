/**
 * @file AdaptiveManifoldFilter_.cpp
 * @brief mex interface for cv::ximgproc::AdaptiveManifoldFilter
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
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
map<int,Ptr<AdaptiveManifoldFilter> > obj_;

/// Option arguments parser used by create and filter methods
struct OptionsParser
{
    double sigma_s;
    double sigma_r;
    bool adjust_outliers;

    /** Parse input arguments.
     * @param first iterator at the beginning of the arguments vector.
     * @param last iterator at the end of the arguments vector.
     */
    OptionsParser(vector<MxArray>::const_iterator first,
                  vector<MxArray>::const_iterator last)
        : sigma_s(16.0),
          sigma_r(0.2),
          adjust_outliers(false)
    {
        ptrdiff_t len = std::distance(first, last);
        nargchk((len%2)==0);
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "SigmaS")
                sigma_s = val.toDouble();
            else if (key == "SigmaR")
                sigma_r = val.toDouble();
            else if (key == "AdjustOutliers")
                adjust_outliers = val.toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
    }
};
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
        nargchk(nrhs>=2 && nlhs<=1);
        OptionsParser opts(rhs.begin() + 2, rhs.end());
        obj_[++last_id] = createAMFilter(
            opts.sigma_s, opts.sigma_r, opts.adjust_outliers);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "amFilter") {
        nargchk(nrhs>=4 && nlhs<=1);
        Mat src(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F)),
            joint(rhs[3].toMat(rhs[3].isUint8() ? CV_8U :
                (rhs[3].isUint16() ? CV_16U : CV_32F))),
            dst;
        OptionsParser opts(rhs.begin() + 4, rhs.end());
        amFilter(joint, src, dst,
            opts.sigma_s, opts.sigma_r, opts.adjust_outliers);
        plhs[0] = MxArray(dst);
        return;
    }

    // Big operation switch
    Ptr<AdaptiveManifoldFilter> obj = obj_[id];
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
            Algorithm::loadFromString<AdaptiveManifoldFilter>(rhs[2].toString(), objname) :
            Algorithm::load<AdaptiveManifoldFilter>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing AdaptiveManifoldFilter::create()
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
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    else if (method == "filter") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        Mat src(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F)),
            joint, dst;
        if (nrhs == 4)
            joint = rhs[3].toMat(rhs[3].isUint8() ? CV_8U :
                (rhs[3].isUint16() ? CV_16U : CV_32F));
        obj->filter(src, dst, (nrhs==4 ? joint : noArray()));
        plhs[0] = MxArray(dst);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "SigmaS")
            plhs[0] = MxArray(obj->getSigmaS());
        else if (prop == "SigmaR")
            plhs[0] = MxArray(obj->getSigmaR());
        else if (prop == "TreeHeight")
            plhs[0] = MxArray(obj->getTreeHeight());
        else if (prop == "PCAIterations")
            plhs[0] = MxArray(obj->getPCAIterations());
        else if (prop == "AdjustOutliers")
            plhs[0] = MxArray(obj->getAdjustOutliers());
        else if (prop == "UseRNG")
            plhs[0] = MxArray(obj->getUseRNG());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "SigmaS")
            obj->setSigmaS(rhs[3].toDouble());
        else if (prop == "SigmaR")
            obj->setSigmaR(rhs[3].toDouble());
        else if (prop == "TreeHeight")
            obj->setTreeHeight(rhs[3].toInt());
        else if (prop == "PCAIterations")
            obj->setPCAIterations(rhs[3].toInt());
        else if (prop == "AdjustOutliers")
            obj->setAdjustOutliers(rhs[3].toBool());
        else if (prop == "UseRNG")
            obj->setUseRNG(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
