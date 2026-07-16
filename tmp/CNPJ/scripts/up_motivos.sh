#!/bin/bash
# ================================================
# Importação CORRIGIDA da tabela SIMPLES
# Uso: ./up_.sh /srv/backups/CNPJ/data/raw
# ================================================

set -e

DIR="$1"
#ZIP="$2" # arquivo zip
CSV_FILE="$2" # arquivo descompactado
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "❌ Uso: $0 /caminho/para/raw"
    exit 1
fi

cd "$DIR"

echo "📦 Importando Motivos.zip → tabela 'Motivos'"

#unzip -o $ZIP ARQ.csv

mysql -u root --local-infile=1 -e "
USE cnpjB;

-- === OTIMIZAÇÕES DE VELOCIDADE ===
SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;
ALTER TABLE motivos DISABLE KEYS;

TRUNCATE TABLE motivos;

LOAD DATA LOCAL INFILE '$(pwd)/$CSV_FILE'
INTO TABLE motivos
FIELDS TERMINATED BY ';'
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(codigo, descricao);

-- === RESTAURA ===
ALTER TABLE motivos ENABLE KEYS;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação MOTIVOS finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM motivos;
"

echo "✅ Processo concluído!"
