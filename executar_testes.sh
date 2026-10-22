#!/usr/bin/env bash
# Execução em Codespaces com Docker + containerlab.
# Guarda evidências VERDADEIRAS; não mascara comandos que falham.
set -u
cd "$(dirname "$0")"
mkdir -p evidencias
exec > >(tee evidencias/execucao-completa.txt) 2>&1
ERROS=0
rodar() {
  echo; echo "===== $1 ====="
  shift
  "$@"; rc=$?
  if [ "$rc" -ne 0 ]; then echo "FALHOU (codigo $rc): $*"; ERROS=$((ERROS+1)); fi
}
comando() {
  echo; echo "===== $1 ====="; shift
  "$@"; rc=$?
  if [ "$rc" -ne 0 ]; then echo "FALHOU (codigo $rc): $*"; ERROS=$((ERROS+1)); fi
}
echo "Início: $(date -Is)"
rodar 'Validador da missão 1' bash -c 'cd enderecamento && python3 verifica_plano.py'
if ! command -v docker >/dev/null || ! command -v containerlab >/dev/null; then
  echo 'ERRO: docker e/ou containerlab não estão disponíveis neste ambiente.'
  echo 'A configuração do Codespaces / devcontainer precisa ser revisada.'
  exit 1
fi
rodar 'Docker' docker info
if docker ps --format '{{.Names}}' | grep -q '^clab-rede-matriz$'; then
    echo 'OK: topologia já implantada; reutilizando containers existentes'
else
    rodar 'Implantação Containerlab' bash -c 'cd rede && sudo containerlab deploy -t rede.clab.yml'
fi
rodar '14 nós da topologia' bash -c 'cd rede && sudo containerlab inspect -t rede.clab.yml'
for r in matriz loja1 loja2 nuvem; do
  rodar "Vizinhança OSPF: $r" docker exec "clab-rede-$r" vtysh -c 'show ip ospf neighbor'
done
rodar 'Conectividade caixa 1 -> ERP (ICMP)' docker exec clab-rede-caixa1 ping -c 3 -W 2 10.20.2.10
rodar 'Conectividade caixa 2 -> ERP (ICMP)' docker exec clab-rede-caixa2 ping -c 3 -W 2 10.20.2.10
rodar 'Traceroute loja1 -> ERP (antes da falha)' docker exec clab-rede-caixa1 traceroute -I -n -w 1 -m 10 10.20.2.10
rodar 'Caixa1 -> ERP HTTPS (esperado funcionar)' docker exec clab-rede-caixa1 curl -k --connect-timeout 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' https://10.20.2.10
rodar 'IoT -> ERP 8554 (esperado funcionar)' docker exec clab-rede-iot1 curl --connect-timeout 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://10.20.2.10:8554
rodar 'Convidados -> site externo simulado (esperado funcionar)' docker exec clab-rede-conv1 curl --connect-timeout 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://100.64.200.10
rodar 'Aplicação privada -> site externo simulado (esperado funcionar)' docker exec clab-rede-app curl --connect-timeout 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://100.64.200.10
rodar 'Regras firewall loja1' docker exec clab-rede-loja1 nft list ruleset
rodar 'Regras firewall nuvem' docker exec clab-rede-nuvem nft list ruleset
rodar 'Rota preferida no roteador loja1' docker exec clab-rede-loja1 vtysh -c 'show ip route 10.20.2.0/25'
echo; echo '===== Teste de bloqueio (resultado esperado: conexão bloqueada) ====='
if docker exec clab-rede-conv1 curl --connect-timeout 4 --max-time 6 -ksS -o /dev/null https://10.20.2.10; then
  echo 'FALHA DE SEGURANÇA: convidados alcançaram HTTPS do ERP'; ERROS=$((ERROS+1))
else
  echo 'OK: convidados não alcançaram HTTPS do ERP'
fi
# Teste de failover controlado. A interface é restaurada mesmo com falha no ping.
echo; echo '===== Simulação de queda do MPLS da Loja 1 ====='
if docker exec clab-rede-loja1 ip link set eth1 down; then
  sleep 8
  rodar 'ERP via enlace reserva' docker exec clab-rede-caixa1 ping -c 3 -W 2 10.20.2.10
  rodar 'Traceroute pela reserva' docker exec clab-rede-caixa1 traceroute -I -n -w 1 -m 10 10.20.2.10
  docker exec clab-rede-loja1 ip link set eth1 up || ERROS=$((ERROS+1))
  sleep 8
else
  echo 'FALHOU: sem permissão para baixar a interface'; ERROS=$((ERROS+1))
fi
echo; echo "Término: $(date -Is) | Falhas reportadas: $ERROS"
if [ "$ERROS" -ne 0 ]; then
 echo 'ATENÇÃO: reveja os erros acima; ainda NÃO está comprovado que a rede passou nos testes.'
 exit 1
fi
echo 'Os comandos executados foram registrados em evidencias/execucao-completa.txt.'
