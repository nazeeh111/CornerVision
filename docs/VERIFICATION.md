# Verification

Tested locally with MATLAB R2026a Update 5 (26.1.0.3346908), using base MATLAB. Only MATLAB, Simulink and System Composer were installed; additional research toolboxes were not assumed available.

## Passed

20 ray-plane geometry cases matched both the legacy entry point exactly and an analytical reference within 1e-12. Headers for all 136 bundled MATLAB data files were readable.

The 165 retained source and asset files in [SOURCE-MANIFEST.json](SOURCE-MANIFEST.json) are SHA-256 identical to the pre-rebrand snapshot. This establishes source and asset preservation, not full scientific replication. New wrappers and smoke checks are separate from those files. No computational core was rewritten.

## Reproduce

From the repository root in MATLAB:

```matlab
run('tests/smoke_test.m')
```

The test uses only local synthetic inputs or bundled data. It does not acquire or transmit signals. Assertions fail if a checked condition is not satisfied.

## Hosted checks

The **Verify CornerVision** GitHub Actions workflow runs the smoke check in base MATLAB R2026a on a standard macOS runner. It checks all 165 retained file hashes before and after MATLAB runs.

For the separate CPU resource check, run the workflow manually and select `candidate`. This evaluates one full 3969-by-1044 forward matrix at the measured occluder corner, using the original final-stage sampling, followed by the original economy singular-value decomposition and RGB projection norms. It prints a compact JSON result. The calculation has a five-minute step limit; the whole job has a fifteen-minute limit. These limits do not provide an instantaneous memory cap.

This candidate check does not execute the 305-candidate localization search, reconstruct an image or establish position accuracy. It leaves the retained research functions and captures unchanged.

For the complete CPU localization calculation, select `localization`. The collector runs the unchanged default `table_S1.m` mushroom script in a separate workspace and checks completion of all three stages. The preserved source prescribes 125, 90 and 90 candidates, 305 in total; the collector does not instrument the candidate count. It reports the final position, all three stage estimates and raw distances to the measured corner and the estimate reported in a source comment. These distances are observations, with no accuracy pass threshold. The calculation has a sixty-minute step limit and a seventy-five-minute job limit. Only a compact JSON summary is printed; the workflow does not upload captures, figures or MAT files. The completed default mushroom run is recorded in [localization results](LOCALIZATION_RESULT.md).

## Limits

Full image reconstructions, occluder optimization, and figure replication were not run in the recorded geometry check. The image scripts allocate GPU arrays and need Parallel Computing Toolbox with a supported NVIDIA GPU. The total-variation solvers also call `nansum` from Statistics and Machine Learning Toolbox. The unchanged source configures capture paths for macOS and Windows, not Linux. Header validation does not establish every dataset variable is semantically valid.

The separate `table_S1.m` localization path uses CPU forward models and singular-value decomposition. Its original `parfor` loop can run serially in base MATLAB; this differs from the image scripts' unconditional GPU allocations. The complete default mushroom localization executed successfully; this does not establish an accuracy threshold or verify the GPU image workflows. These runtime requirements do not change the original research files or their license scope.

The facade restores the MATLAB search path after a call. Legacy figure output and computational behavior are preserved. This release has new branding, documentation, artwork, and an entry-point facade; it does not claim a new underlying research algorithm.
