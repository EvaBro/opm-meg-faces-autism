rm(list = ls())
graphics.off()

library(readxl)
library(ggplot2) # For plots
library(tidyr) # For data frame manipulation
library(dplyr) # For data frame manipulation
library(lme4)     # For LME model
library(lmerTest) # For ANOVA based on LME
library(effectsize) # For effect sizes (eta-squared)
library(MuMIn) # For R-squared
library(emmeans) # For effect sizes (Cohen's d) for specific contracts
library(performance) # For marginal and conditional R squared; model diagnostics (check_model)
library(ggeffects)




# Load and structure data -------------------------------------------------

# Load in data
df <- read_excel(path = "Y:/projects/OPM-Analysis/OPM_faces_ASDvTDC/demographics/opm_faces_including.xlsx")

# Only keep relevant columns
df <- df %>%
  select(subject, dx, age, age_bin, trials, ffg_p1_lat_l, ffg_p1_amp_l, ffg_p1_lat_r, ffg_p1_amp_r, srs_total_T_merged, HM, num_bad_channels
  ) %>% rename(latency_l = ffg_p1_lat_l, 
               latency_r = ffg_p1_lat_r, 
               amplitude_l = ffg_p1_amp_l, 
               amplitude_r = ffg_p1_amp_r
  ) %>% 
  mutate(dx = factor(dx),
         subject = factor(subject), 
         age_bin = factor(age_bin),
         age = as.numeric(age)) # Make sure R knows that dx, age_bin and subject are categorical variables and age is a numeric variable


# Reshape to long format
df_hemisphere <- df %>%
  pivot_longer(
    cols = c(latency_l, latency_r, amplitude_l, amplitude_r),
    names_to = c("variable", "hemisphere"),
    names_sep = "_",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  ) %>%
  mutate(
    hemisphere = recode(hemisphere, l = "Left", r = "Right")
  ) %>%
  select(subject, dx, age, age_bin, hemisphere, latency, amplitude, srs_total_T_merged, trials, HM, num_bad_channels
  ) %>% 
  mutate(hemisphere = factor(hemisphere),
         dx = factor(dx),
         subject = factor(subject), 
         age_bin = factor(age_bin),
         age = as.numeric(age)) # Make sure R knows that dx, hemisphere, and subject are categorical variables and age is a numeric variable


# Data visualization ------------------------------------------------------

# Visualize peak latency by diagnosis

ggplot(df_hemisphere, aes(x = hemisphere, y = latency, fill = dx)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  geom_jitter(
    color = 'black',               
    position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8),
    alpha = 0.5, size = 1
  ) +
  labs(title = "Peak Latency by Diagnosis", y = "Peak Latency", x = "Hemisphere")


# Visualize peak amplitude diagnosis within hemisphere
ggplot(df_hemisphere, aes(x = hemisphere, y = amplitude, fill = dx)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  geom_jitter(
    color = 'black',               
    position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8),
    alpha = 0.5, size = 1
  ) +
  labs(title = "Peak Amplitude by Diagnosis", y = "Peak Amplitude", x = "Hemisphere")

# Visualize peak amplitude hemisphere within diagnosis
ggplot(df_hemisphere, aes(x = dx, y = amplitude, fill = hemisphere)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  geom_jitter(
    color = 'black',               
    position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8),
    alpha = 0.5, size = 1
  ) +
  labs(title = "Peak Amplitude by Diagnosis", y = "Peak Amplitude", x = "Hemisphere")


# Visualize peak amplitude left versus right
ggplot(df_hemisphere, aes(x = hemisphere, y = amplitude)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Peak Amplitude by Hemisphere", y = "Peak Amplitude", x = "Hemisphere") 

# Visualize peak latency left versus right
ggplot(df_hemisphere, aes(x = hemisphere, y = latency)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Peak Latency by Hemisphere", y = "Peak Latency", x = "Hemisphere") 


# Visualize peak amplitude ASD vs TDC
ggplot(df_hemisphere, aes(x = dx, y = amplitude)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Peak Amplitude by Diagnosis", y = "Peak Amplitude", x = "Diagnosis")

# Visualize peak latency ASD vs TDC
ggplot(df_hemisphere, aes(x = dx, y = latency)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Peak Latency by Diagnosis", y = "Peak Latency", x = "Diagnosis")


# ANOVA case-control -----------------------------------------
# What is the effect of hemisphere and dx on amplitude and latency of the face response?
# This would be a two-way repeated measures ANOVA: 
# Two-way because we have two categorical predictors, 
# and repeated-measures because hemisphere is a within-subject factor
# But there are missing values in the dependent variables
# And ANOVA doesn't handle them well / leaves out the entire row
# So we're going for a linear mixed-effects model instead. 

### AMPLITUDE
# Linear mixed effects model for repeated measures design - random intercept for each subject
model_amplitude_interaction <- lmer(amplitude ~ dx * hemisphere + (1 | subject), data = df_hemisphere)
summary(model_amplitude_interaction)

# The interaction term is non-significant so we let it go:
model_amplitude_simple <- lmer(amplitude ~ dx + hemisphere + (1 | subject), data = df_hemisphere)
summary(model_amplitude_simple)

# Compare both models:
anova(model_amplitude_interaction, model_amplitude_simple)

# Interaction term is not significant and does not improve model fit, so will move forward with simple model
eta_squared(model_amplitude_simple, partial = TRUE) # Check effect size
r2(model_amplitude_simple) # Check effect size
check_model(model_amplitude_simple) # Check model assumptions
emmeans(model_amplitude_simple, ~ dx) # Check adjusted group means



### LATENCY
# Linear mixed effects model for repeated measures design - random intercept for each subject
model_latency_interaction <- lmer(latency ~ dx * hemisphere + (1 | subject), data = df_hemisphere)
summary(model_latency_interaction)

# The interaction term is non-significant so we let it go:
model_latency_simple <- lmer(latency ~ dx + hemisphere + (1 | subject), data = df_hemisphere)
summary(model_latency_simple)

# Compare both models:
anova(model_latency_interaction, model_latency_simple)

# Interaction term is not significant and does not improve model fit, so will move forward with simple model
eta_squared(model_latency_simple, partial = TRUE)# Check effect size
r2(model_latency_simple)
check_model(model_latency_simple) # Check model assumptions
emmeans(model_latency_simple, ~ dx) # Check adjusted group means






# LME spectrum (with SRS scores) ----------------------------------------------
# Ignoring the diagnosis, is there a correlation between OPM data and SRS awareness / SRS cognition?

### AMPLITUDE
srs_amp_interaction <- lmer(amplitude ~ srs_total_T_merged * hemisphere + (1|subject), data = df_hemisphere)
summary(srs_amp_interaction)

srs_amp_simple <- lmer(amplitude ~ srs_total_T_merged + hemisphere + (1|subject), data = df_hemisphere)
summary(srs_amp_simple)

# Compare models
anova(srs_amp_interaction, srs_amp_simple)

# Interaction not significant + does not improve model fit -> continue with simpler model
eta_squared(srs_amp_simple, partial = TRUE)# Check effect size
r2(srs_amp_simple)
check_model(srs_amp_simple) # Check model assumptions

# PLot
pred <- ggpredict(srs_amp_simple, terms = c("srs_total_T_merged", "hemisphere"))

ggplot(df_hemisphere, aes(x = srs_total_T_merged, y = amplitude, colour = hemisphere)) +
  geom_point(alpha = 0.5) +
  geom_line(data = pred,
            aes(x = x, y = predicted, colour = group),
            size = 1.2) +
  geom_ribbon(data = pred,
              aes(x = x, ymin = conf.low, ymax = conf.high, fill = group),
              alpha = 0.15,
              inherit.aes = FALSE) +
  theme_classic() +
  labs(
    x = "SRS-2 Total T-score",
    y = "Amplitude",
    title = "Amplitude predicted by SRS (LMM)"
  )



### LATENCY
srs_lat_interaction <- lmer(latency ~ srs_total_T_merged * hemisphere + (1|subject), data = df_hemisphere)
summary(srs_lat_interaction)

srs_lat_simple <- lmer(latency ~ srs_total_T_merged + hemisphere + (1|subject), data = df_hemisphere)
summary(srs_lat_simple)

# Compare models
anova(srs_lat_interaction, srs_lat_simple)

# Interaction not significant + does not improve model fit -> continue with simpler model
eta_squared(srs_lat_simple, partial = TRUE)# Check effect size
r2(srs_lat_simple)
check_model(srs_lat_simple) # Check model assumptions

# PLot
pred <- ggpredict(srs_lat_simple, terms = c("srs_total_T_merged", "hemisphere"))

ggplot(df_hemisphere, aes(x = srs_total_T_merged, y = latency, colour = hemisphere)) +
  geom_point(alpha = 0.5) +
  geom_line(data = pred,
            aes(x = x, y = predicted, colour = group),
            size = 1.2) +
  geom_ribbon(data = pred,
              aes(x = x, ymin = conf.low, ymax = conf.high, fill = group),
              alpha = 0.15,
              inherit.aes = FALSE) +
  theme_classic() +
  labs(
    x = "SRS-2 Total T-score",
    y = "Latency",
    title = "Latency predicted by SRS (LMM)"
  )

