/**
 * @file LSDDetector_.cpp
 * @brief mex interface for cv::line_descriptor::LSDDetector
 * @ingroup line_descriptor
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/line_descriptor.hpp"
using namespace std;
using namespace cv;
using namespace cv::line_descriptor;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<LSDDetector> > obj_;

/** Convert keylines to struct array
 * @param keylines vector of keylines
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<KeyLine>& keylines)
{
    const char *fields[] = {"angle", "class_id", "octave", "pt", "response",
        "size", "startPoint", "endPoint", "startPointInOctave",
        "endPointInOctave", "lineLength", "numOfPixels"};
    MxArray s = MxArray::Struct(fields, 12, 1, keylines.size());
    for (mwIndex i = 0; i < keylines.size(); ++i) {
        s.set("angle",              keylines[i].angle,                   i);
        s.set("class_id",           keylines[i].class_id,                i);
        s.set("octave",             keylines[i].octave,                  i);
        s.set("pt",                 keylines[i].pt,                      i);
        s.set("response",           keylines[i].response,                i);
        s.set("size",               keylines[i].size,                    i);
        s.set("startPoint",         keylines[i].getStartPoint(),         i);
        s.set("endPoint",           keylines[i].getEndPoint(),           i);
        s.set("startPointInOctave", keylines[i].getStartPointInOctave(), i);
        s.set("endPointInOctave",   keylines[i].getEndPointInOctave(),   i);
        s.set("lineLength",         keylines[i].lineLength,              i);
        s.set("numOfPixels",        keylines[i].numOfPixels,             i);
    }
    return s;
}

/** Convert set of keylines to cell-array of struct-arrays
 * @param keylines vector of vector of keylines
 * @return cell-array of struct-arrays MxArray object
 */
MxArray toCellOfStruct(const vector<vector<KeyLine> >& keylines)
{
    MxArray c = MxArray::Cell(1, keylines.size());
    for (mwIndex i = 0; i < keylines.size(); ++i)
        c.set(i, toStruct(keylines[i]));
    return c;
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
        obj_[++last_id] = LSDDetector::createLSDDetector();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<LSDDetector> obj = obj_[id];
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
            Algorithm::loadFromString<LSDDetector>(rhs[2].toString(), objname) :
            Algorithm::load<LSDDetector>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing LSDDetector::create()
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
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int scale = 2;
        int numOctaves = 1;
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat mask;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else if (key == "Scale")
                    scale = rhs[i+1].toInt();
                else if (key == "NumOctaves")
                    numOctaves = rhs[i+1].toInt();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            Mat image(rhs[2].toMat(CV_8U));
            vector<KeyLine> keylines;
            obj->detect(image, keylines, scale, numOctaves, mask);
            plhs[0] = toStruct(keylines);
        }
        else if (rhs[2].isCell()) {  // second variant that accepts an image set
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> arr(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(arr.size());
                    for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else if (key == "Scale")
                    scale = rhs[i+1].toInt();
                else if (key == "NumOctaves")
                    numOctaves = rhs[i+1].toInt();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_8U));
            }
            //HACK: detect method does not like an empty masks vector!
            if (masks.empty())
                masks.assign(images.size(), Mat());
            vector<vector<KeyLine> > keylines;
            //HACK: detect method does not take care of allocating outer vector!
            keylines.resize(images.size());
            obj->detect(images, keylines, scale, numOctaves, masks);
            plhs[0] = toCellOfStruct(keylines);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    //else if (method == "defaultNorm")
    //else if (method == "descriptorSize")
    //else if (method == "descriptorType")
    //else if (method == "compute")
    //else if (method == "detectAndCompute")
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
