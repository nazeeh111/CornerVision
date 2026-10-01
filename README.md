# CornerVision

MATLAB code and bundled measurements for [*Computational periscopy with an ordinary digital camera*](https://www.nature.com/articles/s41586-018-0868-6), by Charles Saunders, John Murray-Bruce and Vivek K Goyal (Nature, 2019).

This repository preserves the [authors' computational source and data](https://github.com/Computational-Periscopy/Ordinary-Camera) and adds setup documentation, verification checks and a `corner_vision` alias for the ray–plane intersection helper. The reconstruction and occluder-localization workflows remain the original MATLAB scripts.

## Geometry helper

For the ray–plane intersection helper, run from the repository root:

```matlab
point = corner_vision([0 0 0], [1 2 3], [0 1 0], [0 1 0]);
```

This computes a geometry point; it does not reconstruct an image. The alias preserves the original helper's arguments, errors and output.

## Inputs and workflows

For complete image reconstructions, start with fig4_column_c.m, fig4_column_d.m, or fig4_column_e.m. These scripts use GPU arrays and require Parallel Computing Toolbox with a supported NVIDIA GPU. The total-variation solvers also call the statistics function `nansum`. The unchanged data-path setup covers macOS and Windows; Linux paths are not configured.

Supplemental image experiments are fig_S1_S2.m, fig_S9.m, fig_S14.m, fig_S15.m and fig_S16.m. They share the GPU requirement. The separate table_S1.m occluder-localization workflow uses CPU arrays; see [verification details](docs/VERIFICATION.md) for its tested scope. Run from the repository root. Bundled Data measurements are retained. The optional stack_combine helper uses the statistics function nanmedian.

## Verification

Run `run('tests/smoke_test.m')` from the repository root. GitHub Actions also offers manual `candidate` and complete default `localization` CPU checks. See [verification details](docs/VERIFICATION.md) for their scope, runtime limits and execution status. The original computational source and bundled measurements are retained byte-for-byte.

## License

MIT covers CornerVision's added entry point, tests, documentation and artwork. It does not relicense the original research code or measurement data; see [NOTICE](NOTICE) for source attribution and scope.
