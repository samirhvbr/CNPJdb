#!/bin/bash
# ================================================
# Importação CORRIGIDA da tabela SIMPLES
# Uso: ./up_simples.sh /srv/backups/CNPJ/2026-04/raw
# ================================================

set -e

DIR="$1"
ARQ="$2"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "❌ Uso: $0 /caminho/para/raw"
    exit 1
fi

cd "$DIR"

echo "📦 Importando Simples.zip → tabela 'simples'"

#unzip -o Simples.zip Simples.csv

mysql -u root --local-infile=1 -e "
USE cnpjB;

-- Otimizações de performance
SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;

TRUNCATE TABLE simples;

LOAD DATA LOCAL INFILE '$(pwd)/$ARQ'
INTO TABLE simples
FIELDS TERMINATED BY ';'
ENCLOSED BY '\"'               -- ← ESSA É A CORREÇÃO PRINCIPAL
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(
    cnpj_basico,
    opcao_pelo_simples,
    @data_opcao_simples,
    @data_exclusao_simples,
    opcao_pelo_mei,
    @data_opcao_mei,
    @data_exclusao_mei
)
SET
    data_opcao_simples    = NULLIF(STR_TO_DATE(@data_opcao_simples, '%Y%m%d'), '0000-00-00'),
    data_exclusao_simples = NULLIF(STR_TO_DATE(@data_exclusao_simples, '%Y%m%d'), '0000-00-00'),
    data_opcao_mei        = NULLIF(STR_TO_DATE(@data_opcao_mei, '%Y%m%d'), '0000-00-00'),
    data_exclusao_mei     = NULLIF(STR_TO_DATE(@data_exclusao_mei, '%Y%m%d'), '0000-00-00');

-- Restaura configurações
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação da tabela SIMPLES finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM simples;

SELECT 
    COUNT(CASE WHEN opcao_pelo_simples = 'S' THEN 1 END) AS optantes_simples,
    COUNT(CASE WHEN opcao_pelo_mei = 'S' THEN 1 END)     AS optantes_mei,
    COUNT(CASE WHEN data_exclusao_simples IS NULL THEN 1 END) AS ainda_no_simples
FROM simples;
"
