process SAMBAMBA_SORT {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::sambamba=1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity//sambamba:1.0--h98b6b92_0':
    'quay.io/biocontainers/sambamba:1.0--h98b6b92_0' }"


    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.sorted.bam"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.sorted"
    def avail_mem = 1
    if (!task.memory) {
        log.info '[SAMBAMBA SORT] Available memory not known - defaulting to 1GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    if("$bam" == "${prefix}.bam") error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    
    """
    sambamba \\
        sort \\
        $args \\
        -t $task.cpus \\
        -m ${avail_mem}G \\
        $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sambamba: \$(echo \$(sambamba --version 2>&1) | awk '{print \$2}' )
    END_VERSIONS
    """
    stub:
    def args = task.ext.args?:' '
    def prefix = task.ext.prefix ?:"${meta.id}"
    
    """
    touch ${prefix}.sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sambamba: \$(echo \$(sambamba --version 2>&1) | awk '{print \$2}' )
    END_VERSIONS

    """ 
}
