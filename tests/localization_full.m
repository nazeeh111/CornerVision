function localization_full()
% Run the unchanged default table_S1 localization, including all three stages.
% Report raw position differences; there is no scientific accuracy pass gate.

sourceRoot = fileparts(fileparts(mfilename('fullpath')));
runnerTemp = getenv('RUNNER_TEMP');
if isempty(runnerTemp)
    outputRoot = tempname;
else
    outputRoot = tempname(runnerTemp);
end
[created, message] = mkdir(outputRoot);
assert(created, 'Cannot create localization summary directory: %s', message);
priorPath = path;
priorFolder = pwd;
cleanup = onCleanup(@() restore_session(priorFolder, priorPath)); %#ok<NASGU>
cd(sourceRoot);
addpath(fullfile(sourceRoot, 'Functions'));

record.kind = 'full_original_default_localization';
record.status = 'started';
record.full_localization_executed = false;
record.full_image_reconstruction = false;
record.accuracy_gate_defined = false;
record.source_lineage_head = '095fdaac622b3a4b136b6e35b7e0733de83d46cd';
record.matlab_release = version('-release');
record.matlab_version = version;
record.parallel_toolbox_installed = ~isempty(ver('parallel'));
record.parallel_license_test = license('test', 'Distrib_Computing_Toolbox');
record.started_utc = char(datetime('now', 'TimeZone', 'UTC', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX'));
started = tic;

try
    assert(strcmp(record.matlab_release, '2026a'), 'Expected MATLAB R2026a');
    assert(~record.parallel_toolbox_installed, ...
        'Full localization requires base MATLAB with no Parallel Computing Toolbox.');
    assert(ismac || ispc, 'Original configuration supports macOS and Windows paths.');
    assert(strcmp(which('table_S1'), fullfile(sourceRoot, 'table_S1.m')), ...
        'Unexpected source resolution: table_S1');
    needed = {'load_experiment_config_data_localization', 'load_image1', ...
              'SimulateA_OccluderEstimation', 'SimulateForwardModelPerBlock', ...
              'occluderposgridsearch'};
    for i = 1:numel(needed)
        assert(strcmp(which(needed{i}), ...
            fullfile(sourceRoot, 'Functions', [needed{i} '.m'])), ...
            'Unexpected source resolution: %s', needed{i});
    end
    fprintf('LOCALIZATION: running unchanged table_S1 default mushroom search\n');
    result = run_original_localization();
    assert(strcmp(result.scene, 'mushroom') && strcmp(result.configuration, 'TestPosD11'));
    assert(result.numPixels == 1008 && result.downsampling_passes == 4);
    assert(result.N_oneparam == 30 && result.n_iter == 3 && result.final_iteration == 3);
    assert(isequal(result.coarse_grid_shape, [5 5 5]));
    assert(isequal(result.final_grid_shape, [1 30 1]));
    assert(isequal(result.range_vals, [0.025 0.0125 0.00625 0.003125]*4));
    assert(result.sigma_th1 == 0.75 && result.sigma_th2 == 0.2 && result.sigma_th_final == 0.02);
    assert(result.initial_Ndiscr_mon == 1 && result.final_Ndiscr_mon == 10);
    assert(result.viewAngleCorrection && ~result.useEstimatedOccPos && result.bgSub == 0);
    assert(isequal(result.scene_patch_shape, [29 36]));
    assert(isequal(result.capture_size, [63 63 3]) && result.capture_finite);
    assert(isequal(result.ground_truth_size, [29 36 3]) && result.ground_truth_finite);
    assert(result.D == 1.03 && isequal(result.Occ_LLcorner, [0.470 result.D-0.460 0.2040]));
    assert(isequal(result.Occ_size, [0.077 0 0.075]));
    assert(isequal(result.config_occluder, [result.Occ_LLcorner; result.Occ_LLcorner + result.Occ_size]));
    assert(isequal(size(result.p_est_all), [3 3]) && all(isfinite(result.p_est_all(:))));
    assert(isequal(size(result.p_est), [1 3]) && all(isfinite(result.p_est)));
    finalManuscript = result.p_est_all(end,:);
    finalManuscript(2) = result.D - finalManuscript(2);
    assert(isequal(result.p_est, finalManuscript), 'Unexpected final y-coordinate transformation');

    record.scene = result.scene;
    record.capture_name = 'Data/TestPosD11/image_test_mushroom20.mat';
    record.capture_size = result.capture_size;
    record.ground_truth_size = result.ground_truth_size;
    record.numPixels = result.numPixels;
    record.downsampling_passes = result.downsampling_passes;
    record.N_oneparam = result.N_oneparam;
    record.completed_stages = result.final_iteration;
    record.coarse_grid_shape = result.coarse_grid_shape;
    % Counts are derived from the preserved source, not runtime instrumentation.
    record.candidate_count_basis = 'prescribed_by_source_not_dynamically_instrumented';
    record.prescribed_candidates_per_stage = [prod(result.coarse_grid_shape), ...
        3*result.N_oneparam, 3*result.N_oneparam];
    record.prescribed_candidates_total = sum(record.prescribed_candidates_per_stage);
    record.sigma_thresholds = [result.sigma_th1 result.sigma_th2 result.sigma_th_final];
    record.final_Ndiscr_mon = result.final_Ndiscr_mon;
    record.D_m = result.D;
    record.p_est_all_internal_m = result.p_est_all;
    record.p_est_manuscript_m = result.p_est;
    record.measured_corner_internal_m = result.Occ_LLcorner;
    record.measured_corner_manuscript_m = [result.Occ_LLcorner(1), ...
        result.D-result.Occ_LLcorner(2), result.Occ_LLcorner(3)];
    record.source_comment_reported_mushroom_corner_manuscript_m = [0.4583 0.4892 0.2026];
    record.position_difference_to_measured_euclidean_m = ...
        norm(result.p_est-record.measured_corner_manuscript_m);
    record.position_difference_to_source_comment_euclidean_m = ...
        norm(result.p_est-record.source_comment_reported_mushroom_corner_manuscript_m);
    record.total_seconds = toc(started);
    record.full_localization_executed = true;
    record.status = 'full_default_completed';
    record.finished_utc = char(datetime('now', 'TimeZone', 'UTC', ...
        'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX'));
    save_record(outputRoot, record);
    fprintf('PASS LOCALIZATION EXECUTION: all three original stages completed; no accuracy gate or image reconstruction\n');
catch err
    record.status = 'failed';
    record.total_seconds = toc(started);
    record.error_identifier = err.identifier;
    record.error_message = err.message;
    save_record(outputRoot, record);
    rethrow(err);
end
end

function result = run_original_localization()
% Ordinary separate workspace: the source's clear variables cannot erase
% the caller's timer, summary directory, or path/folder cleanup object.
run('table_S1.m');
result.p_est = p_est;
result.p_est_all = p_est_all;
result.D = D;
result.Occ_LLcorner = Occ_LLcorner;
result.Occ_size = Occ_size;
result.config_occluder = simuParams.Occluder;
result.scene = testscene;
result.configuration = filename;
result.numPixels = numPixels;
result.downsampling_passes = downsamp_factor;
result.N_oneparam = N_oneparam;
result.n_iter = n_iter;
result.final_iteration = ii;
result.coarse_grid_shape = [IIx IIy IIz];
result.final_grid_shape = II;
result.range_vals = range_vals;
result.sigma_th1 = sigma_th1;
result.sigma_th2 = sigma_th2;
result.sigma_th_final = sigma_th;
result.initial_Ndiscr_mon = Ndiscr_mon;
result.final_Ndiscr_mon = simuParams.Ndiscr_mon;
result.viewAngleCorrection = viewAngleCorrection;
result.useEstimatedOccPos = useEstimatedOccPos;
result.bgSub = bgSub;
result.scene_patch_shape = NumBlocks_sim;
result.capture_size = size(camera_capture);
result.capture_finite = all(isfinite(camera_capture(:)));
result.ground_truth_size = size(ground_truth1);
result.ground_truth_finite = all(isfinite(ground_truth1(:)));
end

function save_record(outputRoot, record)
summary = jsonencode(record);
fid = fopen(fullfile(outputRoot, 'localization-summary.json'), 'w');
assert(fid ~= -1, 'Cannot write localization summary');
guard = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', summary);
fprintf('%s\n', summary);
end

function restore_session(priorFolder, priorPath)
cd(priorFolder);
path(priorPath);
end
