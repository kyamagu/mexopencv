classdef TestSeamFinder
    %TestSeamFinder

    methods (Static)
        function test_1
            stypes = {'VoronoiSeamFinder', 'DpSeamFinder', 'GraphCutSeamFinder'};
            for i=1:numel(stypes)
                obj = cv.SeamFinder(stypes{i});
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                %TODO
                %masks = obj.find(src, corners, masks);
            end
        end
    end

end
