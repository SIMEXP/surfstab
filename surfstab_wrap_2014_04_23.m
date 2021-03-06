%% Wrapper for functional data
clear;

% Outline
% 1) Get the mask and the func files
% 2) Use niak_brick_tseries to get the tseries from the files
% 3) Use niak_brick_neighbour to build a neighbourhood from a mask
% 4) Store the timeseries in a mat. Store the neighbourhood in a mat
% 5) Run the files through our pipeline.

in_path = '/home/sebastian/Projects/niak_multiscale/data/func/';
out_path = '/home/sebastian/Projects/niak_multiscale/data/func/kmeans_test/';
if ~psom_exist(out_path)
    psom_mkdir(out_path);
end

fmri = [in_path 'fmri_0051173_session_1_run1.nii'];
mask = [in_path 'mask.nii'];
in_ts.fmri = {fmri};
in_ts.mask = mask;
out_ts.tseries = {[out_path 'tseries.mat']};

opt_ts.flag_all = true;
% Run the tseries brick
niak_brick_tseries(in_ts,out_ts,opt_ts);

% Run the neighbour brick
out_neigh = [out_path 'neigh.mat'];
niak_brick_neighbour(mask, out_neigh, struct);

% Bring things into the big pipeline
in.data = out_ts.tseries{1};
in.neigh = out_neigh;
opt.name_data = 'tseries_1';
opt.name_neigh = 'neig';
opt.scale = [4 16 32];

% Set up pipeline parameters
opt.folder_out = [out_path];
opt.region_growing.thre_size = 100;
opt.stability_atom.nb_batch = 10;
opt.stability_vertex.nb_batch = 10;
opt.stability_vertex.clustering.type = 'kmeans';
% Sampling
opt.sampling.type = 'bootstrap';
% Flags
opt.target_type = 'plugin';
opt.consensus.scale_target = [4 8 16];
opt.flag_cores = false;
opt.flag_rand = false;
opt.flag_verbose = true;
opt.flag_test = false;
opt.psom.flag_pause = true;


fprintf('Start');
pipe = niak_pipeline_stability_surf(in,opt);

fprintf('EOF\n');