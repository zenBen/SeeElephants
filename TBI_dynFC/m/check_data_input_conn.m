clear all

%% Load CONN project Setup
% project_path='E:\TBI\CONN\Pre_post\Intervention_period';
cd (project_path)

%%
var='CONN_x';
CONN_x_N24_2ses_BCrep=load('conn_TBI_N24_BCrep.mat', var);
CONN_x_N24_2ses_BCrep=CONN_x_N24_2ses_BCrep.(var);
CONN_x_N24_2ses=load('conn_TBI_N24_2sessions_intervention.mat', var);
CONN_x_N24_2ses=CONN_x_N24_2ses.(var);

%% Check functional inputs
funct_first_CONN_x_N24_2ses_BCrep = cell(24,1); funct_first_CONN_x_N24_2ses = cell(24,1);
funct_last_CONN_x_N24_2ses_BCrep = cell(24,1); funct_last_CONN_x_N24_2ses = cell(24,1);
for pa=1:24
    [~, funct_first_CONN_x_N24_2ses_BCrep{pa,1}, ~] = fileparts(CONN_x_N24_2ses_BCrep.Setup.functional{1,pa}{1,1}{1,3}(1).fname);
    [~, funct_first_CONN_x_N24_2ses{pa,1}, ~] = fileparts(CONN_x_N24_2ses.Setup.functional{1,pa}{1,1}{1,3}(1).fname);
    slashix = strfind(funct_first_CONN_x_N24_2ses{pa, :}, '\');
    funct_first_CONN_x_N24_2ses{pa,1}(1:slashix(end)) = [];
    [~, funct_last_CONN_x_N24_2ses_BCrep{pa,1}, ~] = fileparts(CONN_x_N24_2ses_BCrep.Setup.functional{1,pa}{1,1}{1,3}(2).fname);
    [~, funct_last_CONN_x_N24_2ses{pa,1}, ~] = fileparts(CONN_x_N24_2ses.Setup.functional{1,pa}{1,1}{1,3}(2).fname);
    slashix = strfind(funct_last_CONN_x_N24_2ses{pa, :}, '\');
    funct_last_CONN_x_N24_2ses{pa,1}(1:slashix(end)) = [];
end

% Compare filenames from both projects
cmpfirst = ~cellfun(@strcmp, funct_first_CONN_x_N24_2ses_BCrep, funct_first_CONN_x_N24_2ses);
cmplast = ~cellfun(@strcmp, funct_last_CONN_x_N24_2ses_BCrep, funct_last_CONN_x_N24_2ses);

if any(cmpfirst)
    disp([funct_first_CONN_x_N24_2ses_BCrep{cmpfirst}; funct_first_CONN_x_N24_2ses{cmpfirst}])
end
if any(cmplast)
    disp([funct_last_CONN_x_N24_2ses_BCrep{cmplast}; funct_last_CONN_x_N24_2ses{cmplast}])
end


%% Check structural inputs
struct_CONN_x_N24_2ses_BCrep = cell(24,1); struct_CONN_x_N24_2ses = cell(24,1);
for pa=1:24
    [~, struct_CONN_x_N24_2ses_BCrep{pa,1}, ~] = fileparts(CONN_x_N24_2ses_BCrep.Setup.structural{1,pa}{1,2}{1,1});
    [~, struct_CONN_x_N24_2ses{pa,1}, ~] = fileparts(CONN_x_N24_2ses.Setup.structural{1,pa}{1,2}{1,1});
    slashix = strfind(struct_CONN_x_N24_2ses{pa, :}, '\');
    struct_CONN_x_N24_2ses{pa,1}(1:slashix(end)) = [];
end

% Compare filenames from both projects
cmpstruct = ~cellfun(@strcmp, struct_CONN_x_N24_2ses_BCrep, struct_CONN_x_N24_2ses);

if any(cmpstruct)
    disp({struct_CONN_x_N24_2ses_BCrep{cmpstruct}; struct_CONN_x_N24_2ses{cmpstruct}})
end