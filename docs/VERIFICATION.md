# Verification

Tested locally with MATLAB R2026a Update 5 (26.1.0.3346908), using base MATLAB. Only MATLAB, Simulink and System Composer were installed; additional research toolboxes were not assumed available.

## Passed

20 ray-plane geometry cases matched both the legacy entry point exactly and an analytical reference within 1e-12. Headers for all 136 bundled MATLAB data files were readable.

[SOURCE-MANIFEST.json](SOURCE-MANIFEST.json) remains the unchanged historical 165-file original snapshot. The current gate verifies 163 original files byte for byte and 2 intentionally modified TV solver files against separately pinned [original/current hashes](SOURCE-MODIFICATIONS.json). This establishes the declared source identities, not scientific replication. New wrappers and smoke checks remain separate. The two numerical corrections are described below.

## Reproduce

From the repository root in MATLAB:

```matlab
run('tests/smoke_test.m')
```

The test uses only local synthetic inputs or bundled data. It does not acquire or transmit signals. Assertions fail if a checked condition is not satisfied.

## Hosted checks

The **Verify CornerVision** GitHub Actions workflow runs the smoke check in base MATLAB R2026a on a standard macOS runner. It checks all 165 current file hashes before and after MATLAB runs: 163 against the original snapshot and 2 against the explicit modification record.

For the separate CPU resource check, run the workflow manually and select `candidate`. This evaluates one full 3969-by-1044 forward matrix at the measured occluder corner, using the original final-stage sampling, followed by the original economy singular-value decomposition and RGB projection norms. It prints a compact JSON result. The calculation has a five-minute step limit; the whole job has a fifteen-minute limit. These limits do not provide an instantaneous memory cap.

This candidate check does not execute the 305-candidate localization search, reconstruct an image or establish position accuracy. It does not modify the current research-function or capture bytes; the two TV solver corrections are separate from this localization calculation.

For the complete CPU localization calculation, select `localization`. The collector runs the unchanged default `table_S1.m` mushroom script in a separate workspace and checks completion of all three stages. The preserved source prescribes 125, 90 and 90 candidates, 305 in total; the collector does not instrument the candidate count. It reports the final position, all three stage estimates and raw distances to the measured corner and the estimate reported in a source comment. These distances are observations, with no accuracy pass threshold. The calculation has a sixty-minute step limit and a seventy-five-minute job limit. Only a compact JSON summary is printed; the workflow does not upload captures, figures or MAT files. The completed default mushroom run is recorded in [localization results](LOCALIZATION_RESULT.md).

## Limits

Full image reconstructions, occluder optimization, and figure replication were not run in the recorded geometry check. The image scripts allocate GPU arrays and need Parallel Computing Toolbox with a supported NVIDIA GPU. The total-variation solvers also call `nansum` from Statistics and Machine Learning Toolbox. The unchanged source configures capture paths for macOS and Windows, not Linux. Header validation does not establish every dataset variable is semantically valid.

The separate `table_S1.m` localization path uses CPU forward models and singular-value decomposition. Its original `parfor` loop can run serially in base MATLAB; this differs from the image scripts' unconditional GPU allocations. The complete default mushroom localization executed successfully; this does not establish an accuracy threshold or verify the GPU image workflows. These runtime requirements do not change the original research files or their license scope.

The facade restores the MATLAB search path after a call. The geometry facade preserves its legacy output and behavior. TV solver stopping behavior has the two explicit corrections below. No new underlying research algorithm is claimed.


## TV solver corrections, 2026-10-23

`Functions/reconstruct_tv.m` and `Functions/reconstruct_tv_it_cbg.m` intentionally differ from the original source. A finite zero-cost fixed point now has zero relative objective change instead of 0/0. The iterative file consistently uses its documented `tol` field and the singular `constraint` field. Nonzero objective division, fixed-iteration behavior, outer iteration budgets, FISTA updates, operators, regularization, initialization and public signatures are unchanged. The historical source manifest has not been regenerated; [SOURCE-MODIFICATIONS.json](SOURCE-MODIFICATIONS.json) records both original and current hashes at repository baseline `039a01131ab8420b3633c0258aa1f9cc5217f6f9`.

Retained native diagnostic evidence used MATLAB R2026a Update 5. Unchanged functions first failed because `nansum` was unavailable. With an explicit test-only bridge that accepts finite vectors and calls built-in `sum`, each original zero fixture reached its solver body and was externally stopped eight seconds after fixture entry. No production cap was added. The candidate returned finite zero/constant/varying 2×2 RGB fixtures; 18 local-helper nonzero comparisons and one complete varying RGB comparison were bitwise equal to baseline. The basic helper's fixed-iteration branch also matched. This is bounded synthetic diagnostic evidence, not a research image result, global convergence proof or retained scientific-result parity.

The finite-vector bridge is not shipped and is not a production dependency replacement. `nansum` and the documented GPU/toolbox requirements remain. Other nonconverging or nonfinite inputs, invalid tolerances, arbitrary regularization and GPU operation remain unverified. There is no new iteration cap, failure/error policy, validation or dependency change. The recorded localization result above remains a historical run of its recorded source revision, not a fresh result from this correction.
