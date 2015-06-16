classdef Subdiv2D < handle
    %SUBDIV2D  Delaunay triangulation and Voronoi tesselation
    %
    % See also: delaunay, DelaunayTri, delaunayTriangulation,
    %    voronoi, TriRep, triangulation,
    %    triplot, dsearchn, tsearchn
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = Subdiv2D(varargin)
            %SUBDIV2D  Constructor
            %
            %    obj = cv.Subdiv2D()
            %    obj = cv.Subdiv2D(rect)
            %
            % ## Input
            % * __rect__ `[x,y,w,h]`
            %
            % The second form is equivalent to creating an empty object, then
            % calling the `initDelaunay` method.
            %
            % See also: cv.Subdiv2D.initDelaunay
            %
            this.id = Subdiv2D_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.Subdiv2D
            %
            Subdiv2D_(this.id, 'delete');
        end

        function initDelaunay(this, rect)
            %INITDELAUNAY  Initialize
            %
            %    obj.initDelaunay(rect)
            %
            % ## Input
            % * __rect__ `[x,y,w,h]`
            %
            % See also: cv.Subdiv2D.Subdiv2D
            %
            Subdiv2D_(this.id, 'initDelaunay', rect);
        end

        function varargout = insert(this, pt)
            %INSERT  Insert point or points
            %
            %    obj.insert(pt)
            %    curr_point = obj.insert(pt)
            %    obj.insert(pts)
            %
            % ## Input
            % * __pt__ point `[x,y]`
            % * __pts__ vector of points.
            %
            % ## Output
            % * **curr_point**
            %
            if nargout > 0
                varargout{1} = Subdiv2D_(this.id, 'insert', pt);
            else
                Subdiv2D_(this.id, 'insert', pt);
            end
        end

        function [location, edge, vertex] = locate(this, pt)
            %LOCATE  Locate point (triangulate)
            %
            %    [location, edge, vertex] = obj.locate(pt)
            %
            % ## Input
            % * __pt__ `[x,y]`
            %
            % ## Output
            % * __location__ One of:
            %       * __Error__
            %       * __OutsideRect__
            %       * __Inside__
            %       * __Vertex__
            %       * __OnEdge__
            % * __edge__
            % * __vertex__
            %
            [location, edge, vertex] = Subdiv2D_(this.id, 'locate', pt);
        end

        function [vertex, nearestPt] = findNearest(this, pt)
            %FINDNEAREST  Find nearest vertex to a query point
            %
            %    [vertex, nearestPt] = obj.findNearest(pt)
            %
            % ## Input
            % * __pt__ `[x,y]`
            %
            % ## Output
            % * __vertex__
            % * __nearestPt__ `[x,y]`
            %
            [vertex, nearestPt] = Subdiv2D_(this.id, 'findNearest', pt);
        end

        function edgeList = getEdgeList(this)
            %GETEDGELIST  Return edges list
            %
            %    edgeList = obj.getEdgeList()
            %
            % ## Output
            % * __edgeList__ `{[p1x,p1y, p2x,p2y], ...}`
            %
            % See also: cv.Subdiv2D.getTriangleList
            %
            edgeList = Subdiv2D_(this.id, 'getEdgeList');
        end

        function triangleList = getTriangleList(this)
            %GETTRIANGLELIST  Return triangles list
            %
            %    triangleList = obj.getTriangleList()
            %
            % ## Output
            % * __triangleList__ `{[p1x,p1y, p2x,p2y, p3x,p3y], ...}`
            %
            % See also: cv.Subdiv2D.getEdgeList
            %
            triangleList = Subdiv2D_(this.id, 'getTriangleList');
        end

        function [facetList, facetCenters] = getVoronoiFacetList(this, idx)
            %GETVORONOIFACETLIST  Return Voronoi facets
            %
            %    [facetList, facetCenters] = obj.getVoronoiFacetList(idx)
            %
            % ## Input
            % * __idx__ vector of integers
            %
            % ## Output
            % * __facetList__ array of array of points `{{[x,y], ...}, ...}`
            % * __facetCenters__ vector of points `{[x,y], ...}`
            %
            % See also: cv.Subdiv2D.getEdgeList, cv.Subdiv2D.getTriangleList
            %
            [facetList, facetCenters] = Subdiv2D_(this.id, 'getVoronoiFacetList', idx);
        end

        function [pt, firstEdge] = getVertex(this, vertex)
            %getVertex  Return point by vertex index
            %
            %    [pt, firstEdge] = obj.getVertex(vertex)
            %
            % ## Input
            % * __vertex__
            %
            % ## Output
            % * __pt__ `[x,y]`
            % * __firstEdge__
            %
            % See also: cv.Subdiv2D.getEdge
            %
            [pt, firstEdge] = Subdiv2D_(this.id, 'getVertex', vertex);
        end

        function e = getEdge(this, edge, nextEdgeType)
            %GETEDGE  Get edge
            %
            %    e = obj.getEdge(edge, nextEdgeType)
            %
            % ## Input
            % * __edge__
            % * __nextEdgeType__ One of:
            %       * __NextAroundOrg__
            %       * __NextAroundDst__
            %       * __PrevAroundOrg__
            %       * __PrevAroundDst__
            %       * __NextAroundLeft__
            %       * __NextAroundRight__
            %       * __PrevAroundLeft__
            %       * __PrevAroundRight__
            %
            % ## Output
            % * __e__
            %
            % See also: cv.Subdiv2D.getVertex
            %
            e = Subdiv2D_(this.id, 'getEdge', edge, nextEdgeType);
        end

        function e = nextEdge(this, edge)
            %NEXTEDGE  Get next edge
            %
            %    e = obj.nextEdge(edge)
            %
            % ## Input
            % * __edge__
            %
            % ## Output
            % * __e__
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'nextEdge', edge);
        end

        function e = rotateEdge(this, edge, rotate)
            %ROTATEEDGE  Rotate edge
            %
            %    e = obj.rotateEdge(edge, rotate)
            %
            % ## Input
            % * __edge__
            % * __rotate__
            %
            % ## Output
            % * __e__
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'rotateEdge', edge, rotate);
        end

        function e = symEdge(this, edge)
            %SYMEDGE  Sym edge
            %
            %    e = obj.symEdge(edge)
            %
            % ## Input
            % * __edge__
            %
            % ## Output
            % * __e__
            %
            % See also: cv.Subdiv2D.getEdge
            %
            e = Subdiv2D_(this.id, 'symEdge', edge);
        end

        function [e, orgpt] = edgeOrg(this, edge)
            %EDGEORG  Edge origin
            %
            %    [e, orgpt] = obj.edgeOrg(edge)
            %
            % ## Input
            % * __edge__
            %
            % ## Output
            % * __e__
            % * __orgpt__ `[x,y]`
            %
            % See also: cv.Subdiv2D.edgeDst
            %
            [e, orgpt] = Subdiv2D_(this.id, 'edgeOrg', edge);
        end

        function [e, dstpt] = edgeDst(this, edge)
            %EDGEDST  Edge destination
            %
            %    [e, dstpt] = obj.edgeDst(edge)
            %
            % ## Input
            % * __edge__
            %
            % ## Output
            % * __e__
            % * __dstpt__ `[x,y]`
            %
            % See also: cv.Subdiv2D.edgeOrg
            %
            [e, dstpt] = Subdiv2D_(this.id, 'edgeDst', edge);
        end
    end

end
