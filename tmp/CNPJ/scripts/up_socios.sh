#!/bin/bash
# ================================================
# Importação RÁPIDA dos arquivos SOCIOS0 a SOCIOS9
# Uso: ./up_socios.sh /srv/backups/CNPJ/2026-04/raw
# ================================================

set -e

DIR="$1"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "❌ Uso: $0 /caminho/para/2026-04/raw"
    exit 1
fi

cd "$DIR"

mysql -u root --local-infile=1 -e "
USE cnpjB;

SET GLOBAL innodb_flush_log_at_trx_commit = 0;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;
ALTER TABLE socios DISABLE KEYS;

TRUNCATE TABLE socios;

SELECT '✅ Tabela socios limpa. Iniciando importação dos 10 arquivos...' AS status;
"

for i in {0..9}; do
#    ARQUIVO_ZIP="Socios${i}.zip"
    
#    if [ ! -f "$ARQUIVO_ZIP" ]; then
#        echo "⚠️  Arquivo $ARQUIVO_ZIP não encontrado. Pulando..."
#        continue
#    fi

#    echo "📦 Extraindo $ARQUIVO_ZIP..."
#    unzip -o "$ARQUIVO_ZIP"

    # Detecção do arquivo CSV (nome longo como K3241.K03200Y0.D60411.SOCIOCSV)
    CSV_FILE=$(ls -1 K3241.K03200Y${i}.D60411.SOCIOCSV 2>/dev/null | head -n 1)

    if [ -z "$CSV_FILE" ]; then
        echo "❌ CSV não encontrado em $ARQUIVO_ZIP"
        continue
    fi

    echo "📂 Importando: $CSV_FILE"

    mysql -u root --local-infile=1 -e "
    USE cnpjB;

    LOAD DATA LOCAL INFILE '$(pwd)/$CSV_FILE'
    INTO TABLE socios
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 0 LINES
    (
        cnpj_basico,
        identificador_socio,
        nome_socio,
        documento,
        qualificacao,
        @data_entrada,
        pais
    )
    SET
        data_entrada = NULLIF(STR_TO_DATE(@data_entrada, '%Y%m%d'), '0000-00-00');
    "
done

mysql -u root -pSUA_SENHA_AQUI --local-infile=1 -e "
USE cnpjB;

ALTER TABLE socios ENABLE KEYS;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação de TODOS os SÓCIOS finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM socios;
"

echo "✅ Processo concluído!"
