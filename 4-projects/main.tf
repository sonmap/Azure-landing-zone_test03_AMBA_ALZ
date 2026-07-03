locals {
  projects_all = {
    for row in csvdecode(file("${path.module}/csv/projects.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }
}
