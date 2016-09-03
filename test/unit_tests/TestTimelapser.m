classdef TestTimelapser
    %TestTimelapser

    methods (Static)
        function test_1
            ttypes = {'AsIs', 'Crop'};
            for i=1:numel(ttypes)
                obj = cv.Timelapser(ttypes{i});
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                %{
                %TODO
                obj.initialize(corners, sizes);
                obj.process(img, mask, tl);
                dst = obj.getDst();
                %}
            end
        end
    end

end
