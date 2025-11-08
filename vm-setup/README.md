# Guia de Configuração do Ambiente de Laboratório

## ⚠️ Importante
Este ambiente deve ser usado APENAS para fins educacionais em um laboratório isolado.

## 📋 Requisitos Mínimos
- Processador com suporte à virtualização
- 8GB RAM (mínimo)
- 40GB espaço livre em disco
- VirtualBox 7.0+ ou VMware Workstation 17+

## 🔧 Downloads Necessários
1. VirtualBox: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
2. Kali Linux (VM): [https://www.kali.org/get-kali/#kali-virtual-machines](https://www.kali.org/get-kali/#kali-virtual-machines)
3. Metasploitable 2: [https://sourceforge.net/projects/metasploitable/](https://sourceforge.net/projects/metasploitable/)

## 🖥️ Configuração das Máquinas Virtuais

### 1. Configuração do VirtualBox
1. Criar rede Host-Only
   - VirtualBox > File > Host Network Manager
   - Create > Configure Adapter Manually
   - IPv4: `192.168.56.1`
   - Máscara: `255.255.255.0`
   - Desabilitar DHCP

![Print das configurações de host](/evidences/screenshots/01_network_diagram.png)

### 2. Configuração do Kali Linux
1. Importar VM do Kali
   - RAM: 2-4GB
   - CPU: 2 cores
   - Rede: Host-Only Adapter
   - IP Estático: `192.168.56.101`

### 3. Configuração do Metasploitable 2
1. Importar VM do Metasploitable
   - RAM: 1-2GB
   - CPU: 1 core
   - Rede: Host-Only Adapter
   - IP: DHCP ou estático (`192.168.56.102`)

## 🔒 Configurações de Segurança

### 1. Isolamento de Rede
- Usar APENAS rede Host-Only
- Desabilitar adaptadores de rede adicionais
- NÃO usar modo Bridge

### 2. Snapshots
1. Criar snapshot inicial do Kali
   - Nome: "Fresh Install"
   - Descrição: "Estado inicial limpo"

2. Criar snapshot inicial do Metasploitable
   - Nome: "Base Setup"
   - Descrição: "Configuração inicial"

![Print](/evidences/screenshots/04_snapshots.png)

## ✅ Verificação do Ambiente

### 1. Teste de Conectividade
```bash
# No Kali, testar conexão:
ping 192.168.56.102  # IP do Metasploitable

# No Metasploitable, testar conexão:
ping 192.168.56.101  # IP do Kali
```

### 2. Verificação de Isolamento
```bash
# Verificar que NÃO há conexão com internet:
ping 8.8.8.8  # Deve falhar
```

![Adicionar screenshot aqui: ](/evidences//screenshots/05_network_test.png)

## 🚫 Precauções de Segurança
1. NUNCA deixar as VMs em modo Bridge
2. SEMPRE reverter aos snapshots após os testes
3. Desligar as VMs quando não estiver usando
4. NÃO expor as VMs à rede externa
5. NÃO usar senhas reais no ambiente de lab
