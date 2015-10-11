classdef TestSubdiv2D
    %TestSubdiv2D

    methods (Static)
        function testGetTriangleList
            s2d = cv.Subdiv2D([0, 0, 50, 50]);
            s2d.insert([10, 10]);
            s2d.insert([20, 10]);
            s2d.insert([20, 20]);
            s2d.insert([10, 20]);
            triangles = s2d.getTriangleList();
            assert(iscell(triangles) && numel(triangles) == 10);
            assert(isvector(triangles{1}) && numel(triangles{1}) == 6);
        end

        function testGetEdgeList
            s2d = cv.Subdiv2D();
            s2d.initDelaunay([0, 0, 50, 50]);
            s2d.insert([10, 10; 20, 10; 20, 20; 10, 20]);
            edges = s2d.getEdgeList();
            assert(iscell(edges));
            assert(isvector(edges{1}) && numel(edges{1}) == 4);
        end

        function testGetVoronoiFacetList
            s2d = cv.Subdiv2D([0, 0, 50, 50]);
            s2d.insert([10, 10; 20, 10; 20, 20; 10, 20]);
            [faces,centers] = s2d.getVoronoiFacetList([]);
            assert(iscell(faces) && iscell(centers));
            assert(numel(faces) == numel(centers));

            faces = cellfun(@(f) cat(1,f{:}), faces, 'UniformOutput',false);
            [~,ncols] = cellfun(@size, faces);
            assert(all(ncols == 2));

            centers = cat(1,centers{:});
            assert(size(centers,2) == 2);
        end

        function testLocate
            s2d = cv.Subdiv2D([0, 0, 50, 50]);
            s2d.insert([10, 10; 20, 10; 20, 20; 10, 20]);
            [loc,edge,vertex] = s2d.locate([16, 17]);
            assert(strcmp(loc,'Inside'));
            [loc,edge,vertex] = s2d.locate([10, 10]);
            assert(strcmp(loc,'Vertex'));
            [loc,edge,vertex] = s2d.locate([11, 11]);
            assert(strcmp(loc,'OnEdge'));
            %[loc,edge,vertex] = s2d.locate([nan, nan]);
            %assert(strcmp(loc,'Error'));
        end

        function testFindNearest
            s2d = cv.Subdiv2D([0, 0, 50, 50]);
            s2d.insert([10, 10; 20, 10; 20, 20; 10, 20]);
            [vertex,pt] = s2d.findNearest([18, 19]);
            assert(isequal(pt, [20 20]));

            [p,e] = s2d.getVertex(vertex);
            assert(isequal(p, pt));
        end

        function test_error_1
            try
                cv.Subdiv2D('foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
