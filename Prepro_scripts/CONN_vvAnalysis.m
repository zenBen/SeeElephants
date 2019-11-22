function batch = CONN_vvAnalysis(batch, varargin)
%% CONN_VV_ANALYSIS 1st level voxel-to-voxel analysis batch specification
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)


p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for level 1 v2v analysis


%% Add other top-level fields of batch.vvAnalysis based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.vvAnalysis.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
end


%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

end