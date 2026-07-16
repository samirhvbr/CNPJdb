#!/bin/bash

BASE_DIR="/srv/backups/CNPJ/2026-01"
RAW_DIR="$BASE_DIR/raw"
EXTRACT_DIR="$BASE_DIR/extracted"
PROCESSED_DIR="$BASE_DIR/processed"
LOG="$BASE_DIR/logs/import.log"

DB="cnpj"
MYSQL="mysql $DB"

mkdir -p "$RAW_DIR" "$EXTRACT_DIR" "$PROCESSED_DIR" "$BASE_DIR/logs"

echo "==== INICIO $(date) ====" >> "$LOG"

########################################
# 1. DESCOMPACTAR
########################################
for zip in "$RAW_DIR"/*.zip; do
    [ -e "$zip" ] || continue
    echo "Descompactando $zip" >> "$LOG"
    unzip -o "$zip" -d "$EXTRACT_DIR" >> "$LOG" 2>&1
done

########################################
# 2. NORMALIZAR QUEBRA DE LINHA
########################################
for file in "$EXTRACT_DIR"/*; do
    [ -e "$file" ] || continue
    sed -i 's/\r$//' "$file"
done

########################################
# 3. PERFORMANCE
########################################
$MYSQL -e "
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;
SET autocommit=0;
"

########################################
# 4. EMPRESAS
########################################
echo "==== EMPRESAS ====" >> "$LOG"

for file in "$EXTRACT_DIR"/*EMPRE*; do
    [ -e "$file" ] || continue
    echo "Importando $(basename $file)" >> "$LOG"

    $MYSQL <<EOF
LOAD DATA INFILE '$file'
INTO TABLE empresas
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@cnpj,@razao,@natureza,@qualificacao,@capital,@porte,@ente)
SET
cnpj_basico = @cnpj,
razao_social = @razao,
natureza_juridica = NULLIF(@natureza,''),
qualificacao_responsavel = NULLIF(@qualificacao,''),
capital_social = REPLACE(@capital, ',', '.'),
porte_empresa = NULLIF(@porte,''),
ente_federativo = @ente;
EOF

    mv "$file" "$PROCESSED_DIR/"
done

########################################
# 5. ESTABELECIMENTOS
########################################
echo "==== ESTABELECIMENTOS ====" >> "$LOG"

for file in "$EXTRACT_DIR"/*ESTABELE*; do
    [ -e "$file" ] || continue
    echo "Importando $(basename $file)" >> "$LOG"

    $MYSQL <<EOF
LOAD DATA INFILE '$file'
INTO TABLE estabelecimentos
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(
    @cnpj_basico,@ordem,@dv,@matriz,@nome,@situacao,@data_sit,@motivo,
    @cidade_ext,@pais,@data_inicio,@cnae,@cnae_sec,
    @tipo_logradouro,@logradouro,@numero,@complemento,@bairro,
    @cep,@uf,@municipio,
    @ddd1,@tel1,@ddd2,@tel2,@ddd_fax,@fax,@email,@sit_esp,@data_esp
)
SET
    cnpj_basico = @cnpj_basico,
    cnpj_ordem = @ordem,
    cnpj_dv = @dv,
    cnpj = CONCAT(@cnpj_basico,@ordem,@dv),

    matriz_filial = @matriz,
    nome_fantasia = @nome,
    situacao_cadastral = NULLIF(@situacao,''),

    data_situacao = STR_TO_DATE(@data_sit,'%Y%m%d'),
    motivo_situacao = NULLIF(@motivo,''),

    cidade_exterior = @cidade_ext,
    pais = NULLIF(@pais,''),

    data_inicio_atividade = STR_TO_DATE(@data_inicio,'%Y%m%d'),
    cnae_principal = NULLIF(@cnae,''),
    cnae_secundarios = @cnae_sec,

    logradouro = @logradouro,
    numero = @numero,
    complemento = @complemento,
    bairro = @bairro,
    cep = @cep,
    uf = @uf,
    municipio = NULLIF(@municipio,''),

    ddd1 = @ddd1,
    telefone1 = @tel1,
    email = @email;
EOF

    mv "$file" "$PROCESSED_DIR/"
done

########################################
# 6. SOCIOS
########################################
echo "==== SOCIOS ====" >> "$LOG"

for file in "$EXTRACT_DIR"/*SOCIO*; do
    [ -e "$file" ] || continue
    echo "Importando $(basename $file)" >> "$LOG"

    $MYSQL <<EOF
LOAD DATA INFILE '$file'
INTO TABLE socios
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@cnpj,@tipo,@nome,@doc,@qualificacao,@data,@pais)
SET
    cnpj_basico = @cnpj,
    identificador_socio = @tipo,
    nome_socio = @nome,
    documento = @doc,
    qualificacao = NULLIF(@qualificacao,''),
    data_entrada = STR_TO_DATE(@data,'%Y%m%d'),
    pais = NULLIF(@pais,'');
EOF

    mv "$file" "$PROCESSED_DIR/"
done

########################################
# 7. FINALIZAR
########################################
$MYSQL -e "
COMMIT;
SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;
SET autocommit=1;
"

echo "==== FIM $(date) ====" >> "$LOG"
