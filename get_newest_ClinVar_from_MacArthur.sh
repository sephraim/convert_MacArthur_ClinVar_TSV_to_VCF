#!/bin/bash

# Automatically retrieve the latest version of ClinVar from the
# MacArthur Lab git repository (https://github.com/macarthur-lab/clinvar)
#
# Example usage:
#   ./get_newest_ClinVar_from_MacArthur.sh

# Stop on first error
set -e

tsv="clinvar.macarthur.$(date +%F).tsv"
vcf="clinvar.macarthur.$(date +%F).vcf"

echo "Retrieving..."
curl -o "$tsv" 'https://raw.githubusercontent.com/macarthur-lab/clinvar/master/output/clinvar.tsv'

echo "Pre-formatting..." # Remove leading/trailing commas and semi-colons
sed -i -e $'s/\t[,;]/\t/g' -e $'s/[,;]\t/\t/g' "$tsv"
echo "Done! Output written to $tsv"

echo "Converting to VCF..."
tab2vcf \
  --source 'ClinVar' \
  --reference 'GRCh37.p13' \
  --prefix 'CLINVAR_' \
  --info-tag-map 'info_tag_map.txt' \
  "$tsv" > "$vcf"

echo "Zipping and indexing $vcf..."
bgzip -f "$vcf"
tabix -fp vcf "$vcf.gz"

echo "Output files:"
echo "- $tsv"
echo "- $vcf.gz"
echo "- $vcf.gz.tbi"
