classdef TestBlender
    %TestBlender

    methods (Static)
        function test_1
            btypes = {'FeatherBlender', 'MultiBandBlender'};
            for i=1:numel(btypes)
                obj = cv.Blender(btypes{i});
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                %{
                %TODO
                obj.prepare(corners, sizes);
                obj.feed(img, mask, tl);
                [dst, dst_mask] = obj.blend();
                %}
            end
        end
    end

end
