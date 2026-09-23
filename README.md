![CornerVision](docs/banner.svg)

# CornerVision

Ordinary-camera computational periscopy: calibrated forward models, occluder localization, and hidden-scene reconstruction.

> **Development history:** Developed locally using Git before publication. These projects were published to GitHub together, so similar upload dates do not indicate when development began.

## Quick start

Open MATLAB in this repository, then use the branded entry point:

```matlab
point = corner_vision([0 0 0], [1 2 3], [0 1 0], [0 1 0]);
```

The entry point preserves the existing function's arguments, errors, and numerical output. Existing script and function names remain available for compatibility. No sensor starts when you open this repository.

## Inputs and workflows

For complete image reconstructions, start with fig4_column_c.m, fig4_column_d.m, or fig4_column_e.m. Supplemental experiments are fig_S1_S2.m, fig_S9.m, fig_S14.m, fig_S15.m, fig_S16.m and table_S1.m. Run from the repository root. Bundled Data measurements are retained. Full image workflows require Image Processing Toolbox; stack_combine uses nanmedian.

## Verification

Run `run('tests/smoke_test.m')` from the repository root. See [verification details](docs/VERIFICATION.md) for the tested scope and unavailable checks. Computational source and bundled scientific assets are retained byte-for-byte; the added facade and documentation provide the new presentation.

## License

MIT covers the authorized first-party code and new presentation. Separately owned notices embedded in source remain applicable.
