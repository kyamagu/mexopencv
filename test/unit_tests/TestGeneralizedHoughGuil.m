classdef TestGeneralizedHoughGuil
    %TestGeneralizedHoughGuil

    methods (Static)
        function test_1
            hough = cv.GeneralizedHoughGuil();
            [img, tmpl] = sample_data();
            hough.setTemplate(tmpl);
            [pos,votes] = hough.detect(img);
            assert(iscell(pos) && iscell(votes));
            assert(isequal(numel(pos), numel(votes)));
            if ~isempty(pos)
                assert(all(cellfun(@numel,pos) == 4));
                assert(all(cellfun(@numel,votes) == 3));
            end
        end

        function test_2
            hough = cv.GeneralizedHoughGuil();
            [img, tmpl] = sample_data();
            [edges, dx, dy] = calcEdges(tmpl);
            hough.setTemplate(edges, dx, dy);
            [pos,votes] = hough.detect(img);
        end

        function test_3
            hough = cv.GeneralizedHoughGuil();
            [img, tmpl] = sample_data();
            hough.setTemplate(tmpl);
            [edges, dx, dy] = calcEdges(img);
            [pos,votes] = hough.detect(edges, dx, dy);
        end
    end

end

function [img, tmpl] = sample_data()
    img = zeros(200,200,'uint8');
    img(20:50,20:50) = 255;
    img(120:150,120:150) = 255;

    tmpl = zeros(50,50,'uint8');
    tmpl(10:40,10:40) = 255;
end

function [edges, dx, dy] = calcEdges(img)
    edges = cv.Canny(img, [50 100]);
    dx = cv.Sobel(img, 'DDepth','single', 'XOrder',1, 'YOrder',0);
    dy = cv.Sobel(img, 'DDepth','single', 'XOrder',0, 'YOrder',1);
end
