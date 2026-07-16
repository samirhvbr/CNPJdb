#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$DIR/import.log"

DB="cnpj"
MYSQL="mysql $DB"

echo "==== INICIO $(date) ====" >> "$LOG"

########################################
# PREPARAÇÃO
########################################
$MYSQL -e "
SET sql_log_bin=0;
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;
SET autocommit=0;
"

########################################
# LIMPEZA SEGURA
########################################
$MYSQL -e "
DELETE FROM socios;
DELETE FROM estabelecimentos;
DELETE FROM empresas;
"

########################################
# NORMALIZAÇÃO
########################################
for file in "$DIR"/*; do
    [[ -f "$file" ]] || continue
#    sed -i 's/\r$//' "$file"
done

########################################
# EMPRESAS
########################################
for file in "$DIR"/*EMPRE*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE empresas
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@cnpj,@razao,@natureza,@qualificacao,@capital,@porte,@ente)
SET
cnpj_basico = NULLIF(@cnpj,''),

razao_social = @razao,

natureza_juridica =
IF(TRIM(@natureza) REGEXP '^[0-9]+$', @natureza, NULL),

qualificacao_responsavel =
IF(TRIM(@qualificacao) REGEXP '^[0-9]+$', @qualificacao, NULL),

capital_social =
IF(TRIM(@capital)!='', REPLACE(@capital, ',', '.'), NULL),

porte_empresa =
IF(TRIM(@porte) REGEXP '^[0-9]+$', @porte, NULL),

ente_federativo = @ente;
EOF

done

########################################
# ESTABELECIMENTOS
########################################
for file in "$DIR"/*ESTABELE*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
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
cnpj_basico = NULLIF(@cnpj_basico,''),

cnpj_ordem =
IF(TRIM(@ordem) REGEXP '^[0-9]+$', @ordem, NULL),

cnpj_dv =
IF(TRIM(@dv) REGEXP '^[0-9]+$', @dv, NULL),

cnpj =
IF(@cnpj_basico!='' AND @ordem!='' AND @dv!='',
   CONCAT(@cnpj_basico,@ordem,@dv),
   NULL),

matriz_filial =
IF(TRIM(@matriz) REGEXP '^[0-9]+$', @matriz, NULL),

nome_fantasia = @nome,

situacao_cadastral =
IF(TRIM(@situacao) REGEXP '^[0-9]+$', @situacao, NULL),

data_situacao =
IF(@data_sit REGEXP '^[0-9]{8}$',
   STR_TO_DATE(@data_sit,'%Y%m%d'),
   NULL),

motivo_situacao =
IF(TRIM(@motivo) REGEXP '^[0-9]+$', @motivo, NULL),

data_inicio_atividade =
IF(@data_inicio REGEXP '^[0-9]{8}$',
   STR_TO_DATE(@data_inicio,'%Y%m%d'),
   NULL),

cnae_principal =
IF(TRIM(@cnae) REGEXP '^[0-9]+$', @cnae, NULL),

logradouro = @logradouro,
numero = @numero,
bairro = @bairro,
cep = @cep,

uf =
IF(TRIM(@uf) REGEXP '^[A-Z]{2}$', @uf, NULL),

municipio =
IF(TRIM(@municipio) REGEXP '^[0-9]+$', @municipio, NULL),

ddd1 = @ddd1,
telefone1 = @tel1,
email = @email;
EOF

done

########################################
# SOCIOS
########################################
for file in "$DIR"/*SOCIO*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE socios
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(
@cnpj_basico,@identificador,@nome,@cnpj_cpf,@qualificacao,
@data_entrada,@pais,@rep_legal,@nome_rep,@qualif_rep,@faixa_etaria
)
SET
cnpj_basico = NULLIF(@cnpj_basico,''),

identificador_socio =
IF(TRIM(@identificador) REGEXP '^[0-9]+$', @identificador, NULL),

nome_socio = @nome,

documento = @cnpj_cpf,

qualificacao =
IF(TRIM(@qualificacao) REGEXP '^[0-9]+$', @qualificacao, NULL),

data_entrada =
IF(@data_entrada REGEXP '^[0-9]{8}$',
   STR_TO_DATE(@data_entrada,'%Y%m%d'),
   NULL),

pais =
IF(TRIM(@pais) REGEXP '^[0-9]+$', @pais, NULL);
EOF

done

########################################
# FINAL
########################################
$MYSQL -e "
COMMIT;
SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;
SET autocommit=1;
SET sql_log_bin=1;
"

echo "==== FIM $(date) ====" >> "$LOG"
