# =============================================================================
# REGISTROS DNS CNAME PARA O WEBINAR
# =============================================================================
# Cria registros CNAME apontando para o ALB

# Registros CNAME no Route 53
# Permite acesso ao ALB via nomes amigáveis
resource "aws_route53_record" "webinar_cnames" {
  count = length(var.lista_cnames) # Cria um registro para cada CNAME

  zone_id = var.dns_zone                  # Zona DNS do Route 53
  name    = var.lista_cnames[count.index] # Nome do CNAME
  type    = "CNAME"
  ttl     = 5 # TTL baixo para testes

  records = [aws_lb.main.dns_name] # Aponta para o DNS do ALB

  depends_on = [aws_lb.main]
}

