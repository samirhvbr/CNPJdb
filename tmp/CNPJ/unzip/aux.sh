#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
DB="cnpj"
MYSQL="mysql $DB"

########################################
# CNAE
########################################
for file in "$DIR"/*CNAE*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE cnae
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@codigo,@descricao)
SET
codigo = IF(TRIM(@codigo) REGEXP '^[0-9]+$', @codigo, NULL),
descricao = @descricao;
EOF
done

########################################
# MUNICIPIOS
########################################
for file in "$DIR"/*MUNIC*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE municipios
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@codigo,@descricao)
SET
codigo = IF(TRIM(@codigo) REGEXP '^[0-9]+$', @codigo, NULL),
descricao = @descricao;
EOF
done

########################################
# NATUREZA JURIDICA
########################################
for file in "$DIR"/*NATJU*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE natureza_juridica
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@codigo,@descricao)
SET
codigo = IF(TRIM(@codigo) REGEXP '^[0-9]+$', @codigo, NULL),
descricao = @descricao;
EOF
done

########################################
# QUALIFICACAO
########################################
for file in "$DIR"/*QUALS*; do
    [ -e "$file" ] || continue

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE qualificacao
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@codigo,@descricao)
SET
codigo = IF(TRIM(@codigo) REGEXP '^[0-9]+$', @codigo, NULL),
descricao = @descricao;
EOF
done

########################################
# PAISES
########################################
for file in "$DIR"/*PAIS*; do
    [ -e "$file" ] || continue

    echo "Importando PAISES $(basename "$file")"

$MYSQL <<EOF
LOAD DATA INFILE '$file'
IGNORE
INTO TABLE pais
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@codigo,@descricao)
SET
codigo = IF(TRIM(@codigo) REGEXP '^[0-9]+$', @codigo, NULL),
descricao = @descricao;
EOF

done
