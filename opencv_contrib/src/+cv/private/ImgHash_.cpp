/**
 * @file ImgHash_.cpp
 * @brief mex interface for cv::img_hash::ImgHashBase
 * @ingroup img_hash
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/img_hash.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::img_hash;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ImgHashBase> > obj_;

/// BlockMeanHash mode map for option processing
const ConstMap<string,int> BlockMeanHashModeMap = ConstMap<string,int>
    ("Mode0", cv::img_hash::BLOCK_MEAN_HASH_MODE_0)
    ("Mode1", cv::img_hash::BLOCK_MEAN_HASH_MODE_1);

/** Create an instance of ImgHashBase using options in arguments
 * @param alg image hash algorithm, one of:
 *    - "AverageHash"
 *    - "BlockMeanHash"
 *    - "ColorMomentHash"
 *    - "MarrHildrethHash"
 *    - "PHash"
 *    - "RadialVarianceHash"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ImgHashBase
 */
Ptr<ImgHashBase> createImgHashBase(
    const string& alg,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<ImgHashBase> p;
    if (alg == "AverageHash") {
        nargchk(len==0);
        p = AverageHash::create();
    }
    else if (alg == "BlockMeanHash") {
        nargchk((len%2)==0);
        int mode = cv::img_hash::BLOCK_MEAN_HASH_MODE_0;
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "Mode")
                mode = BlockMeanHashModeMap[val.toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = BlockMeanHash::create(mode);
    }
    else if (alg == "ColorMomentHash") {
        nargchk(len==0);
        p = ColorMomentHash::create();
    }
    else if (alg == "MarrHildrethHash") {
        nargchk((len%2)==0);
        float alpha = 2.0f;
        float scale = 1.0f;
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "Alpha")
                alpha = val.toFloat();
            else if (key == "Scale")
                scale = val.toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = MarrHildrethHash::create(alpha, scale);
    }
    else if (alg == "PHash") {
        nargchk(len==0);
        p = PHash::create();
    }
    else if (alg == "RadialVarianceHash") {
        nargchk((len%2)==0);
        double sigma = 1;
        int numOfAngleLine = 180;
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "Sigma")
                sigma = val.toDouble();
            else if (key == "NumOfAngleLine")
                numOfAngleLine = val.toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = RadialVarianceHash::create(sigma, numOfAngleLine);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized hash algorithm %s",alg.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create ImgHashBase");
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
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createImgHashBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods calls
    else if (method == "averageHash") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[2].toMat(CV_8U)), hash;
        averageHash(img, hash);
        plhs[0] = MxArray(hash);
        return;
    }
    else if (method == "blockMeanHash") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int mode = BLOCK_MEAN_HASH_MODE_0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mode")
                mode = BlockMeanHashModeMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U)), hash;
        blockMeanHash(img, hash, mode);
        plhs[0] = MxArray(hash);
        return;
    }
    else if (method == "colorMomentHash") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[2].toMat(CV_8U)), hash;
        colorMomentHash(img, hash);
        plhs[0] = MxArray(hash);
        return;
    }
    else if (method == "marrHildrethHash") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        float alpha = 2.0f;
        float scale = 1.0f;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Alpha")
                alpha = rhs[i+1].toFloat();
            else if (key == "Scale")
                scale = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U)), hash;
        marrHildrethHash(img, hash, alpha, scale);
        plhs[0] = MxArray(hash);
        return;
    }
    else if (method == "pHash") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[2].toMat(CV_8U)), hash;
        pHash(img, hash);
        plhs[0] = MxArray(hash);
        return;
    }
    else if (method == "radialVarianceHash") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        double sigma = 1;
        int numOfAngleLine = 180;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Sigma")
                sigma = rhs[i+1].toDouble();
            else if (key == "NumOfAngleLine")
                numOfAngleLine = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U)), hash;
        radialVarianceHash(img, hash, sigma, numOfAngleLine);
        plhs[0] = MxArray(hash);
        return;
    }

    // Big operation switch
    Ptr<ImgHashBase> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "compute") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat img(rhs[2].toMat(CV_8U)), hash;
        obj->compute(img, hash);
        plhs[0] = MxArray(hash);
    }
    else if (method == "compare") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat hashOne(rhs[2].toMat()),
            hashTwo(rhs[3].toMat());  // hashes CV_8U or CV_64F
        double val = obj->compare(hashOne, hashTwo);
        plhs[0] = MxArray(val);
    }
    //TODO: expose derived-class specific methods:
    // BlockMeanHash::getMean
    // RadialVarianceHash::getFeatures
    // RadialVarianceHash::getPixPerLine
    // RadialVarianceHash::getProjection
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
