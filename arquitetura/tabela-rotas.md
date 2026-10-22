# Modelo lógico de rotas — nuvem privada

| Destino | Máscara | Próximo salto lógico | Decisão |
|---|---|---|---|
| 10.20.8.0 | /24 | Conectada via eth3 | Aplicação privada |
| 10.20.0.0 | /22 | OSPF, preferir MPLS eth1 | Matriz |
| 10.20.4.0 | /23 | OSPF, preferir MPLS eth1 | Loja 1 |
| 10.20.6.0 | /23 | OSPF, preferir MPLS eth1 | Loja 2 |
| 0.0.0.0 | /0 | Internet eth2 (saída NAT) | Destinos externos |

**Importante:** representação de projeto, e não cópia de uma tabela de rotas medida no Containerlab. A tabela real depende do OSPF e da configuração de rota padrão. A rota mais específica vence. O laboratório simplifica VPN em OSPF via provedor Internet.
