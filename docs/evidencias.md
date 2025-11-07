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

### 4. Mitigações
| Arquivo | Descrição | Observações |
|---------|-----------|-------------|
| `09_fail2ban_config.png` | Configuração do Fail2ban | [Adicionar screenshot] |
| `10_firewall_rules.png` | Regras de firewall | [Adicionar screenshot] |

## 📝 Logs

### 1. Logs de Reconhecimento
```
# Adicionar logs sanitizados aqui
# Exemplo: resultado do nmap com IPs e informações sensíveis removidas
```

### 2. Logs de Tentativas
```
# Adicionar logs sanitizados aqui
# Exemplo: saída do Medusa com credenciais removidas
```

### 3. Logs de Sistema
```
# Adicionar logs sanitizados aqui
# Exemplo: logs de autenticação com IPs e usuários removidos
```

## 🔍 Processo de Sanitização
1. Remover todos os IPs reais (substituir por 192.168.x.x)
2. Remover/mascarar nomes de usuário reais
3. Remover/mascarar senhas e hashes
4. Remover informações de sistema específicas
5. Remover timestamps específicos se necessário

## ✅ Checklist de Validação
- [ ] Screenshots não contêm dados sensíveis
- [ ] Logs foram sanitizados
- [ ] Evidências são claras e relevantes
- [ ] Formato das imagens é consistente
- [ ] Nomes dos arquivos seguem o padrão
- [ ] Todos os arquivos estão referenciados
- [ ] Qualidade das imagens está adequada
