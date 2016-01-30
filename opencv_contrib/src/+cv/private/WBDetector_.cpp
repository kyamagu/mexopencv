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
        return;
    }

    // Big operation switch
    Ptr<WBDetector> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "read") {
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(), FileStorage::READ);
        obj->read(fs.getFirstTopLevelNode());
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to read detector");
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(), FileStorage::WRITE);
        fs << "waldboost";
        obj->write(fs);
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
