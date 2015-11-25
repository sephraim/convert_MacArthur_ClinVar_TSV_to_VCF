#!/bin/bash

# Automatically retrieve the latest version of ClinVar from the
# MacArthur Lab git repository (https://github.com/macarthur-lab/clinvar)

tsv="clinvar.macarthur.$(date +%F).tsv"
vcf="clinvar.macarthur.$(date +%F).vcf"

echo "Retrieving..."
curl -o "$tsv" 'https://raw.githubusercontent.com/macarthur-lab/clinvar/master/output/clinvar.tsv'
echo "Pre-formatting..."
sed -i -e $'s/\t[,;]/\t/g' -e $'s/[,;]\t/\t/g' "$tsv"
echo "Done! Output written to $tsv"

echo "Converting to VCF..."
tab2vcf --prefix 'CLINVAR_' "$tsv" > "$vcf"
echo "Zipping and indexing $vcf..."
bgzip -f "$vcf"
tabix -fp vcf "$vcf.gz"
echo "Output files:"
echo "- $tsv"
echo "- $vcf.gz"
echo "- $vcf.gz.tbi"
