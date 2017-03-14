/**
 * @file SelectiveSearchSegmentation_.cpp
 * @brief mex interface for cv::ximgproc::segmentation::SelectiveSearchSegmentation
 * @ingroup ximgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc::segmentation;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<SelectiveSearchSegmentation> > obj_;

/** Create an instance of GraphSegmentation using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created GraphSegmentation
 */
Ptr<GraphSegmentation> create_GraphSegmentation(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    double sigma = 0.5;
    float k = 300;
    int min_size = 100;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Sigma")
            sigma = val.toDouble();
        else if (key == "K")
            k = val.toFloat();
        else if (key == "MinSize")
            min_size = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createGraphSegmentation(sigma, k, min_size);
}

/** Create an instance of SelectiveSearchSegmentationStrategyMultiple using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created SelectiveSearchSegmentationStrategyMultiple
 */
Ptr<SelectiveSearchSegmentationStrategyMultiple> create_SelectiveSearchSegmentationStrategyMultiple(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=0);
    Ptr<SelectiveSearchSegmentationStrategyMultiple> p =
        createSelectiveSearchSegmentationStrategyMultiple();
    for (; first != last; ++first) {
        string type(first->toString());
        Ptr<SelectiveSearchSegmentationStrategy> s;
        if (type == "Color")
            s = createSelectiveSearchSegmentationStrategyColor();
        else if (type == "Size")
            s = createSelectiveSearchSegmentationStrategySize();
        else if (type == "Texture")
            s = createSelectiveSearchSegmentationStrategyTexture();
        else if (type == "Fill")
            s = createSelectiveSearchSegmentationStrategyFill();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized segmentation strategy %s", type.c_str());
        p->addStrategy(s, 1.0f / len);  // equal weights
    }
    return p;
}

/** Create an instance of SelectiveSearchSegmentationStrategy using options in arguments
 * @param type stereo matcher type, one of:
 *    - "Color"
 *    - "Size"
 *    - "Texture"
 *    - "Fill"
 *    - "Multiple"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created SelectiveSearchSegmentationStrategy
 */
Ptr<SelectiveSearchSegmentationStrategy> create_SelectiveSearchSegmentationStrategy(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<SelectiveSearchSegmentationStrategy> p;
    if (type == "Color")
        p = createSelectiveSearchSegmentationStrategyColor();
    else if (type == "Size")
        p = createSelectiveSearchSegmentationStrategySize();
    else if (type == "Texture")
        p = createSelectiveSearchSegmentationStrategyTexture();
    else if (type == "Fill")
        p = createSelectiveSearchSegmentationStrategyFill();
    else if (type == "Multiple")
        p = create_SelectiveSearchSegmentationStrategyMultiple(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized segmentation strategy %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create SelectiveSearchSegmentationStrategy");
    return p;
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
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = createSelectiveSearchSegmentation();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SelectiveSearchSegmentation> obj = obj_[id];
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
            Algorithm::loadFromString<SelectiveSearchSegmentation>(rhs[2].toString(), objname) :
            Algorithm::load<SelectiveSearchSegmentation>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing SelectiveSearchSegmentation::create()
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
    else if (method == "setBaseImage") {
        nargchk(nrhs==3 && nlhs==0);
        Mat img(rhs[2].toMat());
        obj->setBaseImage(img);
    }
    else if (method == "switchToSingleStrategy") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int k = 200;
        float sigma = 0.8f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "K")
                k = rhs[i+1].toInt();
            else if (key == "Sigma")
                sigma = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->switchToSingleStrategy(k, sigma);
    }
    else if (method == "switchToSelectiveSearchFast") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int base_k = 150;
        int inc_k = 150;
        float sigma = 0.8f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "BaseK")
                base_k = rhs[i+1].toInt();
            else if (key == "IncK")
                inc_k = rhs[i+1].toInt();
            else if (key == "Sigma")
                sigma = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->switchToSelectiveSearchFast(base_k, inc_k, sigma);
    }
    else if (method == "switchToSelectiveSearchQuality") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int base_k = 150;
        int inc_k = 150;
        float sigma = 0.8f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "BaseK")
                base_k = rhs[i+1].toInt();
            else if (key == "IncK")
                inc_k = rhs[i+1].toInt();
            else if (key == "Sigma")
                sigma = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->switchToSelectiveSearchQuality(base_k, inc_k, sigma);
    }
    else if (method == "addImage") {
        nargchk(nrhs==3 && nlhs==0);
        Mat img(rhs[2].toMat());
        obj->addImage(img);
    }
    else if (method == "clearImages") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clearImages();
    }
    else if (method == "addGraphSegmentation") {
        nargchk(nrhs>=2 && nlhs==0);
        Ptr<GraphSegmentation> g = create_GraphSegmentation(
            rhs.begin() + 2, rhs.end());
        obj->addGraphSegmentation(g);
    }
    else if (method == "clearGraphSegmentations") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clearGraphSegmentations();
    }
    else if (method == "addStrategy") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<SelectiveSearchSegmentationStrategy> s =
            create_SelectiveSearchSegmentationStrategy(
                rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->addStrategy(s);
    }
    else if (method == "clearStrategies") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clearStrategies();
    }
    else if (method == "process") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<Rect> rects;
        obj->process(rects);
        plhs[0] = MxArray(Mat(rects, false).reshape(1,0));  // Nx4
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
