library(optparse)
library(data.table)
library(dplyr)
library(tidyr)
library(reshape2)

suppressPackageStartupMessages(library(optparse))

## ---------- 1. Define command-line options ----------
option_list <- list(
  make_option(c("-i", "--input"),  type = "character",
              help = "Input data file (TSV / CSV)", metavar = "FILE"),
  make_option(c("-b", "--gene_name"), type = "character",
              help = "Gene annotation BED file", metavar = "FILE"),
  make_option(c("-g", "--gene_of_interest"), type = "character",
              help = "Plain-text list of genes (one per line)", metavar = "FILE"),
  make_option(c("-o", "--output"), type = "character", default = "result.tsv",
              help = "Output file [default: %default]", metavar = "FILE")
)

## ---------- 2. Parse command line ----------
parser <- OptionParser(
  option_list  = option_list,
  description  = "Filter your data by gene annotations"
)
opt <- parse_args(parser)

## ---------- 3. Check required arguments ----------
required <- c("input", "gene_name", "gene_of_interest")
missing  <- required[ vapply(required, function(x) is.null(opt[[x]]), logical(1)) ]

if (length(missing)) {
  cat("Missing required option(s):", paste(missing, collapse = ", "), "\n\n")
  print_help(parser)
  quit(status = 1)
}
folder_path <-  dirname(opt$input)
gene_name <- opt$gene_name

file_list <- list.files(folder_path, pattern = "\\.vcf$", full.names = TRUE)

# 初始化一个列表，用于存储读取的数据
cns_data <- list()

# 遍历每个文件
for (file_path in file_list) {
  file_name <- tools::file_path_sans_ext(basename(file_path))
  
  # 用 fread 读取文件
  cns_data[[file_name]] <- fread(file_path, header = T) %>%
    filter(FILTER=="PASS") %>%
    select(ID) %>%
    separate(ID, into=c("dragen", "cnv", "chr", "pos"), sep = ":") %>%
    separate(pos, into=c("start", "end"), sep = "-") %>%
    select(chr, start, end, cnv) %>%
    filter(cnv=="LOSS"|cnv=="GAIN") %>%
    mutate(cnv=case_when(
      cnv=="LOSS" ~ "loss",
      cnv=="GAIN" ~ "gain"
    ))
}
merged_data <- data.frame(coordinate = character(), cn = integer(), source = character(), stringsAsFactors = FALSE)
for (source_name in names(cns_data)) {
  # 获取当前数据框
  current_data <- cns_data[[source_name]]
  
  # 添加来源列
  current_data$source <- source_name
  
  # 合并到总数据框中
  merged_data <- rbind(merged_data, current_data)
}
temp <- merged_data %>%
  group_by(chr, start, end) %>%
  mutate(n=n())
cast.mind <- dcast(
  temp,
  chr + start + end + n~ source, # 将 source 的内容作为列名
  value.var = "cnv",                 # 填充值来自 cn 列
)
temp_cohort <- tempfile()
write.table(cast.mind, file = temp_cohort, col.names = F, row.names = F, sep = "\t", quote = F)
int_temp <- tempfile()

int <- sprintf("bedtools intersect -wo -a %s -b %s > %s", temp_cohort, gene_name, int_temp)
system(int)
header <- c(colnames(cast.mind), colnames(fread(gene_name, header=T)), "int")
int <- fread(int_temp, header=F)
int <- setnames(int, header)
GOI <- gene_of_interest
goi_dt <- fread(GOI, header = F)
int_filt <- int %>%
  filter(name2 %in% goi_dt$V1) %>%
  group_by(chr, start, end) %>%
  summarise(GOI=paste(name2, collapse = ","), across(everything(), first)) %>%
  ungroup(
  )
reuslt[is.na(reuslt)] <- " "

write.table(reuslt, file = output, col.names = T, row.names = F, sep = "\t", quote = F)
