/**
 * @file BinaryDescriptor_.cpp
 * @brief mex interface for cv::line_descriptor::BinaryDescriptor
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
map<int,Ptr<BinaryDescriptor> > obj_;

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

/** Convert an MxArray to cv::line_descriptor::KeyLine
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return keyline object
 */
KeyLine MxArrayToKeyLine(const MxArray& arr, mwIndex idx = 0)
{
    KeyLine keyline;
    keyline.angle           = arr.at("angle",              idx).toFloat();
    keyline.class_id        = arr.at("class_id",           idx).toInt();
    keyline.octave          = arr.at("octave",             idx).toInt();
    keyline.pt              = arr.at("pt",                 idx).toPoint2f();
    keyline.response        = arr.at("response",           idx).toFloat();
    keyline.size            = arr.at("size",               idx).toFloat();
    keyline.startPointX     = arr.at("startPoint",         idx).toPoint2f().x;
    keyline.startPointY     = arr.at("startPoint",         idx).toPoint2f().y;
    keyline.endPointX       = arr.at("endPoint",           idx).toPoint2f().x;
    keyline.endPointY       = arr.at("endPoint",           idx).toPoint2f().y;
    keyline.sPointInOctaveX = arr.at("startPointInOctave", idx).toPoint2f().x;
    keyline.sPointInOctaveY = arr.at("startPointInOctave", idx).toPoint2f().y;
    keyline.ePointInOctaveX = arr.at("endPointInOctave",   idx).toPoint2f().x;
    keyline.ePointInOctaveY = arr.at("endPointInOctave",   idx).toPoint2f().y;
    keyline.lineLength      = arr.at("lineLength",         idx).toFloat();
    keyline.numOfPixels     = arr.at("numOfPixels",        idx).toInt();
    return keyline;
}

/** Convert an MxArray to std::vector<cv::line_descriptor::KeyLine>
 * @param arr struct-array MxArray object
 * @return vector of keyline objects
 */
vector<KeyLine> MxArrayToVectorKeyLine(const MxArray& arr)
{
    const mwSize n = arr.numel();
    vector<KeyLine> vk;
    vk.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            vk.push_back(MxArrayToKeyLine(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            vk.push_back(MxArrayToKeyLine(arr,i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::line_descriptor::KeyLine>");
    return vk;
}

/** Convert an MxArray to std::vector<std::vector<cv::line_descriptor::KeyLine>>
 * @param arr cell-array of struct-arrays MxArray object
 * @return vector of vector of keyline objects
 */
vector<vector<KeyLine> > MxArrayToVectorVectorKeyLine(const MxArray& arr)
{
    vector<MxArray> va(arr.toVector<MxArray>());
    vector<vector<KeyLine> > vvk;
    vvk.reserve(va.size());
    for (vector<MxArray>::const_iterator it = va.begin(); it != va.end(); ++it)
        vvk.push_back(MxArrayToVectorKeyLine(*it));
    return vvk;
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
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        BinaryDescriptor::Params parameters;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "KSize")
                parameters.ksize_ = rhs[i+1].toInt();
            else if (key == "NumOfOctave")
                parameters.numOfOctave_ = rhs[i+1].toInt();
            else if (key == "ReductionRatio")
                parameters.reductionRatio = rhs[i+1].toInt();
            else if (key == "WidthOfBand")
                parameters.widthOfBand_ = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = BinaryDescriptor::createBinaryDescriptor(parameters);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<BinaryDescriptor> obj = obj_[id];
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
            Algorithm::loadFromString<BinaryDescriptor>(rhs[2].toString(), objname) :
            Algorithm::load<BinaryDescriptor>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing BinaryDescriptor::create()
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
    else if (method == "defaultNorm") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(NormTypeInv[obj->defaultNorm()]);
    }
    else if (method == "descriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->descriptorSize());
    }
    else if (method == "descriptorType") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(ClassNameInvMap[obj->descriptorType()]);
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat mask;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            Mat image(rhs[2].toMat(CV_8U));
            vector<KeyLine> keylines;
            obj->detect(image, keylines, mask);
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
            obj->detect(images, keylines, masks);
            plhs[0] = toCellOfStruct(keylines);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "compute") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        bool returnFloatDescr = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ReturnFloatDescr")
                returnFloatDescr = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat image(rhs[2].toMat(CV_8U)), descriptors;
            vector<KeyLine> keylines(MxArrayToVectorKeyLine(rhs[3]));
            obj->compute(image, keylines, descriptors, returnFloatDescr);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = toStruct(keylines);
        }
        else if (rhs[2].isCell()) { // second variant that accepts an image set
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images, descriptors;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_8U));
            }
            vector<vector<KeyLine> > keylines(MxArrayToVectorVectorKeyLine(rhs[3]));
            //HACK: compute method does not check correct sizes, so we do it
            if (keylines.size() != images.size())
                mexErrMsgIdAndTxt("mexopencv:error", "Incorrect keylines size");
            //HACK: compute method does not take care of allocating output vector!
            descriptors.resize(images.size());
            obj->compute(images, keylines, descriptors, returnFloatDescr);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = toCellOfStruct(keylines);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "detectAndCompute") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        Mat mask;
        vector<KeyLine> keylines;
        bool useProvidedKeyLines = false;
        bool returnFloatDescr = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else if (key == "KeyLines") {
                keylines = MxArrayToVectorKeyLine(rhs[i+1]);
                useProvidedKeyLines = true;
            }
            else if (key == "ReturnFloatDescr")
                returnFloatDescr = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(CV_8U)), descriptors;
        obj->operator()(image, mask, keylines, descriptors,
            useProvidedKeyLines, returnFloatDescr);
        plhs[0] = toStruct(keylines);
        if (nlhs > 1)
            plhs[1] = MxArray(descriptors);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "NumOfOctaves")
            plhs[0] = MxArray(obj->getNumOfOctaves());
        else if (prop == "ReductionRatio")
            plhs[0] = MxArray(obj->getReductionRatio());
        else if (prop == "WidthOfBand")
            plhs[0] = MxArray(obj->getWidthOfBand());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "NumOfOctaves")
            obj->setNumOfOctaves(rhs[3].toInt());
        else if (prop == "ReductionRatio")
            obj->setReductionRatio(rhs[3].toInt());
        else if (prop == "WidthOfBand")
            obj->setWidthOfBand(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
