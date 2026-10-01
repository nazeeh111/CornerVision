function localization_candidate()
% One original CPU forward matrix and SVD/projection at the measured corner.
% This is not table_S1, a position search, reconstruction, or accuracy test.
% The hosted job bounds VM/runtime use, not instantaneous RSS or cleanup.

sourceRoot = fileparts(fileparts(mfilename('fullpath')));
runnerTemp = getenv('RUNNER_TEMP');
if isempty(runnerTemp)
    outputRoot = tempname;
else
    outputRoot = tempname(runnerTemp);
end
[created, message] = mkdir(outputRoot);
assert(created, 'Cannot create candidate summary directory: %s', message);
priorPath = path;
priorFolder = pwd;
cleanup = onCleanup(@() restore_session(priorFolder, priorPath)); %#ok<NASGU>
cd(sourceRoot);
addpath(fullfile(sourceRoot, 'Functions'));

record.kind = 'one_original_CPU_candidate';
record.full_localization_executed = false;
record.full_reconstruction_executed = false;
record.accuracy_evaluated = false;
record.candidates_evaluated = 0;
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
        'This candidate requires base MATLAB with no Parallel Computing Toolbox.');
    assert(ismac || ispc, 'Original configuration supports macOS and Windows paths.');
    needed = {'load_experiment_config_data_localization', 'load_image1', ...
              'SimulateA_OccluderEstimation', 'SimulateForwardModelPerBlock', ...
              'occluderposgridsearch'};
    for i = 1:numel(needed)
        resolved = which(needed{i});
        expected = fullfile(sourceRoot, 'Functions', [needed{i} '.m']);
        assert(strcmp(resolved, expected), 'Unexpected source resolution: %s', needed{i});
    end
    % Unchanged table_S1 mushroom configuration and bundled capture.
    numPixels = 1008;
    Ndiscr_mon = 1;
    viewAngleCorrection = true;
    useEstimatedOccPos = false;
    load_experiment_config_data_localization;
    downsamp_factor = 4;
    assert(strcmp(filename, 'TestPosD11'));
    assert(isequal(NumBlocks_sim, [29 36]));
    assert(isequal(Occ_LLcorner, [0.470 D-0.460 0.2040]));
    assert(isequal(simuParams.Occluder, [Occ_LLcorner; Occ_LLcorner + Occ_size]));
    assert(simuParams.numPixels == 1008 && simuParams.viewAngleCorrection);
    [camera_capture, ground_truth1] = load_image1( ...
        'image_test_mushroom20.mat', datafilepath, downsamp_factor);
    assert(isequal(size(camera_capture), [63 63 3]));
    assert(isequal(size(ground_truth1), [29 36 3]));
    assert(all(isfinite(camera_capture(:))));
    assert(all(isfinite(ground_truth1(:))));
    record.capture_name = 'Data/TestPosD11/image_test_mushroom20.mat';
    record.capture_size = size(camera_capture);
    record.capture_class = class(camera_capture);
    record.capture_min = min(camera_capture(:));
    record.capture_max = max(camera_capture(:));
    record.capture_sum_rgb = reshape(sum(sum(camera_capture, 1), 2), 1, 3);
    record.ground_truth_size = size(ground_truth1);
    record.measured_corner_internal_m = Occ_LLcorner;
    record.measured_corner_manuscript_m = [Occ_LLcorner(1), D-Occ_LLcorner(2), Occ_LLcorner(3)];
    % Original final y-refinement sampling, evaluated at ONE measured corner.
    simuParams.Ndiscr_mon = 10;
    record.Ndiscr_mon = simuParams.Ndiscr_mon;
    record.downsampling_passes = downsamp_factor;
    fprintf('CANDIDATE forward matrix: 3969x1044; Ndiscr_mon=10; measured corner\n');
    matrixStarted = tic;
    [simA, ~] = SimulateA_OccluderEstimation(simuParams, downsamp_factor);
    record.forward_seconds = toc(matrixStarted);
    assert(isequal(size(simA), [3969 1044]));
    assert(all(isfinite(simA(:))));
    record.candidates_evaluated = 1;
    record.matrix_size = size(simA);
    record.matrix_class = class(simA);
    info = whos('simA');
    record.matrix_bytes = info.bytes;
    record.matrix_min = min(simA(:));
    record.matrix_max = max(simA(:));
    record.matrix_frobenius_norm = norm(simA, 'fro');
    fprintf('CANDIDATE forward matrix finished; starting original economy SVD\n');
    svdStarted = tic;
    [U, S, ~] = svd(simA, 'econ');
    record.svd_seconds = toc(svdStarted);
    singular_values = diag(S);
    assert(isequal(size(U), [3969 1044]) && isequal(size(S), [1044 1044]));
    assert(all(isfinite(U(:))) && all(isfinite(singular_values)) && singular_values(1) > 0);
    sigma_th = 0.02; % Unchanged third-stage mushroom threshold.
    vecS = diag(S)/S(1);
    K = min(sum(vecS > sigma_th), 10);
    assert(K >= 1 && K <= 10);
    projection_norm_rgb = zeros(1, 3);
    for c = 1:3
        channel = camera_capture(:,:,c);
        projection_norm_rgb(c) = norm(U(:,1:K)'*channel(:));
    end
    assert(all(isfinite(projection_norm_rgb)));
    record.U_size = size(U);
    record.S_size = size(S);
    record.sigma_threshold = sigma_th;
    record.singular_values_above_threshold = sum(vecS > sigma_th);
    record.singular_vectors_used = K;
    record.projection_norm_rgb = projection_norm_rgb;
    record.singular_value_max = singular_values(1);
    record.singular_value_min = singular_values(end);
    record.total_seconds = toc(started);
    record.status = 'one_candidate_completed';
    record.finished_utc = char(datetime('now', 'TimeZone', 'UTC', ...
        'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX'));
    save_record(outputRoot, record);
    fprintf('PASS CANDIDATE: one matrix/SVD/projection; no search, reconstruction, or accuracy test\n');
catch err
    record.status = 'failed';
    record.total_seconds = toc(started);
    record.error_identifier = err.identifier;
    record.error_message = err.message;
    save_record(outputRoot, record);
    rethrow(err);
end
end

function save_record(outputRoot, record)
summary = jsonencode(record);
fid = fopen(fullfile(outputRoot, 'candidate-summary.json'), 'w');
assert(fid ~= -1, 'Cannot write candidate summary');
guard = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', summary);
fprintf('%s\n', summary);
end

function restore_session(priorFolder, priorPath)
cd(priorFolder);
path(priorPath);
end
