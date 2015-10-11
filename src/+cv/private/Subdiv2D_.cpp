/**
 * @file Subdiv2D_.cpp
 * @brief mex interface for cv::Subdiv2D
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Subdiv2D> > obj_;

/// edge types for option processing
const ConstMap<string,int> EdgeTypeMap = ConstMap<string,int>
    ("NextAroundOrg",   cv::Subdiv2D::NEXT_AROUND_ORG)
    ("NextAroundDst",   cv::Subdiv2D::NEXT_AROUND_DST)
    ("PrevAroundOrg",   cv::Subdiv2D::PREV_AROUND_ORG)
    ("PrevAroundDst",   cv::Subdiv2D::PREV_AROUND_DST)
    ("NextAroundLeft",  cv::Subdiv2D::NEXT_AROUND_LEFT)
    ("NextAroundRight", cv::Subdiv2D::NEXT_AROUND_RIGHT)
    ("PrevAroundLeft",  cv::Subdiv2D::PREV_AROUND_LEFT)
    ("PrevAroundRight", cv::Subdiv2D::PREV_AROUND_RIGHT);

/// inverse point location types for option processing
const ConstMap<int,string> PointLocationInvMap = ConstMap<int,string>
    (cv::Subdiv2D::PTLOC_ERROR,        "Error")
    (cv::Subdiv2D::PTLOC_OUTSIDE_RECT, "OutsideRect")
    (cv::Subdiv2D::PTLOC_INSIDE,       "Inside")
    (cv::Subdiv2D::PTLOC_VERTEX,       "Vertex")
    (cv::Subdiv2D::PTLOC_ON_EDGE,      "OnEdge");
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Arguments vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk((nrhs==2 || nrhs==3) && nlhs<=1);
        obj_[++last_id] = (nrhs == 3) ?
            makePtr<Subdiv2D>(rhs[2].toRect()) : makePtr<Subdiv2D>();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<Subdiv2D> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "initDelaunay") {
        nargchk(nrhs==3 && nlhs==0);
        obj->initDelaunay(rhs[2].toRect());
    }
    else if (method == "insert") {
        nargchk(nrhs==3);
        if (rhs[2].isNumeric() && rhs[2].numel() == 2) {
            nargchk(nlhs<=1);
            int curr_point = obj->insert(rhs[2].toPoint2f());
            plhs[0] = MxArray(curr_point);
        }
        else {
            nargchk(nlhs==0);
            obj->insert(rhs[2].toVector<Point2f>());
        }
    }
    else if (method == "locate") {
        nargchk(nrhs==3 && nlhs<=3);
        Point2f pt(rhs[2].toPoint2f());
        int edge, vertex;
        int location = obj->locate(pt, edge, vertex);
        plhs[0] = MxArray(PointLocationInvMap[location]);
        if (nlhs > 1)
            plhs[1] = MxArray(edge);
        if (nlhs > 2)
            plhs[2] = MxArray(vertex);
    }
    else if (method == "findNearest") {
        nargchk(nrhs==3 && nlhs<=2);
        Point2f pt(rhs[2].toPoint2f()), nearestPt;
        int vertex = obj->findNearest(pt, (nlhs>1) ? &nearestPt : NULL);
        plhs[0] = MxArray(vertex);
        if (nlhs > 1)
            plhs[1] = MxArray(nearestPt);
    }
    else if (method == "getEdgeList") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<Vec4f> edgeList;
        obj->getEdgeList(edgeList);
        plhs[0] = MxArray(edgeList);
    }
    else if (method == "getTriangleList") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<Vec6f> triangleList;
        obj->getTriangleList(triangleList);
        plhs[0] = MxArray(triangleList);
    }
    else if (method == "getVoronoiFacetList") {
        nargchk(nrhs==3 && nlhs<=2);
        vector<int> idx(rhs[2].toVector<int>());
        vector<vector<Point2f> > facetList;
        vector<Point2f> facetCenters;
        obj->getVoronoiFacetList(idx, facetList, facetCenters);
        plhs[0] = MxArray(facetList);
        if (nlhs > 1)
            plhs[1] = MxArray(facetCenters);
    }
    else if (method == "getVertex") {
        nargchk(nrhs==3 && nlhs<=2);
        int vertex = rhs[2].toInt();
        int firstEdge = 0;
        Point2f pt = obj->getVertex(vertex, (nlhs>1) ? &firstEdge : NULL);
        plhs[0] = MxArray(pt);
        if (nlhs > 1)
            plhs[1] = MxArray(firstEdge);
    }
    else if (method == "getEdge") {
        nargchk(nrhs==4 && nlhs<=1);
        int edge = rhs[2].toInt();
        int nextEdgeType = EdgeTypeMap[rhs[3].toString()];
        int e = obj->getEdge(edge, nextEdgeType);
        plhs[0] = MxArray(e);
    }
    else if (method == "nextEdge") {
        nargchk(nrhs==3 && nlhs<=1);
        int edge = rhs[2].toInt();
        int e = obj->nextEdge(edge);
        plhs[0] = MxArray(e);
    }
    else if (method == "rotateEdge") {
        nargchk(nrhs==4 && nlhs<=1);
        int edge = rhs[2].toInt();
        int rotate = rhs[3].toInt();
        int e = obj->rotateEdge(edge, rotate);
        plhs[0] = MxArray(e);
    }
    else if (method == "symEdge") {
        nargchk(nrhs==3 && nlhs<=1);
        int edge = rhs[2].toInt();
        int e = obj->symEdge(edge);
        plhs[0] = MxArray(e);
    }
    else if (method == "edgeOrg") {
        nargchk(nrhs==3 && nlhs<=2);
        int edge = rhs[2].toInt();
        Point2f orgpt;
        int e = obj->edgeOrg(edge, (nlhs>1) ? &orgpt : NULL);
        plhs[0] = MxArray(e);
        if (nlhs > 1)
            plhs[1] = MxArray(orgpt);
    }
    else if (method == "edgeDst") {
        nargchk(nrhs==3 && nlhs<=2);
        int edge = rhs[2].toInt();
        Point2f dstpt;
        int e = obj->edgeDst(edge, (nlhs>1) ? &dstpt : NULL);
        plhs[0] = MxArray(e);
        if (nlhs > 1)
            plhs[1] = MxArray(dstpt);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
