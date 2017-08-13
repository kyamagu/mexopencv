/**
 * @file SuperpixelSLIC_.cpp
 * @brief mex interface for cv::ximgproc::SuperpixelSLIC
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
map<int,Ptr<SuperpixelSLIC> > obj_;

/// Option values for SLIC algorithms
const ConstMap<string, int> SLICAlgorithmMap = ConstMap<string, int>
    ("SLIC",  cv::ximgproc::SLIC)
    ("SLICO", cv::ximgproc::SLICO)
    ("MSLIC", cv::ximgproc::MSLIC);
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
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int algorithm = cv::ximgproc::SLICO;
        int region_size = 10;
        float ruler = 10.0f;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Algorithm")
                algorithm = SLICAlgorithmMap[rhs[i+1].toString()];
            else if (key == "RegionSize")
                region_size = rhs[i+1].toInt();
            else if (key == "Ruler")
                ruler = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat());
        obj_[++last_id] = createSuperpixelSLIC(
            image, algorithm, region_size, ruler);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SuperpixelSLIC> obj = obj_[id];
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
            Algorithm::loadFromString<SuperpixelSLIC>(rhs[2].toString(), objname) :
            Algorithm::load<SuperpixelSLIC>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing SuperpixelSLIC::create()
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
    else if (method == "iterate") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int num_iterations = 10;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "NumIterations")
                num_iterations = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->iterate(num_iterations);
    }
    else if (method == "getNumberOfSuperpixels") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getNumberOfSuperpixels());
    }
    else if (method == "getLabels") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat labels_out;
        obj->getLabels(labels_out);
        plhs[0] = MxArray(labels_out);
    }
    else if (method == "getLabelContourMask") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        bool thick_line = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ThickLine")
                thick_line = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image;
        obj->getLabelContourMask(image, thick_line);
        plhs[0] = MxArray(image);
    }
    else if (method == "enforceLabelConnectivity") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int min_element_size = 25;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "MinElementSize")
                min_element_size = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->enforceLabelConnectivity(min_element_size);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
