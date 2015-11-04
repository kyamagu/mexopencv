/**
 * @file TonemapReinhard_.cpp
 * @brief mex interface for cv::TonemapReinhard
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
map<int,Ptr<TonemapReinhard> > obj_;

/** Create an instance of TonemapReinhard using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created TonemapReinhard
 */
Ptr<TonemapReinhard> create_TonemapReinhard(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float gamma = 1.0f;
    float intensity = 0.0f;
    float light_adapt = 1.0f;
    float color_adapt = 0.0f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Gamma")
            gamma = val.toFloat();
        else if (key == "Intensity")
            intensity = val.toFloat();
        else if (key == "LightAdaptation")
            light_adapt = val.toFloat();
        else if (key == "ColorAdaptation")
            color_adapt = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createTonemapReinhard(gamma, intensity, light_adapt, color_adapt);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = create_TonemapReinhard(
            rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<TonemapReinhard> obj = obj_[id];
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
            Algorithm::loadFromString<TonemapReinhard>(rhs[2].toString(), objname) :
            Algorithm::load<TonemapReinhard>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing TonemapReinhard::create()
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
        Mat src(rhs[2].toMat(CV_32F)), dst;
        obj->process(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else if (prop == "Intensity")
            plhs[0] = MxArray(obj->getIntensity());
        else if (prop == "LightAdaptation")
            plhs[0] = MxArray(obj->getLightAdaptation());
        else if (prop == "ColorAdaptation")
            plhs[0] = MxArray(obj->getColorAdaptation());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Gamma")
            obj->setGamma(rhs[3].toFloat());
        else if (prop == "Intensity")
            obj->setIntensity(rhs[3].toFloat());
        else if (prop == "LightAdaptation")
            obj->setLightAdaptation(rhs[3].toFloat());
        else if (prop == "ColorAdaptation")
            obj->setColorAdaptation(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
