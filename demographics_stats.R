rm(list = ls())
graphics.off()


library(readxl)
library(ggplot2)
library(patchwork)



setwd("Y:/projects/OPM-Analysis/OPM_faces_ASDvTDC/code/Rscripts")


# Load in data
df <- read_excel(path = "Y:/projects/OPM-Analysis/OPM_faces_ASDvTDC/demographics/opm_faces_including.xlsx")


# Age ---------------------------------------------------------------------

by(df$age, df$dx, summary)
by(df$age, df$dx, sd)

# Boxplots
boxplot(age~dx, data=df, ylab="Age (years)",outpch=19,col="skyblue1")
age_means <- tapply(df$age, df$dx, mean)
points(1:2,age_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$age[df$dx == "ASD"],col="skyblue1",main="",ylab="Count", xlab="Age ASD (years)",breaks=seq(3,5,1))
hist(df$age[df$dx == "TDC"],col="skyblue1",main="",ylab="Count", xlab="Age TDC (years)",breaks=seq(3,5,1))
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = age, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  # Optional: add boxplot inside
  labs(title = "Violin Plot of Age by Dx", x = "Dx", y = "Age (years)") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = age)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD age"), x = "Theoretical Quantiles", y = "Age (years)")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = age)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC age"), x = "Theoretical Quantiles", y = "Age (years)")

qq1 + qq2

# Normality test
shapiro.test(df$age[df$dx == "ASD"])
shapiro.test(df$age[df$dx == "TDC"])


# Since the data for ASD is not normally distributed due to our cap at 5yo, test difference in mean without assuming normality
wilcox.test(age ~ dx, data = df) # Test whether the medians are different


# Head motion -------------------------------------------------------------

by(df$HM, df$dx, summary)
by(df$HM, df$dx, sd, na.rm = TRUE)


# Boxplots
boxplot(HM~dx, data=df, ylab="Age (years)",outpch=19,col="skyblue1")
HM_means <- tapply(df$HM, df$dx, mean)
points(1:2,HM_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$HM[df$dx == "ASD"],col="skyblue1",main="",ylab="Count", xlab="HM ASD (mm)",breaks=seq(0,20,5))
hist(df$HM[df$dx == "TDC"],col="skyblue1",main="",ylab="Count", xlab="HM TDC (mm)",breaks=seq(0,20,5))
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = HM, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  # Optional: add boxplot inside
  labs(title = "Violin Plot of HM by Dx", x = "Dx", y = "HM (mm)") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = HM)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD HM"), x = "Theoretical Quantiles", y = "HM (mm)")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = HM)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC HM"), x = "Theoretical Quantiles", y = "HM (mm)")

qq1 + qq2

# Normality test
shapiro.test(df$HM[df$dx == "ASD"])
shapiro.test(df$HM[df$dx == "TDC"])


# Data is normally distributed for both groups, so we can do a regular 2-sample t-tes
t.test(HM ~ dx, data = df) 


# Number of bad channels --------------------------------------------------------

by(df$num_bad_channels, df$dx, summary)
by(df$num_bad_channels, df$dx, sd)

# Boxplots
boxplot(num_bad_channels~dx, data=df, ylab="Trial count",outpch=19,col="skyblue1")
bch_means <- tapply(df$num_bad_channels, df$dx, mean)
points(1:2,bch_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$num_bad_channels[df$dx == "ASD"],col="skyblue1",main="",ylab="Count", xlab="Bad channels ASD")
hist(df$num_bad_channels[df$dx == "TDC"],col="skyblue1",main="",ylab="Count", xlab="Bad channels TDC")
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = num_bad_channels, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  
  labs(title = "Violin Plot of Bad Channel Count by Dx", x = "Dx", y = "Bad channel count") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = num_bad_channels)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD bad channel count"), x = "Theoretical Quantiles", y = "Bad channel count")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = num_bad_channels)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC bad channel count"), x = "Theoretical Quantiles", y = "Bad channel count")

qq1 + qq2

shapiro.test(df$num_bad_channels[df$dx == "ASD"])
shapiro.test(df$num_bad_channels[df$dx == "TDC"])

# Since the data are not normally distributed, test difference in mean without assuming normality
wilcox.test(num_bad_channels ~ dx, data = df) # Test whether the medians are different


# Number of trials --------------------------------------------------------

by(df$trials, df$dx, summary)
by(df$trials, df$dx, sd)

# Boxplots
boxplot(trials~dx, data=df, ylab="Trial count",outpch=19,col="skyblue1")
trial_means <- tapply(df$trials, df$dx, mean)
points(1:2,trial_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$trials[df$dx == "ASD"],col="skyblue1",main="",ylab="Count", xlab="Trial count ASD")
hist(df$trials[df$dx == "TDC"],col="skyblue1",main="",ylab="Count", xlab="Trial count TDC")
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = trials, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  
  labs(title = "Violin Plot of Trial Count by Dx", x = "Dx", y = "Trial count") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = trials)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD trial count"), x = "Theoretical Quantiles", y = "Trial count")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = trials)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC trial count"), x = "Theoretical Quantiles", y = "Trial count")

qq1 + qq2

shapiro.test(df$trials[df$dx == "ASD"])
shapiro.test(df$trials[df$dx == "TDC"])

# Since the data for TDC is not normally distributed, test difference in mean without assuming normality
wilcox.test(trials ~ dx, data = df) # Test whether the medians are different

# SRS total --------------------------------------------------------

by(df$srs_total_T_merged, df$dx, summary)
by(df$srs_total_T_merged, df$dx, sd, na.rm = TRUE)

# Boxplots
boxplot(srs_total_T_merged~dx, data=df, ylab="SRS total",outpch=19,col="skyblue1")
srsa_means <- tapply(df$srs_total_T_merged, df$dx, mean)
points(1:2,srsa_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$srs_total_T_merged[df$dx == "ASD"],col="skyblue1",main="",ylab="Score", xlab="SRS total ASD")
hist(df$srs_total_T_merged[df$dx == "TDC"],col="skyblue1",main="",ylab="Score", xlab="SRS total TDC")
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = srs_total_T_merged, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  
  labs(title = "Violin Plot of SRS total by Dx", x = "Dx", y = "Score") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = srs_total_T_merged)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD SRS total"), x = "Theoretical Quantiles", y = "SRS total")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = srs_total_T_merged)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC SRS total"), x = "Theoretical Quantiles", y = "SRS total")

qq1 + qq2

shapiro.test(df$srs_total_T_merged[df$dx == "ASD"])
shapiro.test(df$srs_total_T_merged[df$dx == "TDC"])

# Since the data are normally distributed, can do regular t test
t.test(srs_total_T_merged ~ dx, data = df) # Test whether the means are different

# ELC score --------------------------------------------------------

by(df$elc_score, df$dx, summary)
by(df$elc_score, df$dx, sd, na.rm=TRUE)

# Boxplots
boxplot(elc_score~dx, data=df, ylab="ELC score",outpch=19,col="skyblue1", ylim=c(0, 140))
elc_means <- tapply(df$elc_score, df$dx, mean, na.rm=TRUE)
points(1:2,elc_means,pch=18,col="firebrick",cex=1.5)

# Histogram
par(mfrow = c(1, 2))  # 1 row, 2 columns
hist(df$elc_score[df$dx == "ASD"],col="skyblue1",main="",ylab="Score", xlab="ELC score ASD")
hist(df$elc_score[df$dx == "TDC"],col="skyblue1",main="",ylab="Score", xlab="ELC score TDC")
par(mfrow = c(1, 1))

# Violin plot
ggplot(df, aes(x = dx, y = elc_score, fill = dx)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +  
  labs(title = "Violin Plot of ELC score by Dx", x = "Dx", y = "Score") +
  theme_minimal()

# Verify if data is normally distributed
qq1 <- ggplot(df[df$dx == "ASD",], aes(sample = elc_score)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of ASD SRS total"), x = "Theoretical Quantiles", y = "ELC score")

qq2 <- ggplot(df[df$dx == "TDC",], aes(sample = elc_score)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = paste("QQ Plot of TDC SRS total"), x = "Theoretical Quantiles", y = "ELC score")

qq1 + qq2

shapiro.test(df$elc_score[df$dx == "ASD"])
shapiro.test(df$elc_score[df$dx == "TDC"])

# ASD are not normally distributed so do Mann-Whitney U
wilcox.test(elc_score ~ dx, data = df) # Test whether the medians are different


# Other demographics --------------------------------------------------------
# Ethnicity/race 
table(df$race, df$dx)
100 * prop.table(table(df$race[df$dx == "ASD"]))
100 * prop.table(table(df$race[df$dx == "TDC"]))

race_table <- table(df$dx, df$race)
fisher.test(race_table)

# Income
table(df$income, df$dx)
100 * prop.table(table(df$income[df$dx == "ASD"]))
100 * prop.table(table(df$income[df$dx == "TDC"]))

income_table <- table(df$dx, df$income)
fisher.test(income_table)

# Education
table(df$education, df$dx)
100 * prop.table(table(df$education[df$dx == "ASD"]))
100 * prop.table(table(df$education[df$dx == "TDC"]))

education_table <- table(df$dx, df$education)
fisher.test(education_table)