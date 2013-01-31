/**
 * @file DescriptorMatcher_.cpp
 * @brief mex interface for DescriptorMatcher
 * @author Kota Yamaguchi
 * @date 2012
 */
#include <typeinfo>
#include "mexopencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DescriptorMatcher> > obj_;
/// Initialization methods for flann::Index
const ConstMap<std::string,cvflann::flann_centers_init_t> CentersInit =
    ConstMap<std::string,cvflann::flann_centers_init_t>
    ("Random", cvflann::FLANN_CENTERS_RANDOM)
    ("Gonzales", cvflann::FLANN_CENTERS_GONZALES)
    ("KMeansPP", cvflann::FLANN_CENTERS_KMEANSPP);

/// Check number of arguments
void nargchk(bool cond)
{
    if (!cond)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
}

/// Create a new index parameters
Ptr<flann::IndexParams> createIndexParams(const MxArray& m)
{
    Ptr<flann::IndexParams> p(NULL);
    vector<MxArray> rhs(m.toVector<MxArray>());
    if (rhs.empty() || (rhs.size()%2)==0)
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    string type(rhs[0].toString());
    if (type == "Linear")
        p = new flann::LinearIndexParams();
    else if (type == "KDTree") {
        int trees = 4;
        for (int i=1; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key == "Trees")
                trees = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        p = new flann::KDTreeIndexParams(trees);
    }
    else if (type == "KMeans") {
        int branching = 32;
        int iterations = 11;
        cvflann::flann_centers_init_t centers_init = cvflann::CENTERS_RANDOM;
        float cb_index = 0.2;
        for (int i=1; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key == "Branching")
                branching = rhs[i+1].toInt();
            else if (key == "Iterations")
                iterations = rhs[i+1].toInt();
            else if (key == "CentersInit")
                centers_init = CentersInit[rhs[i+1].toString()];
            else if (key == "CBIndex")
                cb_index = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        p = new flann::KMeansIndexParams(
            branching, iterations, centers_init, cb_index);
    }
    else if (type == "Composite") {
        int trees = 4;
        int branching = 32;
        int iterations = 11;
        cvflann::flann_centers_init_t centers_init = cvflann::CENTERS_RANDOM;
        float cb_index = 0.2;
        for (int i=1; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key == "Trees")
                trees = rhs[i+1].toInt();
            else if (key == "Branching")
                branching = rhs[i+1].toInt();
            else if (key == "Iterations")
                iterations = rhs[i+1].toInt();
            else if (key == "CentersInit")
                centers_init = CentersInit[rhs[i+1].toString()];
            else if (key == "CBIndex")
                cb_index = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        p = new flann::CompositeIndexParams(trees,
            branching, iterations, centers_init, cb_index);
    }
    else if (type == "LSH") {
        unsigned int table_number = 20;
        unsigned int key_size = 15;
        unsigned int multi_probe_level = 0;
        for (int i=1; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key == "TableNumber")
                table_number = rhs[i+1].toInt();
            else if (key == "KeySize")
                key_size = rhs[i+1].toInt();
            else if (key == "MultiProbeLevel")
                multi_probe_level = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        p = new flann::LshIndexParams(table_number, key_size, multi_probe_level);
    }
    else if (type == "Autotuned") {
        float target_precision = 0.9;
        float build_weight = 0.01;
        float memory_weight = 0;
        float sample_fraction = 0.1;
        for (int i=1; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key == "TargetPrecision")
                target_precision = rhs[i+1].toDouble();
            else if (key == "BuildWeight")
                build_weight = rhs[i+1].toDouble();
            else if (key == "MemoryWeight")
                memory_weight = rhs[i+1].toDouble();
            else if (key == "SampleFraction")
                sample_fraction = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        p = new flann::AutotunedIndexParams(target_precision,
            build_weight, memory_weight, sample_fraction);
    }
    else if (type == "Saved") {
        if (rhs.size()!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Missing filename");
        string filename(rhs[1].toString());
        p = new flann::SavedIndexParams(filename);
        if (p.empty())
            mexErrMsgIdAndTxt("mexopencv:error","Failed to load index");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized index type");
    return p;
}

/// Create a new search parameters
Ptr<flann::SearchParams> createSearchParams(const MxArray& m)
{
    vector<MxArray> rhs(m.toVector<MxArray>());
    nargchk((rhs.size()%2)==0);
    int checks = 32;
    float eps = 0;
    bool sorted = true;
    for (int i=0; i<rhs.size(); i+=2) {
        string key(rhs[i].toString());
        if (key == "Checks")
            checks = rhs[i+1].toInt();
        else if (key == "EPS")
            eps = rhs[i+1].toDouble();
        else if (key == "Sorted")
            sorted = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    return Ptr<flann::SearchParams>(new flann::SearchParams(checks,eps,sorted));
}

/// Create a new FlannBasedMatcher
Ptr<DescriptorMatcher> createFlannBasedMatcher(const vector<MxArray>& rhs)
{
    Ptr<flann::IndexParams> indexParams(NULL);
    Ptr<flann::SearchParams> searchParams(NULL);
    for (int i=0; i<rhs.size(); i+=2) {
        string key(rhs[i].toString());
        if (key == "Index")
            indexParams = createIndexParams(rhs[i+1]);
        else if (key == "Search")
            searchParams = createSearchParams(rhs[i+1]);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    if (indexParams.empty())
        indexParams = new flann::KDTreeIndexParams();
    if (searchParams.empty())
        searchParams = new flann::SearchParams();
    return Ptr<DescriptorMatcher>(new FlannBasedMatcher(indexParams,searchParams));
}

}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    nargchk(nrhs>=2 && nlhs<=1);
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method = rhs[1].toString();

    if (last_id==0)
        initModule_nonfree();
    
    // Big operation switch
    if (method == "new") {
        nargchk(nrhs>=3);
        string descriptorMatcherType(rhs[2].toString());
        obj_[++last_id] = (nrhs>=4 && descriptorMatcherType=="FlannBased") ?
            createFlannBasedMatcher(vector<MxArray>(prhs+3, prhs+nrhs)) :
            DescriptorMatcher::create(descriptorMatcherType);
        plhs[0] = MxArray(last_id);
        return;
    }
    Ptr<DescriptorMatcher> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "type") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "add") {
        nargchk(nrhs==3 && nlhs==0);
        vector<MxArray> v(rhs[2].toVector<MxArray>());
        vector<Mat> descriptors;
        descriptors.reserve(v.size());
        for (vector<MxArray>::iterator it=v.begin();it<v.end();++it)
            descriptors.push_back(((*it).isUint8()) ? (*it).toMat() : (*it).toMat(CV_32F));
        obj->add(descriptors);
    }
    else if (method == "getTrainDescriptors") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->getTrainDescriptors());
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "empty") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "isMaskSupported") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->isMaskSupported());
    }
    else if (method == "train") {
        nargchk(nrhs==2);
        obj->train();
    }
    else if (method == "match") {
        nargchk(nrhs>=3);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<DMatch> matches;
        if (nrhs>=4 && rhs[3].isNumeric()) { // First format
            nargchk((nrhs%2)==0);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
            Mat mask;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->match(queryDescriptors, trainDescriptors, matches, mask);
        }
        else { // Second format
            nargchk((nrhs%2)==1);
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->match(queryDescriptors, matches, masks);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "knnMatch") {
        nargchk(nrhs>=4);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) { // First format
            nargchk((nrhs%2)==1);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
            int k = rhs[4].toInt();
            Mat mask;
            bool compactResult=false;
            for (int i=5; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else if (key=="CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->knnMatch(queryDescriptors, trainDescriptors, matches, k, mask,
                compactResult);
        }
        else { // Second format
            nargchk((nrhs%2)==0);
            int k = rhs[3].toInt();
            vector<Mat> masks;
            bool compactResult=false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
                else if (key=="CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->knnMatch(queryDescriptors, matches, k, masks, compactResult);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "radiusMatch") {
        nargchk(nrhs>=4);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) { // First format
            nargchk((nrhs%2)==1);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
            float maxDistance = rhs[4].toDouble();
            Mat mask;
            bool compactResult=false;
            for (int i=5; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else if (key=="CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->radiusMatch(queryDescriptors, trainDescriptors, matches, 
                maxDistance, mask, compactResult);
        }
        else { // Second format
            nargchk((nrhs%2)==0);
            float maxDistance = rhs[3].toDouble();
            vector<Mat> masks;
            bool compactResult=false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
                else if (key=="CompactResult")
                    compactResult = rhs[i+1].toBool();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->radiusMatch(queryDescriptors, matches, maxDistance, masks, compactResult);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "read") {
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(),FileStorage::READ);
        obj->read(fs.root());
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(),FileStorage::WRITE);
        obj->write(fs);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
