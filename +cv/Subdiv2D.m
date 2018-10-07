classdef Subdiv2D < handle
    %SUBDIV2D  Delaunay triangulation and Voronoi tessellation
    %
    % ## Planar Subdivision
    %
    % The cv.Subdiv2D class described in this section is used to perform
    % various planar subdivision on a set of 2D points (represented as vector
    % of 2D-points `[x,y]`). OpenCV subdivides a plane into triangles using
    % the Delaunay's algorithm, which corresponds to the dual graph of the
    % Voronoi diagram. In the figure below, the Delaunay's triangulation is
    % marked with black lines and the Voronoi diagram with red lines.
    %
    % ![image](https://github.com/opencv/opencv/raw/3.2.0/modules/imgproc/doc/pics/delaunay_voronoi.png)
    %
    % The subdivisions can be used for the 3D piece-wise transformation of a
    % plane, morphing, fast location of points on the plane, building special
    % graphs (such as NNG,RNG), and so forth.
    %
    % See also: delaunay, DelaunayTri, delaunayTriangulation, voronoi, TriRep,
    %  triangulation, triplot, dsearchn, tsearchn
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = Subdiv2D(varargin)
            %SUBDIV2D  Constructor
            %
            %     obj = cv.Subdiv2D()
            %     obj = cv.Subdiv2D(rect)
            %
            % ## Input
            % * __rect__ Rectangle `[x,y,w,h]` that includes all of the 2D
            %   points that are to be added to the subdivision.
            %
            % Creates an empty Delaunay subdivision object.
            % The second form is equivalent to creating an empty object, then
            % calling the `initDelaunay` method.
            %
            % This creates an empty Delaunay subdivision where 2D points can
            % be added using the function cv.Subdiv2D.insert. All of the
            % points to be added must be within the specified rectangle,
            % otherwise a runtime error is raised.
            %
            % See also: cv.Subdiv2D.initDelaunay
            %
            this.id = Subdiv2D_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Subdiv2D
            %
            if isempty(this.id), return; end
            Subdiv2D_(this.id, 'delete');
        end

        function initDelaunay(this, rect)
            %INITDELAUNAY  Initialize
            %
            %     obj.initDelaunay(rect)
            %
            % ## Input
            % * __rect__ Rectangle `[x,y,w,h]` that includes all of the 2D
            %   points that are to be added to the subdivision.
            %
            % See also: cv.Subdiv2D.Subdiv2D
            %
            Subdiv2D_(this.id, 'initDelaunay', rect);
        end

        function varargout = insert(this, pt)
            %INSERT  Insert a single point or multiple points into a Delaunay triangulation
            %
            %     obj.insert(pt)
            %     curr_point = obj.insert(pt)
            %     obj.insert(pts)
            %
            % ## Input
            % * __pt__ Point to insert `[x,y]`
            % * __pts__ vector of points to insert `{[x,y], ...}`.
            %
            % ## Output
            % * **curr_point** the ID of the point.
            %
            % The function inserts a single point or a vector of points into a
            % subdivision and modifies the subdivision topology appropriately.
            % If a point with the same coordinates exists already, no new
            % point is added.
            %
            % NOTE: If the point is outside of the triangulation specified
            % `rect` a runtime error is raised.
            %
            % See also: cv.Subdiv2D.Subdiv2D, cv.Subdiv2D.initDelaunay
            %
            if nargout > 0
                varargout{1} = Subdiv2D_(this.id, 'insert', pt);
            else
                Subdiv2D_(this.id, 'insert', pt);
            end
        end

        function [location, edge, vertex] = locate(this, pt)
            %LOCATE  Returns the location of a point within a Delaunay triangulation
            %
            %     [location, edge, vertex] = obj.locate(pt)
            %
            % ## Input
            % * __pt__ Point `[x,y]` to locate.
            %
            % ## Output
            % * __location__ a string which specifies one of the following
            %   five cases for point location:
            %   * __Inside__ The point falls into some facet. The function
            %     returns 'Inside' and edge will contain one of edges of the
            %     facet.
            %   * __OnEdge__ The point falls onto the edge. The function
            %     returns 'OnEdge' and edge will contain this edge.
            %   * __Vertex__ The point coincides with one of the subdivision
            %     vertices. The function returns 'Vertex' and vertex will
            %     contain a pointer to the vertex.
            %   * __OutsideRect__ The point is outside the subdivision
            %     reference rectangle. The function returns 'OutsideRect' and
            %     no other outputs are filled.
            %   * __Error__ Point location error. One of input arguments is
            %     invalid. A runtime error is raised or, if silent or "parent"
            %     error processing mode is selected, 'Error' is returned.
            % * __edge__ Output edge that the point belongs to or is located
            %   to the right of it.
            % * __vertex__ Optional output vertex the input point coincides
            %   with.
            %
            % The function locates the input point within the subdivision and
            % gives one of the triangle edges or vertices.
            %
            % See also: cv.Subdiv2D.findNearest
            %
            [location, edge, vertex] = Subdiv2D_(this.id, 'locate', pt);
        end

        function [vertex, nearestPt] = findNearest(this, pt)
            %FINDNEAREST  Finds the subdivision vertex closest to the given point
            %
            %     [vertex, nearestPt] = obj.findNearest(pt)
            %
            % ## Input
            % * __pt__ Input point `[x,y]`
            %
            % ## Output
            % * __vertex__ vertex ID.
            % * __nearestPt__ Output subdivision vertex point `[x,y]`.
            %
            % The function is another function that locates the input point
            % within the subdivision. It finds the subdivision vertex that is
            % the closest to the input point. It is not necessarily one of
            % vertices of the facet containing the input point, though the
            % facet (located using cv.Subdiv2D.locate) is used as a starting
            % point.
            %
            % See also: cv.Subdiv2D.locate
            %
            [vertex, nearestPt] = Subdiv2D_(this.id, 'findNearest', pt);
        end

        function edgeList = getEdgeList(this)
            %GETEDGELIST  Returns a list of all edges
            %
            %     edgeList = obj.getEdgeList()
            %
            % ## Output
            % * __edgeList__ Output vector `{[p1x,p1y, p2x,p2y], ...}`.
            %
            % The function gives each edge as a 4 numbers vector, where each
            % two are one of the edge vertices. i.e. `org_x = v[0]`,
            % `org_y = v[1]`, `dst_x = v[2]`, `dst_y = v[3]`.
            %
            % See also: cv.Subdiv2D.getTriangleList
            %
            edgeList = Subdiv2D_(this.id, 'getEdgeList');
        end

        function leadingEdgeList = getLeadingEdgeList(this)
            %GETLEADINGEDGELIST  Returns a list of the leading edge ID connected to each triangle
            %
            %     leadingEdgeList = obj.getLeadingEdgeList()
            %
            % ## Output
            % * __leadingEdgeList__ Output vector.
            %
            % The function gives one edge ID for each triangle.
            %
            % See also: cv.Subdiv2D.getTriangleList
            %
            leadingEdgeList = Subdiv2D_(this.id, 'getLeadingEdgeList');
        end

        function triangleList = getTriangleList(this)
            %GETTRIANGLELIST  Returns a list of all triangles
            %
            %     triangleList = obj.getTriangleList()
            %
            % ## Output
            % * __triangleList__ Output vector
            %   `{[p1x,p1y, p2x,p2y, p3x,p3y], ...}`.
            %
            % The function gives each triangle as a 6 numbers vector, where
            % each two are one of the triangle vertices. i.e. `p1_x = v[0]`,
            % `p1_y = v[1]`, `p2_x = v[2]`, `p2_y = v[3]`, `p3_x = v[4]`,
            % `p3_y = v[5]`.
            %
            % See also: cv.Subdiv2D.getEdgeList
            %
            triangleList = Subdiv2D_(this.id, 'getTriangleList');
        end

        function [facetList, facetCenters] = getVoronoiFacetList(this, idx)
            %GETVORONOIFACETLIST  Returns a list of all Voroni facets
            %
            %     [facetList, facetCenters] = obj.getVoronoiFacetList(idx)
            %
            % ## Input
            % * __idx__ Vector of vertices IDs to consider. For all vertices
            %   you can pass empty vector.
            %
            % ## Output
            % * __facetList__ Output vector of the Voroni facets, an array of
            %   array of points `{{[x,y], ...}, ...}`.
            % * __facetCenters__ Output vector of the Voroni facets center
            %   points, a vector of points `{[x,y], ...}`.
            %
            % See also: cv.Subdiv2D.getEdgeList, cv.Subdiv2D.getTriangleList
            %
            [facetList, facetCenters] = Subdiv2D_(this.id, 'getVoronoiFacetList', idx);
        end

        function [pt, firstEdge] = getVertex(this, vertex)
            %GETVERTEX  Returns vertex location from vertex ID
            %
            %     [pt, firstEdge] = obj.getVertex(vertex)
            %
            % ## Input
            % * __vertex__ vertex ID.
            %
            % ## Output
            % * __pt__ vertex `[x,y]`.
            % * __firstEdge__ Optional. The first edge ID which is connected
            %   to the vertex.
            %
            % See also: cv.Subdiv2D.getEdge
            %
            [pt, firstEdge] = Subdiv2D_(this.id, 'getVertex', vertex);
        end

        function e = getEdge(this, edge, nextEdgeType)
            %GETEDGE  Returns one of the edges related to the given edge
            %
            %     e = obj.getEdge(edge, nextEdgeType)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            % * __nextEdgeType__ Parameter specifying which of the related
            %   edges to return. The following edge type navigation values are
            %   possible:
            %   * __NextAroundOrg__ next around the edge origin (`eOnext` on
            %     the picture below if `e` is the input edge).
            %   * __NextAroundDst__ next around the edge vertex (`eDnext`).
            %   * __PrevAroundOrg__ previous around the edge origin
            %     (reversed `eRnext`).
            %   * __PrevAroundDst__ previous around the edge destination
            %     (reversed `eLnext`).
            %   * __NextAroundLeft__ next around the left facet (`eLnext`).
            %   * __NextAroundRight__ next around the right facet (`eRnext`).
            %   * __PrevAroundLeft__ previous around the left facet
            %     (reversed `eOnext`).
            %   * __PrevAroundRight__ previous around the right facet
            %     (reversed `eDnext`).
            %
            % ## Output
            % * __e__ edge ID related to the input edge.
            %
            % A sample output is shown below:
            %
            % ![image](https://github.com/opencv/opencv/raw/master/modules/imgproc/doc/pics/quadedge.png)
            %
            % See also: cv.Subdiv2D.getVertex
            %
            e = Subdiv2D_(this.id, 'getEdge', edge, nextEdgeType);
        end

        function e = nextEdge(this, edge)
            %NEXTEDGE  Returns next edge around the edge origin
            %
            %     e = obj.nextEdge(edge)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            %
            % ## Output
            % * __e__ an integer which is next edge ID around the edge origin
            %   (`eOnext` on the picture shown if `e` is the input edge).
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'nextEdge', edge);
        end

        function e = rotateEdge(this, edge, rotate)
            %ROTATEEDGE  Returns another edge of the same quad-edge
            %
            %     e = obj.rotateEdge(edge, rotate)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            % * __rotate__ Parameter specifying which of the edges of the same
            %   quad-edge as the input one to return. The following values are
            %   possible:
            %   * __0__ the input edge (`e` on the picture shown if `e` is the
            %     input edge).
            %   * __1__ the rotated edge (`eRot`).
            %   * __2__ the reversed edge (reversed `e` (in green)).
            %   * __3__ the reversed rotated edge (reversed `eRot` (in green)).
            %
            % ## Output
            % * __e__ one of the edges ID of the same quad-edge as the input
            %   edge.
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'rotateEdge', edge, rotate);
        end

        function e = symEdge(this, edge)
            %SYMEDGE  Sym edge
            %
            %     e = obj.symEdge(edge)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            %
            % ## Output
            % * __e__
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'symEdge', edge);
        end

        function [e, orgpt] = edgeOrg(this, edge)
            %EDGEORG  Returns the edge origin
            %
            %     [e, orgpt] = obj.edgeOrg(edge)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            %
            % ## Output
            % * __e__ vertex ID.
            % * __orgpt__ Output vertex location `[x,y]`.
            %
            % See also: cv.Subdiv2D.edgeDst
            %
            [e, orgpt] = Subdiv2D_(this.id, 'edgeOrg', edge);
        end

        function [e, dstpt] = edgeDst(this, edge)
            %EDGEDST  Returns the edge destination
            %
            %     [e, dstpt] = obj.edgeDst(edge)
            %
            % ## Input
            % * __edge__ Subdivision edge ID.
            %
            % ## Output
            % * __e__ vertex ID.
            % * __dstpt__ Output vertex location `[x,y]`.
            %
            % See also: cv.Subdiv2D.edgeOrg
            %
            [e, dstpt] = Subdiv2D_(this.id, 'edgeDst', edge);
        end
    end

end
