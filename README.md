> **Como entregar sem ler o enunciado:** veja [`PASSO_A_PASSO.md`](PASSO_A_PASSO.md). Para registrar testes no Codespaces: `bash executar_testes.sh`.

# Laboratorio NAS - Da matriz a nuvem

Projeto-base elaborado a partir do enunciado HTML fornecido. Integrante: Gabriel C. Simões — RM 563169 — Engenharia de Software, FIAP — turma 2ESPX. Conferir dados antes da entrega.

## Proposta
Rede de varejo com matriz, duas lojas e nuvem; roteamento OSPF por MPLS preferencial (custo 10) e internet de contingencia (custo 100), segmentacao e monitoramento.

## Enderecamento
Bloco 10.20.0.0/16, folga de 30% em cada segmento. Gateways: primeiro IP util de cada rede.
- Matriz 10.20.0.0/22; usuarios /23, servidores /25, gestao /27.
- Loja 1 10.20.4.0/23; convidados /24, corp /25, caixas /26, IoT /26.
- Loja 2 10.20.6.0/23; segmentos equivalentes.
- Nuvem 10.20.8.0/23; privada /24 e publica /27.

## Como validar
1. Abrir no GitHub Codespaces via devcontainer.
2. `cd enderecamento && python3 verifica_plano.py`.
3. `cd ../rede && sudo containerlab deploy -t rede.clab.yml`.
4. `sudo containerlab inspect -t rede.clab.yml`.
5. `docker exec clab-rede-loja1 vtysh -c "show ip ospf neighbor"`.
6. `docker exec clab-rede-caixa1 ping -c 3 10.20.2.10`.
7. Executar os roteiros originais das missoes 3 a 7, e salvar as saidas em `evidencias/`.

## Arquivo como fonte da verdade
Alteracoes manuais nao persistem depois da recriacao; o repositorio e a fonte declarativa da configuracao.

## Contingencia
O OSPF escolhe o menor custo: MPLS 10 por enlace, internet 100 por enlace. Falha fisica e falha silenciosa devem ser medidas, nunca presumidas.

## Segmentacao
O convidado nao pode acessar 10.20.0.0/16, mesmo em contingencia. O caixa tem apenas HTTPS e ping ate o ERP; IoT somente TCP/8554 ate o servidor correspondente.

## NAT da nuvem
A sub-rede privada usa SNAT quando acessa destinos externos via internet. Conexoes externas novas nao devem alcancar a privada; retorno de conexoes existentes e acessos da empresa continuam permitidos conforme as regras definidas.

## Monitoracao
Linha de base: media + 3 desvios das ultimas 30 amostras boas (piso de 2 ms); alerta por perda de 3 amostras em 10.

## Evidencias pendentes
Os testes reais precisam ser executados na plataforma. Nao foram inventados resultados, capturas ou tempos medidos. Ver o arquivo `evidencias/ROTEIRO.md`.

## Desenhos
Os desenhos `fisica.png` e `logica.png` estão incluídos como visualizações do projeto; os arquivos `*.mmd` mantêm a fonte editável. Veja `arquitetura/tabela-rotas.md` e `evidencias/STATUS.md`.


## Cinco entregas — correspondência com as missões
| Entrega | Conteúdo | Arquivos |
|---|---|---|
| 1 | Ambiente e plano | `.devcontainer/`, `enderecamento/`, `evidencias/missao1.txt` |
| 2 | Topologia e roteamento | `rede/rede.clab.yml`, `rede/*.conf`, `politica-caminhos.yaml` |
| 3 | Segurança e nuvem | `rede/*.nft`, `seguranca/fluxos.md`, `arquitetura/tabela-rotas.md` |
| 4 | Wi-Fi e operação | `semfio/projeto.md`, `operacao/monitora.py` |
| 5 | Arquitetura e demonstração | `arquitetura/*.png`, `arquitetura/*.mmd`, `evidencias/` |

## Ressalvas de implementação
- `politica-caminhos.yaml` é uma **especificação de política**, não um controlador SD-WAN integrado à topologia.
- O `monitora.py` implementa a **detecção**; aumentar automaticamente o custo OSPF é EXTRA e não foi automatizado.
- Os SSIDs/VLANs são **projeto lógico**; o Containerlab original não cria APs nem VLANs reais.
- O firewall usa `nftables` nos roteadores; conferir no Codespaces se a imagem aceita instalação e carregamento via `apk`. Se houver falha, corrigir no ambiente e registrar.
- A internet é simulada como roteador FRR com OSPF; não é um provedor público real.

## Comandos principais de evidência
```bash
cd rede
sudo containerlab deploy -t rede.clab.yml
sudo containerlab inspect -t rede.clab.yml
docker exec clab-rede-loja1 vtysh -c 'show ip ospf neighbor'
docker exec clab-rede-caixa1 ping -c 3 10.20.2.10
docker exec clab-rede-caixa1 traceroute -I -n 10.20.2.10
# No diretório raiz, após subir o laboratório:
python3 operacao/monitora.py 10.20.2.10
```

## Roteamento externo simulado
A rota estática `100.64.200.0/24` nos roteadores `loja1` e `nuvem` direciona o site de teste ao provedor de Internet local (`eth2`), separadamente da política OSPF para acesso corporativo. Essa exceção é específica do laboratório e **não substitui uma implementação completa de SD-WAN**.
