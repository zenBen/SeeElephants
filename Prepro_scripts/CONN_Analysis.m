function batch = CONN_Analysis(batch, varargin)
%% CONN_ANALYSIS 1st level analysis batch specification
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

%Sequential number identifying each set of independent first-level analyses
p.addParameter('analysis_num', 1, @isscalar)
%1=ROI-to-ROI analysis, 2= seed-to-voxel analysis, 3= both;
p.addParameter('analysis_type', 3, @(x) ismember(x, 1:3))
% connectivity measure: 
% 1 = 'correlation (bivariate)', 
% 2 = 'correlation (semipartial)', 
% 3 = 'regression (bivariate)', 
% 4 = 'regression (multivariate)'
p.addParameter('analysis_measure', 1, @(x) ismember(x, 1:4))
% within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
p.addParameter('within_weight', 2, @(x) ismember(x, 1:3))

%TODO: SET SOME SMART DEFAULTS (e.g. default to all ROIs)
p.addParameter('sources_names', {}, @iscellstr)
p.addParameter('sources_dims', 0, @isscalar)
p.addParameter('sources_deriv', 1, @isscalar)

p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for level 1 analysis
batch.Analysis.analysis_number = Arg.analysis_num;
batch.Analysis.type = Arg.analysis_type;
batch.Analysis.measure = Arg.analysis_measure;
batch.Analysis.weight = Arg.within_weight;

batch.Analysis.sources.names = Arg.sources_names;
ns = numel(Arg.sources_names);
batch.Analysis.sources.dimensions = repmat({Arg.sources_dims}, 1, ns);
batch.Analysis.sources.deriv = repmat({Arg.sources_deriv}, 1, ns);


%% Add other top-level fields of batch.Analysis based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.Analysis.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
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