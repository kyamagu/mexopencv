/**
 * @file MergeRobertson_.cpp
 * @brief mex interface for cv::MergeRobertson
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
map<int,Ptr<MergeRobertson> > obj_;
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
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = createMergeRobertson();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<MergeRobertson> obj = obj_[id];
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
            Algorithm::loadFromString<MergeRobertson>(rhs[2].toString(), objname) :
            Algorithm::load<MergeRobertson>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing MergeRobertson::create()
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
        nargchk((nrhs==4 || nrhs==5) && nlhs<=1);
        vector<Mat> src;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            src.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                src.push_back(it->toMat(CV_8U));
        }
        Mat times(rhs[3].toMat(CV_32F)), dst;
        if (nrhs == 5) {
            Mat response(rhs[4].toMat(CV_32F));
            obj->process(src, dst, times, response);
        }
        else
            obj->process(src, dst, times);
        plhs[0] = MxArray(dst);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
