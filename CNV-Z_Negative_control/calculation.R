library(tidyverse)

# 获取所有以 "Fx-sample" 开头的 CSV 文件名
files <- list.files()

# 读取并合并所有文件，加一列表示来源文件名
df_long <- files %>%
  set_names() %>%
  map_df(~ read_csv(.x, show_col_types = FALSE) %>%
           mutate(Source = .x), .id = NULL)

# 查看前几行确认结果
head(df_long)
cal <- df_long %>%
  filter(Chr!="chrX") %>%
  mutate(cnv = case_when(
    copynumber < 1.2 ~ "loss",
    copynumber >= 1.2 & copynumber <= 2.8 ~ "neutral",
    TRUE ~ "gain"  # 可选：处理大于2.8的情况
  ))

cal_all <- cal %>%  
  count(cnv)
# 保存完整带CNV注释的数据表
write_csv(cal, "CNV_Calls_with_Labels.csv")

# 保存统计结果（loss/neutral/gain 各自数量）
write_csv(cal_all, "CNV_Label_Counts.csv")
