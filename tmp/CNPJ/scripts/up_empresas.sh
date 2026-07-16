#!/bin/bash
# ================================================
# Importação RÁPIDA dos arquivos EMPRESAS0 a EMPRESAS9
# Uso: ./up_empresas.sh /srv/backups/CNPJ/2026-04/raw
# ================================================

set -e

DIR="$1"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "❌ Uso: $0 /caminho/para/data/raw"
    exit 1
fi

cd "$DIR"

mysql -u root --local-infile=1 -e "
USE cnpjB;

SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;
ALTER TABLE empresas DISABLE KEYS;

TRUNCATE TABLE empresas;

SELECT '✅ Tabela empresas limpa. Iniciando importação dos 10 arquivos...' AS status;
"

for i in {0..9}; do
    ARQUIVO_ZIP="Empresas${i}.zip"
    
#    if [ ! -f "$ARQUIVO_ZIP" ]; then
#        echo "⚠️  Arquivo $ARQUIVO_ZIP não encontrado. Pulando..."
#        continue
#    fi

    echo "📦 Extraindo $ARQUIVO_ZIP..."
    #unzip -o "$ARQUIVO_ZIP"

    # Detecção do arquivo CSV (pode ter nome longo como F.K03200.EMPRESA0.CSV.Dxxxxx)
    CSV_FILE=$(ls -1 K3241.K03200Y${i}.D60411.EMPRECSV* 2>/dev/null | head -n 1)

    if [ -z "$CSV_FILE" ]; then
        echo "❌ CSV não encontrado em $ARQUIVO_ZIP"
        continue
    fi

    echo "📂 Importando: $CSV_FILE"

    mysql -u root --local-infile=1 -e "
    USE cnpjB;

    LOAD DATA LOCAL INFILE '$(pwd)/$CSV_FILE'
    INTO TABLE empresas
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 0 LINES
    (
        cnpj_basico,
        razao_social,
        natureza_juridica,
        qualificacao_responsavel,
        @capital_social,
        porte_empresa,
        @ente_federativo
    )
    SET
        capital_social = NULLIF(@capital_social, ''),
        ente_federativo = NULLIF(@ente_federativo, '');
    "
done

mysql -u root --local-infile=1 -e "
USE cnpjB;

ALTER TABLE empresas ENABLE KEYS;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação de TODAS as EMPRESAS finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM empresas;
"

echo "✅ Processo concluído!"
