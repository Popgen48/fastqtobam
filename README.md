## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->

**nf-core/fastqtobam** is a bioinformatics best-practice analysis pipeline to generate bam files from raw paired-end reads fastq files.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

The pipeline supports job/batch schedulers/distributed resource management systems (DRMS)/distributed resource managers (DRM), like The Slurm Workload Manager/sbatch.

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->

On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/fastqtobam/results).

## Pipeline summary

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Check input samplesheet (list.csv)
2. Fasta index bwa ([`BWA-MEM`](https://github.com/lh3/bwa))
3. Fasta indices samtools faidx ([`Samtools`](https://www.htslib.org/))
4. Quality and adapter trimming ([`TrimGalore`](https://github.com/FelixKrueger/TrimGalore))
5. Windowed adaptive trimming ([`sickle`](https://github.com/najoshi/sickle))
6. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
7. Alignment ([`BWA-MEM`](https://github.com/lh3/bwa))
8. Finding duplicate reads in BAM file ([`Sambamba-markdup`](https://github.com/biod/sambamba))
9. Quality control of bam alignment data ([`Qualimap bamqc`](http://qualimap.conesalab.org/))
10. Custom dump (diverse softwareversions)
11. Present QC for raw reads ([`MultiFastQC`](http://multiqc.info/))
12. Present QC for bam alignment ([`Multibamqc`](http://qualimap.conesalab.org/))

<img src="docs/images/fastqToBamPP.svg" width=60% height=60%>

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and test it on a minimal dataset with a single command:

   ```bash
   nextflow run fastqtobam/ -profile test,YOURPROFILE --fasta <path-to-genome.fa> --outdir <OUTDIR>
   ```

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

   > - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   > - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
   > - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Set further configurations, depending on your computational environment, especially if resource managers are used or not.
   - In `fastqtobam/nextflow.config` one can set an executer (resource manager), with `slurm` as the default.
   - A computational facility may structure itself in Slurm clusters and Slurm partitions. If used, the pipeline expects the Slurm cluster to be specified outside of nextflow by a separate command:

     ```bash
     export SLURM_CLUSTERS=<CLUSTER-NAME>
     ```

   - The Slurm partition is specified in the beginning of `fastqtobam/conf/base.config` under `squeue = "<PARTITION-NAME>"`
   - Also, in `fastqtobam/conf/base.config` the maximum amount of CPUs/memory/time per `nf-core`-label can be set.

   If no resource manager is used, the respective lines need to be commented out.

5. In `fastqtobam/docs/usage.md` and `fastqtobam/assets/samplesheet.csv`, example input samplesheets are provided to communicate the input structure expected from the pipeline.

6. Start running your own analysis!

   <!-- TODO nf-core: Update the example "typical command" below used to run the pipeline -->

   ```bash
   nextflow run fastqtobam/ --input samplesheet.csv --outdir <OUTDIR> --fasta <path-to-genome.fna> --samtools_faidx <path-to-genome.fna.fai> -qs 40 -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
   ```

   The `-qs` parameter specifies the number of parallel sent slurm jobs. If the pipeline is cancelled at some point, it can be continued with the `-resume` flag.

## Documentation

The nf-core/fastqtobam pipeline comes with documentation about the pipeline [usage](https://nf-co.re/fastqtobam/usage), [parameters](https://nf-co.re/fastqtobam/parameters) and [output](https://nf-co.re/fastqtobam/output).

## Credits

nf-core/fastqtobam was originally written by @BioInf2305.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#fastqtobam` channel](https://nfcore.slack.com/channels/fastqtobam) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/fastqtobam for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
