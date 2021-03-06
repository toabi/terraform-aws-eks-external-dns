data "helm_repository" "default" {
  depends_on = [var.mod_dependency]
  name       = var.helm_repo_name
  url        = var.helm_repo_url
}

data "aws_region" "current" {}

resource "helm_release" "external_dns" {
  depends_on = [var.mod_dependency]
  count      = var.enabled ? 1 : 0
  name       = var.helm_release_name
  repository = data.helm_repository.default.metadata[0].name
  chart      = var.helm_chart_name
  namespace  = var.k8s_namespace
  version    = var.helm_chart_version

  values = [
    "${templatefile("${path.module}/templates/values.yaml.tpl",
      {
        "cluster_name"              = var.cluster_name,
        "zone_tags_filters"         = var.zone_tags_filters
        "external_dns_iam_role_arn" = aws_iam_role.external_dns[0].arn
        "service_account_name"      = var.k8s_service_account_name
        "aws_region"                = data.aws_region.current.name
      })
    }"
  ]
}
