/**
 * @file FileStorage.cpp
 * @brief mex interface for FileStorage
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Check if the node is of a user-defined type
 * @param _node node.
 * @param _type_name type name. e.g., "opencv-matrix"
 * @return flag
 */
bool isa(const FileNode& _node, const string& _type_name)
{
    const CvFileNode* node = reinterpret_cast<const CvFileNode*>(*_node);
    if (node->info && node->info->type_name)
        return string(node->info->type_name)==_type_name;
    return false;
}

/** Recursive function to output to a file storage
 * @param fs FileStorage object
 * @param x MxArray to be read
 * @param node FileNode to read
 */
void read(FileStorage& fs, MxArray& x, const FileNode& node)
{
    if (node.type()==FileNode::SEQ) {
        int n = node.size();
        vector<MxArray> v(n, MxArray(static_cast<mxArray*>(NULL)));
        for (int i=0; i<n; ++i) {
            const FileNode& elem = node[i];
            int type = elem.type();
            if (type==FileNode::INT)
                v[i] = MxArray(static_cast<int>(elem));
            else if (type==FileNode::REAL)
                v[i] = MxArray(static_cast<double>(elem));
            else if (type==FileNode::STR)
                v[i] = MxArray(static_cast<string>(elem));
            else if (type==FileNode::SEQ) {
                MxArray y(static_cast<mxArray*>(NULL));
                read(fs, y, elem);
                v[i] = y;
            }
            else if (type==FileNode::MAP) {
                if (isa(elem,"opencv-matrix")) {
                    Mat m;
                    elem >> m;
                    v[i] = MxArray(m);
                }
                else if (isa(elem,"opencv-nd-matrix")) {
                    MatND m;
                    elem >> m;
                    v[i] = MxArray(m);
                }
                else {
                    MxArray y = MxArray::Struct();
                    read(fs, y, elem);
                    v[i] = y;
                }
            }
        }
        x = MxArray(v);
    }
    else if (node.type()==FileNode::MAP) {
        for (FileNodeIterator it=node.begin(); it!=node.end(); ++it) {
            const FileNode& elem = (*it);
            int type = elem.type();
            if (type==FileNode::INT)
                x.set(elem.name(), static_cast<int>(elem));
            else if (type==FileNode::REAL)
                x.set(elem.name(), static_cast<double>(elem));
            else if (type==FileNode::STR)
                x.set(elem.name(), static_cast<string>(elem));
            else if (type==FileNode::SEQ) {
                MxArray y(static_cast<mxArray*>(NULL));
                read(fs, y, elem);
                x.set(elem.name(), y);
            }
            else if (type==FileNode::MAP) {
                if (isa(elem,"opencv-matrix")) {
                    Mat m;
                    elem >> m;
                    x.set(elem.name(), m);
                }
                else if (isa(elem,"opencv-nd-matrix")) {
                    MatND m;
                    elem >> m;
                    x.set(elem.name(), m);
                }
                else {
                    MxArray y = MxArray::Struct();
                    read(fs, y, elem);
                    x.set(elem.name(), y);
                }
            }
        }
    }
}

/** Recursive function to output to a file storage
 * @param fs FileStorage object
 * @param x MxArray to be written
 * @param root Flag inidicating the root node
 */
void write(FileStorage& fs, const MxArray& x, bool root=false)
{
    mxClassID classid = x.classID();
    if (classid == mxFUNCTION_CLASS || classid==mxUNKNOWN_CLASS)
        mexErrMsgIdAndTxt("mexopencv:error","Invalid MxArray");
    if (classid == mxSTRUCT_CLASS) {
        int n = x.numel();
        vector<string> fields(x.fieldnames());
        if (n>1) fs << "[";
        for (int i=0; i<n; ++i) {
            if (!root) fs << "{";
            for (vector<string>::iterator it=fields.begin(); it<fields.end(); ++it) {
                fs << *it;
                write(fs, MxArray(x.at(*it,i)));
            }
            if (!root) fs << "}";
        }
        if (n>1) fs << "]";
    }
    else if (classid == mxCELL_CLASS) {
        vector<MxArray> array(x.toVector<MxArray>());
        fs << "[";
        for (vector<MxArray>::iterator it=array.begin(); it<array.end(); ++it)
            write(fs,*it);
        fs << "]";
    }
    else if (classid == mxCHAR_CLASS) {
        string s(x.toString());
        fs << s;
    }
    else {
        if (x.numel()==1) {
            if (x.isDouble() || x.isSingle())
                fs << x.toDouble();
            else
                fs << x.toInt();
        }
        else {
            Mat y(x.toMat());
            fs << y;
        }
    }
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
    // Check arguments
    if (!(nrhs>=2&&nlhs==0)&&!(nrhs==1&&nlhs<=1))
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    string filename(MxArray(prhs[0]).toString());
    if (nrhs==1) {
        // Read
        FileStorage fs(filename, FileStorage::READ);
        FileNode node = fs.root();
        MxArray s = MxArray::Struct();
        read(fs, s, node);
        plhs[0] = s;
    }
    else {
        // Write
        vector<MxArray> rhs(prhs+1,prhs+nrhs);
        FileStorage fs(filename, FileStorage::WRITE);
        if (rhs[0].isStruct() && rhs[0].numel()==1)
            // Write a scalar struct
            write(fs, rhs[0], true);
        else {
            // Create a temporary scalar struct and write
            string nodeName(FileStorage::getDefaultObjectName(filename));
            MxArray s = MxArray::Struct();
            if (rhs.size()==1)
                s.set(nodeName, rhs[0].clone());
            else {
                MxArray cell = MxArray::Cell(rhs.size());
                for (int i=0; i<rhs.size(); ++i)
                    cell.set(i, rhs[i].clone());
                s.set(nodeName, cell);
            }
            write(fs, s, true);
            s.destroy();
        }
    }
}
