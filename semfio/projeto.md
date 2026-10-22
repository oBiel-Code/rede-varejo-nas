# Projeto sem fio - uma loja de 600 m²

| SSID | Autenticacao | VLAN | Sub-rede loja 1 | Firewall |
|---|---|---:|---|---|
| loja-corp | WPA3-Enterprise / 802.1X | 10 | 10.20.5.0/25 | Acesso corporativo a definir conforme politica interna |
| loja-clientes | Portal cativo e isolamento | 20 | 10.20.4.0/24 | Somente Internet, NAT e bloqueio da empresa |
| loja-sensores | WPA3-Personal, senha exclusiva | 30 | 10.20.5.192/26 | Somente video TCP 8554 |

Loja 2: corp 10.20.7.0/25, clientes 10.20.6.0/24 e sensores 10.20.7.192/26.

## Dimensionamento
- Area: 600 / 150 = 4 APs.
- Capacidade: (120 clientes + 20 funcionarios + 25 sensores) / 30 = 5,5 -> 6 APs.
- Adotado: **6 APs por loja**. Validar o posicionamento em vistoria real.

## Exemplo de canais (assumindo disposicao em linha)
| AP | 2,4 GHz | 5 GHz |
|---|---:|---:|
| AP1 | 1 | 36 |
| AP2 | 6 | 44 |
| AP3 | 11 | 52 |
| AP4 | 1 | 60 |
| AP5 | 6 | 100 |
| AP6 | 11 | 108 |

APs vizinhos imediatos nao dividem canal no arranjo linear exemplificado. Em uma planta real, rever sobreposicao, DFS, potencias e canalizacao.
