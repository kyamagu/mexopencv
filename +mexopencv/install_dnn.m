function install_dnn(source)
    %INSTALL_DNN Copies DNN network files in mexopencv
    %
    %   install_dnn(source)
    %
    % where source is a zipfile containing networks.
    
    if exist(source, 'file')
        unzip(source, fullfile(mexopencv.root, 'test'));
    end
end