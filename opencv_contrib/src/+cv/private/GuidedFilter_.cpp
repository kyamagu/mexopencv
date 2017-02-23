/**
 * @file GuidedFilter_.cpp
 * @brief mex interface for cv::ximgproc::GuidedFilter
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
map<int,Ptr<GuidedFilter> > obj_;

/// Option arguments parser used by create and filter methods
struct OptionsParser
{
    int radius;
    double eps;

    /** Parse input arguments.
     * @param first iterator at the beginning of the arguments vector.
     * @param last iterator at the end of the arguments vector.
     */
    OptionsParser(vector<MxArray>::const_iterator first,
                  vector<MxArray>::const_iterator last)
        : radius(7),
          eps(500.0)
    {
        ptrdiff_t len = std::distance(first, last);
        nargchk((len%2)==0);
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "Radius")
                radius = val.toInt();
            else if (key == "EPS")
                eps = val.toDouble();
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
        nargchk(nrhs>=3 && nlhs<=1);
        Mat guide(rhs[2].toMat(rhs[2].isUint8() ? CV_8U :
            (rhs[2].isUint16() ? CV_16U : CV_32F)));
        OptionsParser opts(rhs.begin() + 3, rhs.end());
        obj_[++last_id] = createGuidedFilter(guide, opts.radius, opts.eps);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "guidedFilter") {
        nargchk(nrhs>=4 && nlhs<=1);
        Mat src(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F)),
            guide(rhs[3].toMat(rhs[3].isUint8() ? CV_8U :
                (rhs[3].isUint16() ? CV_16U : CV_32F))),
            dst;
        OptionsParser opts(rhs.begin() + 4, rhs.end());
        guidedFilter(guide, src, dst, opts.radius, opts.eps);
        plhs[0] = MxArray(dst);
        return;
    }

    // Big operation switch
    Ptr<GuidedFilter> obj = obj_[id];
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
            Algorithm::loadFromString<GuidedFilter>(rhs[2].toString(), objname) :
            Algorithm::load<GuidedFilter>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing GuidedFilter::create()
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
    else if (method == "filter") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int dDepth = -1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "DDepth")
                dDepth = (rhs[i+1].isChar()) ?
                    ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F)),
            dst;
        obj->filter(src, dst, dDepth);
        plhs[0] = MxArray(dst);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
