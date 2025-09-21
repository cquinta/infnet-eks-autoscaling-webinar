resource "aws_route53_record" "webinar_cnames" {
  count = length(var.lista_cnames)

  zone_id = var.dns_zone
  name    = var.lista_cnames[count.index]
  type    = "CNAME"
  ttl     = 5

  # weighted_routing_policy {
  #   weight = 10
  # }


  records    = [aws_lb.main.dns_name]
  depends_on = [aws_lb.main]

}

