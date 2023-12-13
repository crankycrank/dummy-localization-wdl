version 1.0

# dummy WDL to reproduce localization problem

workflow Lozalization {

  input {
    File bam
    File bam_index
  }

  call localize_bam {
    input:
      bam = bam,
      bam_index = bam_index,

      docker="marketplace.gcr.io/google/debian12",
      preemptible_tries=0
  }

  output {
    String bam_size = localize_bam.file_size
  }
}

task localize_bam {

  input {
    File bam
    File bam_index

    String docker
    Int preemptible_tries
    Int cpu = 1
    Int memory_gb = 3
  }
  Float bam_size = size(bam, "GiB")
  Int disk_size_gb = ceil((1.1 * bam_size) + 10)

  command <<<
    ls -s ~{bam} | awk '{print $1}' > size
    sleep 10
  >>>

  runtime {
    docker: docker
    preemptible: preemptible_tries
    memory: "${memory_gb} GiB"
    cpu: cpu
    disks: "local-disk ${disk_size_gb} HDD"
  }

  output {
    Int file_size = read_string("size")
  }
}  # end task localize_bam
