#!/bin/bash
# ================================================
# Importação RÁPIDA dos arquivos ESTABELECIMENTOS0 a ESTABELECIMENTOS9
# Uso: ./up_estabelecimentos.sh /srv/backups/CNPJ/2026-04/raw
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
ALTER TABLE estabelecimentos DISABLE KEYS;

TRUNCATE TABLE estabelecimentos;

SELECT '✅ Tabela estabelecimentos limpa. Iniciando importação dos 10 arquivos...' AS status;
"

for i in {0..9}; do
#    ARQUIVO_ZIP="Estabelecimentos${i}.zip"
    
#    if [ ! -f "$ARQUIVO_ZIP" ]; then
#        echo "⚠️  Arquivo $ARQUIVO_ZIP não encontrado. Pulando..."
#        continue
#    fi

#    echo "📦 Extraindo $ARQUIVO_ZIP..."
#    unzip -o "$ARQUIVO_ZIP"

    # Detecção do arquivo CSV
    CSV_FILE=$(ls -1 K3241.K03200Y${i}.D60411.ESTABELE 2>/dev/null | head -n 1)

    if [ -z "$CSV_FILE" ]; then
        echo "❌ CSV não encontrado em $ARQUIVO_ZIP"
        continue
    fi

    echo "📂 Importando: $CSV_FILE"

    mysql -u root --local-infile=1 -e "
    USE cnpjB;

    LOAD DATA LOCAL INFILE '$(pwd)/$CSV_FILE'
    INTO TABLE estabelecimentos
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 0 LINES
    (
        cnpj_basico,
        cnpj_ordem,
        cnpj_dv,
        matriz_filial,
        nome_fantasia,
        situacao_cadastral,
        @data_situacao,
        motivo_situacao,
        cidade_exterior,
        pais,
        @data_inicio_atividade,
        cnae_principal,
        cnae_secundarios,
        logradouro,
        numero,
        complemento,
        bairro,
        cep,
        uf,
        municipio,
        ddd1,
        telefone1,
        @email   -- pode ter mais colunas depois
    )
    SET
        cnpj = (cnpj_basico * 1000000) + (cnpj_ordem * 100) + cnpj_dv,
        data_situacao        = NULLIF(STR_TO_DATE(@data_situacao, '%Y%m%d'), '0000-00-00'),
        data_inicio_atividade = NULLIF(STR_TO_DATE(@data_inicio_atividade, '%Y%m%d'), '0000-00-00'),
        email                = NULLIF(@email, '');
    "
done

mysql -u root --local-infile=1 -e "
USE cnpjB;

ALTER TABLE estabelecimentos ENABLE KEYS;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET SESSION unique_checks = 1;
SET SESSION foreign_key_checks = 1;

SELECT '✅ Importação de TODOS os ESTABELECIMENTOS finalizada!' AS status;
SELECT COUNT(*) AS total_registros FROM estabelecimentos;
"

echo "✅ Processo concluído!"
