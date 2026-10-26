# Localization figure source map

Editable landscape master: [`figures/localization-method.svg`](figures/localization-method.svg). Responsive phone artwork: [`figures/localization-method-portrait.svg`](figures/localization-method-portrait.svg). Both show the default mushroom localization documented in `table_S1.m` and `Functions/occluderposgridsearch.m`; neither claims a new computation.

| SVG group | Source fact |
| --- | --- |
| `measurement` | The camera capture is split into `meas.r`, `meas.g` and `meas.b` in `table_S1.m` (lines 75–79). |
| `schedule-to-candidate` | The default search schedule supplies candidate grid positions to the localization routine (`table_S1.m`, lines 90–130). |
| `candidate`, `forward-model` | Each selected candidate sets the occluder position and simulates `A(p_o)` in `Functions/occluderposgridsearch.m` (lines 69–78). |
| `svd-modes` | Economy SVD; singular values normalized by the largest; modes above `sigma_th` counted and capped at 10 for projection (`occluderposgridsearch.m`, lines 81–84). |
| `measurement-to-score`, `retained-modes-to-score`, `projection-score`, `channel-maxima` | The RGB measurements and the candidate-derived retained left singular modes both feed the projection scores; each channel selects its maximum-scoring candidate (`occluderposgridsearch.m`, lines 81–108). |
| `channel-mean` | The three channel-wise candidate positions are averaged (`occluderposgridsearch.m`, line 111). |
| `stage-schedule` | Default mushroom: 5×5×5 initial joint grid; then x, z, y coordinate refinements with 30 samples per coordinate; three total stages: one global search plus two refinement rounds (`table_S1.m`, lines 58–64, 81–86, 90–130). |
| `coordinate-conversion` | Final y conversion `p_est(2)=D-p_est(2)` (`table_S1.m`, line 142); `D=1.03 m` for this experiment (`docs/LOCALIZATION_RESULT.md`). |
| `recorded-result` | Estimate, measured position, raw distance, run date, and no-threshold limitation (`docs/LOCALIZATION_RESULT.md`). |

The diagrams' RGB marks and corner glyph are explanatory vector symbols, not camera output or a reconstruction. The README `<picture>` element selects the portrait file below 600 CSS pixels and retains the landscape file as its desktop fallback. The artwork uses the existing README identity colors: navy `#081526` and teal `#53dec7` from `docs/banner.svg`, with muted blue-gray and restrained channel colors for legibility.
