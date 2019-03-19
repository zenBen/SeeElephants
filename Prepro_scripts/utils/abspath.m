function abspath = abspath(relpath)
    tmp = pwd;
    if ~isfolder(relpath), mkdir(relpath); end
%     abspath = validpath(relpath);
    cd(relpath)
    abspath = pwd;
    cd(tmp)
end