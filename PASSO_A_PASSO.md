# GUIA RÁPIDO — LEIA SÓ ESTE ARQUIVO

## 1. Subir os arquivos no GitHub
1. Crie um repositório no GitHub chamado `rede-varejo-nas`, com visibilidade **Private** se o professor aceitar. Marque a opção de inicializar com README para que o Codespaces tenha uma branch `main` desde o início.
2. Extraia o ZIP no seu computador. Entre na pasta `rede-varejo` extraída e selecione **todos os itens dentro dela**, inclusive `.devcontainer` (não suba apenas o ZIP).
3. No GitHub, clique **Add file > Upload files** e arraste os itens selecionados. Salve com **Commit changes**. Confirme que o arquivo `.devcontainer/devcontainer.json` apareceu na raiz do repositório.
4. Clique **Code > Codespaces > Create codespace on main**. Se houver opção de configuração, escolha `.devcontainer/devcontainer.json`. Confirme recursos disponíveis; podem existir limites ou custos conforme sua conta.

## 2. Testar a rede e coletar evidências (terminal do Codespaces)
Na raiz do projeto (onde está o README.md), cole:

```bash
bash executar_testes.sh
```

O script tenta validar os IPs, implantar os 14 contêineres, fazer testes de conectividade, verificar firewall e registrar o resultado na pasta `evidencias/`. **Leia qualquer erro no terminal**: um script que termina sem rede funcional não comprova a entrega. A implantação requer Docker e Containerlab em funcionamento com privilégios adequados.

Os testes de degradação com `tc`, observação de 5 minutos e a eventual demonstração ao vivo continuam sendo verificações adicionais; consulte `evidencias/ROTEIRO.md`. Não trate resultados não executados como comprovados.

## 3. Salvar as evidências no repositório
No terminal do Codespaces:

```bash
git status
git add evidencias
git commit -m "Registro dos testes executados no laboratorio"
git push origin main
```

Se o teste falhar, salve a saída de erro; não declare sucesso. Se não quiser manter a infraestrutura ligada, execute no diretório `rede`:

```bash
sudo containerlab destroy -t rede.clab.yml
```

## 4. Tags das cinco entregas
O enunciado pede versões `entrega-1` a `entrega-5`. Como todos os arquivos já foram reunidos, **criar cinco tags no mesmo commit NÃO reconstrói cinco entregas cronológicas separadas**. Caso o professor aceite um envio único consolidado, marque a versão final:

```bash
git tag entrega-5
git push origin entrega-5
```

Se ele exigir o histórico progressivo das semanas, isso precisa ser feito corretamente, com commits correspondentes às etapas, não fingindo que houve entregas anteriores.

## 5. Entregar
Copie a URL do repositório do GitHub (ou a tag `entrega-5`) e entregue no canal indicado pelo professor. Se o repositório for privado, conceda acesso a quem for avaliar.

## O que você precisa saber para explicar
- A **matriz** tem ERP e usuários; existem duas **lojas** e uma **nuvem privada**.
- **VLSM/CIDR** reserva endereços IP com 30% de crescimento.
- **OSPF** prefere MPLS (custo 10); Internet (100) é a contingência.
- **nftables** isola convidados, caixas, IoT e a nuvem; **NAT** atende saídas externas.
- **Wi-Fi** separa funcionários, clientes e sensores por SSID/VLAN.
- **Monitoramento** aprende o RTT normal e alerta por latência/perdas.

## Limitação transparente
O plano de IP foi validado localmente. Neste ambiente de criação não há Docker nem Containerlab, portanto não é possível garantir que os contêineres e os testes de rede rodem até a validação no Codespaces. As evidências de rede devem ser obtidas pela execução do roteiro, nunca inventadas.
