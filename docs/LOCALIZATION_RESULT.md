# Default mushroom localization

On 1 October 2026, [hosted run 36885002157](https://github.com/nazeeh111/CornerVision/actions/runs/36885002157) executed the unchanged `table_S1.m` at commit `339dbedceda21a0823476876fc18de97dd50223e` in base MATLAB R2026a Update 5 on a standard macOS runner. No Parallel Computing Toolbox was installed.

All three stages completed in **1187.912 seconds**. The preserved source prescribes 125, 90 and 90 candidates, 305 total; the collector does not instrument individual candidate calls. Both before/after checks verified all 165 retained source and asset hashes.

| Position, manuscript coordinates in metres | x | y | z |
| --- | --- | --- | --- |
| Executed estimate | 0.4583333333 | 0.4891954023 | 0.2025862069 |
| Estimate reported in the original source comment | 0.4583 | 0.4892 | 0.2026 |
| Original measured corner | 0.4700 | 0.4600 | 0.2040 |

The executed estimate rounds to the source comment's displayed values. Its Euclidean distance to that rounded reference is **0.036366 mm**; its distance to the measured corner is **31.471915 mm**. These are raw comparisons. No accuracy pass threshold is defined.

The final y coordinate is `D - y_internal`, with `D = 1.03 m`, exactly as in the original script. The collector checks that conversion and finite estimates for all three stages.

This verifies execution of the original default mushroom localization, not image reconstruction, other scenes, every candidate's intermediate values, hardware accuracy, peak memory or complete paper replication. The algorithm, capture and reference coordinates are from Saunders, Murray-Bruce and Goyal's [original research source](https://github.com/Computational-Periscopy/Ordinary-Camera); [NOTICE](../NOTICE) records attribution and license scope.
