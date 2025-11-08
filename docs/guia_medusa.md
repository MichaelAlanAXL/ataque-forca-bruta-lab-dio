# Guia seguro de uso do Medusa (laboratório)

> Aviso: use estas instruções apenas em ambiente controlado (VM Host-Only / Internal). Não execute testes sem permissão.

## Objetivo
Explicar o que é Medusa, como usá-lo de forma segura em laboratório, e como capturar e sanitizar logs/evidências para o repositório.

## O que é o Medusa
Medusa é uma ferramenta de força bruta paralelizada para autenticação contra serviços remotos (ssh, ftp, http, smb, telnet, etc.). Ela tenta combinações de usuário/senha usando uma wordlist. No laboratório do bootcamp, usaremos o Medusa apenas para demonstrar *que* um serviço com senhas fracas pode ser quebrado e para coletar evidências de forma controlada.

## Princípios de segurança (leia antes de rodar)
- Só execute em VMs isoladas (Host-Only / Internal).
- Nunca direcione Medusa a hosts públicos.
- Use wordlists muito pequenas para demonstração (10–100 itens) para evitar execução prolongada.
- Não inclua wordlists no repositório. Faça referência ao nome e ao caminho local.
- Sempre gere logs e revise antes de commitar — sanitize qualquer credencial encontrada.

## Preparando a execução
1. Crie/prepare uma wordlist curta (ex.: `~/wordlists/medusa_demo.txt`) com poucas entradas para demonstração.
2. Identifique o serviço alvo a partir do scan (ex.: `ftp`, `ssh`, `http`).
3. Escolha um usuário de teste existente no Metasploitable (ex.: `ftp` ou `msfadmin`) conforme necessário.
4. Confirme o IP do alvo (ex.: `192.168.56.20`).

## Comando padrão (exemplo seguro)
Use o script wrapper presente no repositório em `tools/scripts/run_medusa_example_safe.sh`.

Exemplo de uso (FTP):

```bash
# torne o script executável se necessário
chmod +x tools/scripts/run_medusa_example_safe.sh

# execute o script (substitua os parâmetros)
./tools/scripts/run_medusa_example_safe.sh 192.168.56.20 ftp /home/kali/wordlists/medusa_demo.txt
```

O script realiza validações (somente IP privado), executa o Medusa e salva a saída em `evidences/logs/medusa_<TARGET>_<TIMESTAMP>.log`.

> Observação: o script usa `-M ftp` por padrão no exemplo. Para outro serviço ajuste o comando manualmente ou edite o script para alterar `-M <servico>`.

## Exemplos manuais (sem o wrapper)

FTP (exemplo):
```bash
medusa -h 192.168.56.20 -u ftp -P /home/kali/wordlists/medusa_demo.txt -M ftp -t 4 -f
```

SSH (exemplo; use com cuidado):
```bash
medusa -h 192.168.56.20 -u testuser -P /home/kali/wordlists/medusa_ssh.txt -M ssh -t 4 -f
```

Flags importantes:
- `-h`: host alvo
- `-u`: usuário alvo
- `-P`: arquivo de palavra-chave (wordlist)
- `-M`: módulo/serviço (ssh, ftp, http, smb, etc.)
- `-t`: número de threads (paralelismo)
- `-f`: parar ao encontrar primeiro acerto (útil para demo rápida)

## Coleta de logs e evidências (texto)
1. Sempre grave a saída completa em arquivo (redirecione ou use o wrapper):
   - `-o` ou `tee`/redirecionamento: `medusa ... 2>&1 | tee medusa_target.log`
2. Salve o arquivo na pasta `evidences/logs/` no formato: `medusa_<TARGET>_<YYYYMMDD_HHMMSS>.log`.
3. Revise o log e substitua senhas em texto puro por `<REDACTED>` antes de commitar.
4. Gere um arquivo resumo `evidences/logs/07_medusa_summary_<TARGET>.txt` com as linhas-chave (ex.: `ACCOUNT FOUND ...`) e uma breve explicação.

## Sanitização de logs — guia rápido
- Procure por strings óbvias de senha ou padrões que correspondam ao conteúdo da sua wordlist.
- Substitua com `sed` ou manualmente:
```bash
# exemplo básico (não perfeito) para substituir senhas completas pelo token <REDACTED>
sed -E "s/(password: ).*/\1<REDACTED>/I" medusa_192.168.56.20_*.log > medusa_192.168.56.20_sanitized.log
```
- Sempre abra o arquivo sanitizado e confira antes do commit.

## O que capturar no relatório (texto)
- Qual comando foi executado (sem incluir a wordlist completa)
- Serviço alvo e porta
- Usuário testado
- Tempo de execução aproximado
- Resultado (ex.: `No valid credentials found` ou `Account found: ftp:password123` — substituir senha por `<REDACTED>`)
- Caminho do log sanitizado salvo em `evidences/logs/`

## Boas práticas para o relatório do bootcamp
- Explique que o teste foi feito em ambiente isolado.
- Foque nas consequências (por que senhas fracas são perigosas) e nas mitigações (rate limiting, fail2ban, autenticação por chave no SSH, MFA).
- Inclua o resumo textual e o log sanitizado conforme o template em `docs/evidencias.md`.

## Recursos e referência
- Página do Medusa: https://github.com/jmk-foofus/medusa
- Documentação do Nmap para enumeração: https://nmap.org

---

Se quiser, eu já adiciono um exemplo pequeno de `medusa_demo.txt` (com 8–10 entradas fictícias) no seu Kali (não no repositório) e/ou insiro uma seção curta no `README.md` apontando para este guia. Deseja que eu:

1. Adicione o trecho de instrução curta no `README.md` (sim/não)?
2. Crie um arquivo de exemplo de wordlist local no repositório (não recomendado) ou apenas um modelo de wordlist em `tools/scripts/wordlists_sample.txt` (recomendado: apenas 8 entradas fictícias)?

Informe qual opção prefere e eu prosseguirei.