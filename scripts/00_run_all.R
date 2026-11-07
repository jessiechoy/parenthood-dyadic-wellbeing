# =========================================================================
# 00_run_all.R
# Runs the full analysis pipeline for the transition-to-parenthood study.
#
# The pipeline has two segments separated by a manual Mplus step:
#   1. Scripts 01-09: data cleaning through Mplus data export
#   2. After running Mplus models 10a-10f: figures and tables
#
# Within each segment, scripts run sequentially.
# =========================================================================

library(here)
library(rmarkdown)

render_step <- function(f) {
  message("\n========================================")
  message("  ", f)
  message("========================================\n")
  render(here(f), quiet = TRUE, envir = new.env())
  message("  -> done\n")
}

# -------------------------------------------------------------------------
# SEGMENT 1: Data cleaning, sample construction, covariate preparation
# -------------------------------------------------------------------------

render_step("01_datacleaning_primary_cleaned.Rmd")
render_step("02_sample_construction_updated.Rmd")
render_step("03_covariates_ipw_sample_backfill.Rmd")
render_step("04_reshape_couple_wide.Rmd")

# -------------------------------------------------------------------------
# SEGMENT 2: Imputation, diagnostics, weighting, Mplus data export
#
# NOTE: Script 05 runs MICE with M=20, MAXIT=20. This takes time.
# -------------------------------------------------------------------------

render_step("05_mice_imputation_clean.Rmd")
render_step("06_mice_diagnostics_final.Rmd")
render_step("07b_entropy_ATT_primary.Rmd")
render_step("07c_covariate_balance_loveplot.Rmd")
render_step("08_weighting_sensitivity_final.Rmd")
render_step("09_prepare_mplus_weighted_outcomes.Rmd")

stop(
  "\n",
  "========================================\n",
  "  MANUAL STEP: Run Mplus models\n",
  "========================================\n",
  "\n",
  "Run the following .inp files in Mplus:\n",
  "  10a_primary_preliminary_free_variances.inp\n",
  "  10b_primary_jump_variances_zero.inp\n",
  "  10c_primary_control_male_preslope_zero.inp\n",
  "  10e_primary_final_complete_hypothesis_tests.inp       (PRIMARY)\n",
  "  10e_sensitivity_ato_final_hypothesis_tests.inp        (ATO sensitivity)\n",
  "  10e_sensitivity_rel5_age2_att_final.inp               (Restricted-support sensitivity)\n",
  "  10a_sensitivity_rel5_age2_att_free_variances.inp      (Restricted-support preliminary)\n",
  "  10f_unweighted_robustness_final.inp                   (Unweighted robustness)\n",
  "\n",
  "Then source() this file again to continue from the next line.\n"
)

# -------------------------------------------------------------------------
# SEGMENT 3: Figures and tables (post-Mplus)
# -------------------------------------------------------------------------

render_step("10_figure1_trajectories.Rmd")
render_step("12_sample_flowchart_compact.Rmd")
render_step("covariate_balance_signed_final.Rmd")
render_step("14_dyadic_concordance_table_Times_New_Roman.Rmd")
render_step("15_sensitivity_robustness_coefficient_plot_journal_color_clean.Rmd")

message("\n========================================")
message("  PIPELINE COMPLETE")
message("========================================\n")
