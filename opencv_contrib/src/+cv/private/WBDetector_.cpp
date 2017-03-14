/**
 * @file WBDetector_.cpp
 * @brief mex interface for cv::xobjdetect::WBDetector
 * @ingroup xobjdetect
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/xobjdetect.hpp"
using namespace std;
using namespace cv;
using namespace cv::xobjdetect;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<WBDetector> > obj_;
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

    // Constructor call
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = WBDetector::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<WBDetector> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "read") {
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
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs<=1);
        FileStorage fs(rhs[2].toString(), FileStorage::WRITE +
            ((nlhs > 0) ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        fs << "waldboost";
        obj->write(fs);
        if (nlhs > 0)
            plhs[0] = MxArray(fs.releaseAndGetString());
    }
    else if (method == "train") {
        nargchk(nrhs==4 && nlhs==0);
        string pos_samples(rhs[2].toString()), neg_imgs(rhs[3].toString());
        obj->train(pos_samples, neg_imgs);
    }
    else if (method == "detect") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat img(rhs[2].toMat());
        vector<Rect> bboxes;
        vector<double> confidences;
        obj->detect(img, bboxes, confidences);
        plhs[0] = MxArray(bboxes);
        if (nlhs>1)
            plhs[1] = MxArray(confidences);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
