#!/bin/bash
# ================================================
# Importação CORRIGIDA da tabela SIMPLES
# Uso: ./up_.sh /srv/backups/CNPJ/data/raw
# ================================================

set -e

DIR="$1"
#ZIP="$2" # arquivo zip
CSV_FILE="$2" # arquivo descompactado
NAME="Natureza"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "❌ Uso: $0 /caminho/para/raw"
    exit 1
fi

cd "$DIR"

echo "📦 Importando $NAME.zip → tabela '$NAME'"

#unzip -o $ZIP ARQ.csv

mysql -u root --local-infile=1 -e "
USE cnpjB;

-- === OTIMIZAÇÕES DE VELOCIDADE ===
SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;
ALTER TABLE natureza_juridica DISABLE KEYS;

TRUNCATE TABLE natureza_juridica;

LOAD DATA LOCAL INFILE '$(pwd)/$CSV_FILE'
INTO TABLE natureza_juridica
FIELDS TERMINATED BY ';'
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(codigo, descricao);

-- === RESTAURA ===
ALTER TABLE natureza_juridica ENABLE KEYS;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação NATUREZAS JURÍDICAS finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM natureza_juridica;
"

echo "✅ Processo concluído!"
