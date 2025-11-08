# Orientações Legais e Éticas

Este repositório contém instruções e exemplos para realização de testes de segurança em ambiente controlado. Leia com atenção antes de prosseguir.

## Aviso legal (texto sugerido para o README)
"AVISO: Todos os testes descritos neste repositório foram realizados exclusivamente em ambientes controlados (máquinas virtuais locais). NÃO execute esses passos em sistemas que você não possui ou para os quais não tem permissão explícita. O autor não se responsabiliza pelo uso indevido das informações contidas neste repositório."

## Repositório: público ou privado?
- Se você for submeter para um bootcamp/avaliação pública, geralmente um repositório público é aceitável, desde que NÃO contenha dados sensíveis, wordlists privadas ou snapshots de VMs.
- Se houver preocupação com divulgação de detalhes do ambiente, use repositório privado e forneça acesso ao avaliador.

## O que NÃO incluir no repo
- Wordlists com senhas reais
- Snapshots de VMs
- Arquivos .pcap completos com tráfego que contenha credenciais em texto claro
- Chaves privadas, certificados ou tokens

## Como documentar ferramentas e wordlists
- Em vez de commitar arquivos pesados/sensíveis, indique o nome da wordlist e forneça instruções para o avaliador baixar (ex.: `sudo apt install wordlists` ou `wget https://...`).

## Boas práticas ao commitar evidências
1. Sanitize logs: remover senhas, tokens, informações pessoais.
2. Substituir IPs públicos por `192.168.x.x` quando for relevante. IPs de laboratório (host-only) podem permanecer, mas evite expor infraestrutura de produção.
3. Documente claramente que os testes foram feitos em VM isolada.

## Responsabilidade e autorização
- Faça testes de invasão somente com autorização explícita do proprietário do sistema.
- Em ambientes profissionais, tenha um escopo por escrito e autorização assinada.

---

Coloque uma cópia deste arquivo no repositório e inclua um trecho curto no topo do `README.md` (já presente).