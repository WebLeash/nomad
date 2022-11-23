resource "nomad_job" "install_consule" {
  jobspec = data.template_file.job.rendered
}

data "template_file" "job" {
  template = file("./consul.hcl.tmpl")


}