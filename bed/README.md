# Appendix Files for Thesis

This repository contains BED files used in the CNV detection benchmarking project described in the thesis titled:  
**"Benchmarking CNV Detection Methods Using Targeted Panel Sequencing in CML"**

## Contents

The files here correspond to the design BED files used for targeted panel sequencing.

| Filename          | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| V1_original.bed   | Original BED file for Panel V1. Contains **all probe target regions**, including SNPs. |
| V1.bed            | Filtered BED file for Panel V1. Regions overlapping known SNPs were removed, and annotation was updated using [reference genome version used, e.g., GRCh38]. |
| V2_original.bed   | Same structure for Panel V2.                                                |
| V2.bed            | SNP-filtered BED for Panel V2.                                              |
| V3_original.bed   | Same structure for Panel V3.                                                |
| V3.bed            | SNP-filtered BED for Panel V3.                                              |

## How this relates to the thesis

These files are referenced in the **Methods** and **Appendix A** sections of the thesis.  
They define the panel designs used in datasets TAPS001 and TAPS002, which are evaluated for CNV detection performance.

---

If you use these BED files or reproduce this work, please cite the thesis or contact the author.
