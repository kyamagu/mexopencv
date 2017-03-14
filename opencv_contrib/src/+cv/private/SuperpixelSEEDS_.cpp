/**
 * @file SuperpixelSEEDS_.cpp
 * @brief mex interface for cv::ximgproc::SuperpixelSEEDS
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
map<int,Ptr<SuperpixelSEEDS> > obj_;
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
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);
        int prior = 2;
        int histogram_bins = 5;
        bool double_step = false;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Prior")
                prior = rhs[i+1].toInt();
            else if (key == "HistogramBins")
                histogram_bins = rhs[i+1].toInt();
            else if (key == "DoubleStep")
                double_step = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<int> sz(rhs[2].toVector<int>());
        if (sz.size() != 2 && sz.size() != 3)
            mexErrMsgIdAndTxt("mexopencv:error", "Incorrect size");
        int image_width = sz[1],
            image_height = sz[0],
            image_channels = (sz.size() == 3 ? sz[2] : 1),
            num_superpixels = rhs[3].toInt(),
            num_levels = rhs[4].toInt();
        obj_[++last_id] = createSuperpixelSEEDS(
            image_width, image_height, image_channels,
            num_superpixels, num_levels, prior, histogram_bins, double_step);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SuperpixelSEEDS> obj = obj_[id];
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
            Algorithm::loadFromString<SuperpixelSEEDS>(rhs[2].toString(), objname) :
            Algorithm::load<SuperpixelSEEDS>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing SuperpixelSEEDS::create()
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
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        int num_iterations = 4;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "NumIterations")
                num_iterations = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(rhs[2].isUint8() ? CV_8U :
            (rhs[2].isUint16() ? CV_16U : CV_32F)));
        obj->iterate(img, num_iterations);
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
        bool thick_line = false;
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
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
