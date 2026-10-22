# Politica de fluxos
| Origem | Destino | Servico | Decisao | Motivo |
|---|---|---|---|---|
| Caixas | ERP da matriz | TCP/443 | Permitir | Transacoes comerciais |
| Caixas | ERP da matriz | ICMP echo | Permitir | Teste de conectividade |
| IoT | Servidor de video da matriz | TCP/8554 | Permitir | Telemetria/video |
| Convidados | Internet externa | HTTP e demais trafegos | Permitir pela eth2 com NAT | Acesso de clientes |
| Convidados | 10.20.0.0/16 | Qualquer | Bloquear sempre | Isolamento corporativo |
| Outros | Outros | Qualquer | Negar por padrao | Menor privilegio |

O firewall controla o encaminhamento nos roteadores das lojas, nao o trafego gerado localmente no proprio roteador.
