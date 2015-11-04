/**
 * @file AlignMTB_.cpp
 * @brief mex interface for cv::AlignMTB
 * @ingroup photo
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/photo.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<AlignMTB> > obj_;

/** Create an instance of AlignMTB using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created AlignMTB
 */
Ptr<AlignMTB> create_AlignMTB(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int max_bits = 6;
    int exclude_range = 4;
    bool cut = true;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MaxBits")
            max_bits = val.toInt();
        else if (key == "ExcludeRange")
            exclude_range = val.toInt();
        else if (key == "Cut")
            cut = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createAlignMTB(max_bits, exclude_range, cut);
}
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
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = create_AlignMTB(
            rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<AlignMTB> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
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
            Algorithm::loadFromString<AlignMTB>(rhs[2].toString(), objname) :
            Algorithm::load<AlignMTB>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing AlignMTB::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
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
    else if (method == "process") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<Mat> src, dst;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            src.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                src.push_back(it->toMat(CV_8U));
        }
        obj->process(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "calculateShift") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat img0(rhs[2].toMat(CV_8U)),
            img1(rhs[3].toMat(CV_8U));
        Point shift = obj->calculateShift(img0, img1);
        plhs[0] = MxArray(shift);
    }
    else if (method == "shiftMat") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat src(rhs[2].toMat()), dst;
        Point shift(rhs[3].toPoint());
        obj->shiftMat(src, dst, shift);
        plhs[0] = MxArray(dst);
    }
    else if (method == "computeBitmaps") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat img(rhs[2].toMat(CV_8U)), tb, eb;
        obj->computeBitmaps(img, tb, eb);
        plhs[0] = MxArray(tb);
        if (nlhs>1)
            plhs[1] = MxArray(eb);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "MaxBits")
            plhs[0] = MxArray(obj->getMaxBits());
        else if (prop == "ExcludeRange")
            plhs[0] = MxArray(obj->getExcludeRange());
        else if (prop == "Cut")
            plhs[0] = MxArray(obj->getCut());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "MaxBits")
            obj->setMaxBits(rhs[3].toInt());
        else if (prop == "ExcludeRange")
            obj->setExcludeRange(rhs[3].toInt());
        else if (prop == "Cut")
            obj->setCut(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
