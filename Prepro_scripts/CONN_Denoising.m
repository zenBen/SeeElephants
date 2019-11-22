function batch = CONN_Denoising(batch, varargin)
%% CONN_DENOISE function used to set confound names and values
% 
% Varargin
%   confoundname    cell string array, confound names can be: any ROI name, 
%                   any covariate name, or 'Effect of *' where * represents 
%                   any condition name
%                   Default = 'Grey Matter', 'White Matter', 'CSF'
%   
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

p.addParameter('confoundname', {'Grey Matter' 'White Matter', 'CSF'}, @iscellstr)
p.addParameter('confounddim', {3, 3, 6}, @(x) iscell(x) || isnumeric(x))
p.addParameter('confoundderiv', {0, 0, 1}, @(x) iscell(x) || isnumeric(x))
p.addParameter('confoundpower', {1, 1, 1}, @(x) iscell(x) || isnumeric(x))
p.addParameter('confoundfilt', {0, 0, 0}, @(x) iscell(x) || isnumeric(x))

p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for denoising
batch.Denoising.confounds.names = Arg.confoundname;

if isnumeric(Arg.confounddim)
    for ci = 1:numel(Arg.confoundname)
        batch.Denoising.confounds.dimensions{ci} = Arg.confounddim;
    end
else
    batch.Denoising.confounds.dimensions = Arg.confounddim;
end

if isnumeric(Arg.confoundderiv)
    for ci = 1:numel(Arg.confoundname)
        batch.Denoising.confounds.deriv{ci} = Arg.confoundderiv;
    end
else
    batch.Denoising.confounds.deriv = Arg.confoundderiv;
end

if isnumeric(Arg.confoundpower)
    for ci = 1:numel(Arg.confoundname)
        batch.Denoising.confounds.power{ci} = Arg.confoundpower;
    end
else
    batch.Denoising.confounds.power = Arg.confoundpower;
end

if isnumeric(Arg.confoundfilt)
    for ci = 1:numel(Arg.confoundname)
        batch.Denoising.confounds.filter{ci} = Arg.confoundfilt;
    end
else
    batch.Denoising.confounds.filter = Arg.confoundfilt;
end


%% Add other top-level fields of batch.Analysis based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.Denoising.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
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
