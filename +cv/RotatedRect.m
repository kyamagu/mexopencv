classdef RotatedRect
    %ROTATEDRECT  The class represents rotated (i.e. not up-right) rectangles on a plane.
    %
    % Each rectangle is specified by the center point (mass center), length of
    % each side (represented by `[width,height]`) and the rotation angle in
    % degrees.
    %
    % See also: cv.CamShift, cv.fitEllipse, cv.minAreaRect
    %

    methods (Static)
        function pts = points(rrect)
            %POINTS  Returns 4 vertices of the rectangle
            %
            %    pts = cv.RotatedRect.points(rrect)
            %
            % ## Input
            % * __rrect__ rotated rectangle. A structure with the following
            %       fields:
            %       * __center__ The rectangle mass center `[x,y]`.
            %       * __size__ Width and height of the rectangle `[w,h]`.
            %       * __angle__ The rotation angle in a clockwise direction.
            %             When the angle is 0, 90, 180, 270 etc., the
            %             rectangle becomes an up-right rectangle.
            %
            % ## Output
            % * __pts__ 4-by-2 points matrix of the rectangle vertices.
            %       `[x1 y1; x2 y2; x3 y3; x4 y4]`
            %
            % See also: cv.boxPoints, bbox2points
            %
            pts = RotatedRect_('points', rrect);
        end

        function rect = boundingRect(rrect)
            %BOUNDINGRECT  Returns the minimal up-right rectangle containing the rotated rectangle
            %
            %    rect = cv.RotatedRect.boundingRect(rrect)
            %
            % ## Input
            % * __rrect__ rotated rectangle. A structure with the following
            %       fields:
            %       * __center__ The rectangle mass center `[x,y]`.
            %       * __size__ Width and height of the rectangle `[w,h]`.
            %       * __angle__ The rotation angle in a clockwise direction.
            %             When the angle is 0, 90, 180, 270 etc., the
            %             rectangle becomes an up-right rectangle.
            %
            % ## Output
            % * __rect__ bounding rectangle, a 1-by-4 vector `[x, y, w, h]`
            %
            rect = RotatedRect_('boundingRect', rrect);
        end

        function rrect = from3points(pt1, pt2, pt3)
            %FROM3POINTS  Create a rotated rectangle from 3 points
            %
            %    rrect = cv.RotatedRect.from3points(pt1, pt2, pt3)
            %
            % ## Input
            % * __pt1__, __pt2__, __pt3__ Any 3 end points `[x,y]` of the
            %       rotated rectangle. They must be given in order (either
            %       clockwise or anticlockwise).
            %
            % ## Output
            % * __rrect__ output rotated rectangle. A structure with the
            %       following fields:
            %       * __center__ The rectangle mass center `[x,y]`.
            %       * __size__ Width and height of the rectangle `[w,h]`.
            %       * __angle__ The rotation angle in a clockwise direction.
            %             When the angle is 0, 90, 180, 270 etc., the
            %             rectangle becomes an up-right rectangle.
            %
            rrect = RotatedRect_('from3points', pt1, pt2, pt3);
        end
    end

end
