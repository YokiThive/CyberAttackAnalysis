library(ggplot2)
library(dplyr)
library(caTools)
library(randomForest)
library(caret)
library(corrplot)

fileUrl = "C:\\Thivedraan\\APU\\Sem 3\\Programming for Data Analysis\\Group Project\\Coursework Question Paper(s) and Answer Scripts -20250928\\UNSW-NB15_uncleaned.csv"

#To determines the relationship of source to destination transaction bytes (sbytes) 
#and source jitter (sjit) towards the presence of a cyber attack 

df = read.csv(fileUrl)
df

summary(df)

cleaner_df <- c("sbytes", "dbytes", "rate", "sttl", "dttl", "sload", "dload", "sloss", "dloss", "sinpkt", "dinpkt", "sjit", "djit")
cleaner_df

#remove weird characters from numerical values
#replace missing values with median for numeric columns
df <- df %>% mutate(across(all_of(cleaner_df), ~ {
  cleaning = gsub("[^0-9]", "", .x)
  cleaning[cleaning == ""] <- NA
  clean_val = as.numeric(cleaning)
  clean_val[is.na(clean_val)] <- median(clean_val, na.rm = TRUE)
  clean_val
}
))

#clean label
df$label <- gsub("[^0-9]", "", df$label)
df$label[df$label == ""] <- NA
df$label <- as.numeric(df$label)

df_before_iqr <- df

summary(df_before_iqr$sbytes)

#before IQR
ggplot(df_before_iqr, aes(x = attack_cat, y = sbytes, fill = attack_cat)) +
  geom_boxplot() +
  labs(title = "Boxplot of sbytes BEFORE IQR Cleaning", x = "Attack Category", y = "sbytes")

ggplot(df_before_iqr, aes(x = attack_cat, y = sjit, fill = attack_cat)) +
  geom_boxplot() +
  labs(title = "Boxplot of sjit BEFORE IQR Cleaning", x = "Attack Category", y = "sjit")

iqr_func <- function(x) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  
  lower_bound <- Q1 - 1.5 * IQR_val
  upper_bound <- Q3 + 1.5 * IQR_val
  
  x[x < lower_bound] <- lower_bound
  x[x > upper_bound] <- upper_bound
  
  return(x)
}

#use IQR function
df <- df %>% mutate(across(all_of(cleaner_df), ~ iqr_func(.x)))

#see differences
summary(df_before_iqr$sbytes)
summary(df$sbytes)
summary(df_before_iqr$sjit)
summary(df$sjit)

#rows with label
df_clean_train <- df %>% filter(!is.na(label))
#rows with missing label
df_clean_missing <- df %>% filter(is.na(label))

#train
randomforest_label <- randomForest(
  x = df_clean_train[, cleaner_df],
  y = as.factor(df_clean_train$label),
  ntree = 300
)

#predict missing label
df_clean_missing$label <- predict(randomforest_label, df_clean_missing[, cleaner_df])

#convert label from factor to numeric
df_clean_missing$label <- as.numeric(as.character(df_clean_missing$label))

#merge
df <- bind_rows(df_clean_train, df_clean_missing)

#set to Normal if the label is 0
df$attack_cat[df$label == 0] <- "Normal"

#rows with category
df_attack_train <- df %>% filter(!is.na(attack_cat), label == 1)
#rows with missing category 
df_attack_missing <- df %>% filter(is.na(attack_cat), label == 1)

#train
randomforest_attack <- randomForest(
  x = df_attack_train[, cleaner_df],
  y = as.factor(df_attack_train$attack_cat),
  ntree = 300
)

#predict missing category
df_attack_missing$attack_cat <- predict(randomforest_attack, df_attack_missing[, cleaner_df])

#final version after cleaning
df_cleaned <- df %>% filter(!(label == 1 & is.na(attack_cat))) %>%  
  bind_rows(df_attack_missing)

#check the portion of data that is NA
table(is.na(df_cleaned$attack_cat))

class(df_cleaned$label)
table(df_cleaned$label)

#correlation matrix only for numeric columns
correlation_column <- c(cleaner_df, "label")

#pearson correlation
correlation_m <- cor(df_cleaned[correlation_column], use="complete.obs", method="pearson")
corrplot(title = "Pearson Correlation Matrix", correlation_m, method="color", type="upper", tl.col="black", tl.cex=0.7, 
         addCoef.col = "black", number.cex = 0.6)

#spearman correlation
correlation_m2 <- cor(df_cleaned[correlation_column], use="complete.obs", method="spearman")
corrplot(title = "Spearman Correlation Matrix", correlation_m2, method="color", type="upper", tl.col="black", tl.cex=0.7,
         addCoef.col = "black", number.cex = 0.6)

#Mann-Whitney U test
sbytes_wilcoxon <- wilcox.test(sbytes ~ label, data = df_cleaned)
sbytes_wilcoxon
sjit_wilcoxon <- wilcox.test(sjit ~ label, data = df_cleaned)
sjit_wilcoxon

#graphs and plots

#boxplots
ggplot(df_cleaned, aes(x = attack_cat, y = sbytes, fill = attack_cat)) + 
  geom_boxplot(outlier.size = 0.8) + 
  labs(title = "Sbytes by Attack Category", x = "Attack Category", y = "Sbytes")

ggplot(df_cleaned, aes(x = attack_cat, y = sjit, fill = attack_cat)) + 
  geom_boxplot(outlier.size = 0.8) + 
  labs(title = "Sjit by Attack Category", x = "Attack Category", y = "Sjit")

#violin plot
ggplot(df_cleaned, aes(x = attack_cat, y = sbytes, fill = attack_cat)) +
  geom_violin(alpha = 0.8) +
  geom_boxplot(outlier.size = 0.8, alpha = 0.5) +
  theme_minimal() +
  labs(title = "sbytes Distribution by Attack Category",
    x = "Attack Category", y = "sbytes") +
  theme(legend.position = "none")

ggplot(df_cleaned, aes(x = attack_cat, y = sjit, fill = attack_cat)) +
  geom_violin(alpha = 0.8) +
  geom_boxplot(outlier.size = 0.8, alpha = 0.5) +
  theme_minimal() +
  labs(
    title = "sjit Distribution by Attack Category",
    x = "Attack Category", y = "sjit") +
  theme(legend.position = "none")

#scatter plot
ggplot(df_cleaned, aes(x = sbytes, y = sjit, color = attack_cat)) +
  geom_point(alpha = 0.5, size = 1) +
  theme_minimal() +
  labs(title = "Relationship Between sbytes and sjit",
    x = "sbytes", y = "sjit", color = "Attack Category") +
  theme(legend.position = "right")
