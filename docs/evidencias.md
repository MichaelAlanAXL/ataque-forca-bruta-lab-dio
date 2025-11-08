# Registro de Evidências do Laboratório

## 📸 Screenshots

### 1. Configuração do Ambiente
| Arquivo | Descrição | Observações |
|---------|-----------|-------------|
| `01_network_diagram.png` | Diagrama da topologia de rede | [Adicionar screenshot] |
| `02_vm_setup.png` | Configuração das VMs no VirtualBox | [Adicionar screenshot] |
| `03_kali_network.png` | Configuração de rede do Kali | [Adicionar screenshot] |
| `04_metasploitable_network.png` | Configuração de rede do Metasploitable | [Adicionar screenshot] |

### 2. Verificação Inicial
| Arquivo | Descrição | Observações |
|---------|-----------|-------------|
| `05_nmap_scan.png` | Resultado do scan inicial | [Adicionar screenshot] |
| `06_service_versions.png` | Versões dos serviços identificados | [Adicionar screenshot] |

### 3. Execução dos Testes
| Arquivo | Descrição | Observações |
|---------|-----------|-------------|
| `07_medusa_execution.png` | Execução do Medusa (sanitizado) | [Adicionar screenshot] |
| `08_attack_evidence.png` | Evidência do ataque (logs limpos) | [Adicionar screenshot] |

# Registro de Evidências do Laboratório (versão texto)

Este arquivo substitui a versão com screenshots por uma versão em texto para facilitar coleta de evidências quando capturas de tela não são possíveis. Mantenha os arquivos de log/texto na pasta `evidences/logs/` e atualize os nomes abaixo conforme necessário.

## 1. Configuração do Ambiente (evidências textuais)

| Arquivo (texto) | Descrição | Observações |
|-----------------|-----------|-------------|
| `01_network_diagram.txt` | Descrição textual da topologia de rede e adaptadores Host-Only | Ex.: Kali: 192.168.56.10, Metasploitable: 192.168.56.20 |
| `02_vm_setup.txt` | Resumo da configuração das VMs (RAM, CPU, rede) | Incluir snapshots criados |
| `03_kali_network.txt` | Saída de `ip addr show` / `ifconfig` do Kali | Remover dados sensíveis se houver |
| `04_metasploitable_network.txt` | Saída de `ifconfig` / `ip a` do Metasploitable | Preferir IPs privados |

## 2. Verificação Inicial (enumeração)

| Arquivo (texto) | Descrição | Observações |
|-----------------|-----------|-------------|
| `05_nmap_top100_<IP>.txt` | Resultado do scan rápido (top 100 portas) | Ex.: `nmap --top-ports 100 -sS -sV` |
| `06_nmap_services_<IP>.txt` | Detalhes de serviços e banners detectados | Gerar com `-sC -sV` |

## 3. Execução dos Testes (força bruta — saídas textuais)

| Arquivo (texto) | Descrição | Observações |
|-----------------|-----------|-------------|
| `07_medusa_<TARGET>_<TIMESTAMP>.log` | Saída completa do Medusa (log gerado pelo script) | Sanitizar senhas antes de commitar |
| `08_attack_evidence.txt` | Resumo das ações e resultados (linhas relevantes coladas) | Indicar quais contas foram testadas |

## 4. Mitigações (configurações e evidências)

| Arquivo (texto) | Descrição | Observações |
|-----------------|-----------|-------------|
| `09_fail2ban_config.txt` | Conteúdo do arquivo de configuração do Fail2ban usado no teste | Ocultar IPs reais se necessário |
| `10_firewall_rules.txt` | Regras aplicadas no `iptables`/`ufw` | Incluir comandos usados para aplicar regras |

## Logs (modelos e instruções)

### 1. Logs de Reconhecimento
Cole aqui os logs sanitizados do Nmap e outras ferramentas de enumeração. Exemplos de como salvar:

```bash
# Scan rápido (top 100)
sudo nmap -T4 -sS -sV --top-ports 100 -oN evidences/logs/05_nmap_top100_192.168.56.20.txt 192.168.56.20

# Scan de serviços com scripts
sudo nmap -sC -sV -oN evidences/logs/06_nmap_services_192.168.56.20.txt 192.168.56.20
```

### 2. Logs de Tentativas (força bruta)
Salve a saída completa do Medusa (ou script wrapper) em `evidences/logs/`. Antes de commitar, verifique e remova qualquer senha em texto puro:

```bash
# exemplo com o script seguro
tools/scripts/run_medusa_example_safe.sh 192.168.56.20 ftp testuser /path/to/wordlist.txt

# o script grava em evidences/logs/medusa_192.168.56.20_YYYYMMDD_HHMMSS.log
```

### 3. Logs de Sistema
Inclua linhas relevantes de logs de autenticação (por exemplo `/var/log/auth.log`) após sanitização. Evite commitar entradas que contenham senhas ou dados pessoais.

## Processo de Sanitização (passo a passo)
1. Abra o arquivo de log e procure por strings que sejam senhas ou tokens.
2. Substitua por `<REDACTED>` ou `<CRED_TEST>`.
3. Substitua IPs públicos por `192.168.x.x` se necessário.
4. Salve a versão sanitizada em `evidences/logs/` com sufixo `_sanitized`.

## Checklist rápido antes do commit
- [ ] Logs salvos em `evidences/logs/`
- [ ] Arquivos sanitizados quando necessário
- [ ] Nomes dos arquivos seguem o padrão descrito acima
- [ ] README e `docs/evidencias.md` referenciam corretamente os arquivos

> Observação: este documento prioriza a compatibilidade com avaliações que não exigem imagens. Se futuramente você quiser incluir screenshots, mantenha ambos os formatos (imagem + texto) e atualize este arquivo.