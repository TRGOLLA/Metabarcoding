
$module list Currently Loaded Modulefiles: 1) chpc/BIOMODULES 2) python/2.7.15 $which illuminapairedend /apps/chpc/bio/python/2.7.15/bin/illuminapairedend

module load chpc/BIOMODULES python/2.7.15
which illuminapairedend /apps/chpc/bio/python/2.7.15/bin/illuminapairedend


module load chpc/BIOMODULES python/2.7.15/bin

STEP BY STEP

Recover full sequence reads from forward and reverse partial reads
$ python /apps/chpc/bio/python/2.7.15/bin/illuminapairedend --score-min=40 -r WBALP_FDSW19H001287-1a_HCYVLDRXX_L1_2_val_2_crop.fastq WBALP_FDSW19H001287-1a_HCYVLDRXX_L1_1_val_1_crop.fastq > WBALP.fastq

Remove unaligned sequence records
$ python /apps/chpc/bio/python/2.7.15/bin/obigrep -p 'mode!="joined"' WBALP.fastq > WBALP.ali.fastq

The first sequence record of wolf.ali.fastq can be obtained using the following command line:
$ python /apps/chpc/bio/python/2.7.15/bin/obihead --without-progress-bar -n 1 WBALP.ali.fastq


Dereplicate reads into uniq sequences
$ python /apps/chpc/bio/python/2.7.15/bin/obiuniq -m sample WBALP.ali.fastq > WBALP.ali.uniq.fasta

To keep only these two key=value attributes, we can use the obiannotate command:
$ python /apps/chpc/bio/python/2.7.15/bin/obiannotate -k count -k merged_sample WBALP.ali.uniq.fasta > $$ ; mv $$ WBALP.ali.uniq.fasta

Denoise the sequence dataset:
Get the count statistics:
$ python /apps/chpc/bio/python/2.7.15/bin/obistat -c count WBALP.ali.uniq.fasta | sort -nk1 | head -20

Keep only the sequences having a count greater or equal to 10 and a length shorter than 80 bp:
$ python /apps/chpc/bio/python/2.7.15/bin/obigrep -l 80 -p 'count>=10' WBALP.ali.uniq.fasta > WBALP.ali.uniq.c10.l80.fasta

(For database preparation, please go through OBITool manual)

Assign each sequence to a taxon:
Once the reference database is built, taxonomic assignment can be carried out using the ecotag command:
$ python /apps/chpc/bio/python/2.7.15/bin/ecotag -d embl_r117 -R db_v05_r117.fasta WBALP.ali.uniq.c10.l80.fasta > WBALP.ali.uniq.c10.l80.tag.fasta


Generate the final result table:
$ python /apps/chpc/bio/python/2.7.15/bin/obiannotate  --delete-tag=scientific_name_by_db --delete-tag=obiclean_samplecount --delete-tag=obiclean_count --delete-tag=obiclean_singletoncount --delete-tag=obiclean_cluster --delete-tag=obiclean_internalcount --delete-tag=obiclean_head --delete-tag=taxid_by_db --delete-tag=obiclean_headcount --delete-tag=id_status --delete-tag=rank_by_db --delete-tag=order_name --delete-tag=order WBALP.ali.uniq.c10.l80.tag.fasta > WBALP.ali.uniq.c10.l80.tag.ann.fasta

The sequences can be sorted by decreasing order of count:
$ python /apps/chpc/bio/python/2.7.15/bin/obisort -k count -r WBALP.ali.uniq.c10.l80.tag.ann.fasta > WBALP.ali.uniq.c10.l80.tag.ann.sort.fasta

Finally, a tab-delimited file that can be open by excel or R is generated:
$ python /apps/chpc/bio/python/2.7.15/bin/obitab -o WBALP.ali.uniq.c10.l80.tag.ann.sort.fasta > WBALP.ali.uniq.c10.l80.tag.ann.sort.tab

