#!/bin/bash

# =========================
# PARAMETROS
# =========================

INPUT_DIR=""

for arg in "$@"; do
    case $arg in
        --dir=*)
        INPUT_DIR="${arg#*=}"
        shift
        ;;
    esac
done

if [ -z "$INPUT_DIR" ]; then
    echo "Uso: $0 --dir=/caminho/dos/zips"
    exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
    echo "Diretório inválido: $INPUT_DIR"
    exit 1
fi

# =========================
# CONFIG
# =========================

BASE_DIR="/srv/backups/cnpj"
RAW_DIR="$BASE_DIR/raw"
EXTRACT_DIR="$BASE_DIR/extracted"
PROCESSED_DIR="$BASE_DIR/processed"
LOG_DIR="$BASE_DIR/logs"

LOG_FILE="$LOG_DIR/import_$(date +%Y%m%d_%H%M%S).log"

DB="cnpj"
MYSQL="mysql --local-infile=1 $DB"

mkdir -p "$RAW_DIR" "$EXTRACT_DIR" "$PROCESSED_DIR" "$LOG_DIR"

# =========================
# FUNÇÕES
# =========================

log() {
    LEVEL=$1
    STEP=$2
    MSG=$3
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$LEVEL] [$STEP] $MSG" | tee -a "$LOG_FILE"
}

run_sql() {
    SQL="$1"
    STEP="$2"

    START=$(date +%s)

    OUTPUT=$(echo "$SQL" | $MYSQL 2>&1)
    STATUS=$?

    END=$(date +%s)
    DURATION=$((END - START))

    if [ $STATUS -ne 0 ]; then
        log "ERROR" "$STEP" "$OUTPUT"
        return 1
    else
        log "OK" "$STEP" "Executado em ${DURATION}s"
    fi
}

# =========================
# INICIO
# =========================

log "INFO" "START" "Iniciando importação"
log "INFO" "INPUT" "Origem: $INPUT_DIR"

# =========================
# MOVER ZIPS PARA RAW
# =========================

for zip in "$INPUT_DIR"/*.zip; do
    [ -e "$zip" ] || continue

    FILE_NAME=$(basename "$zip")

    if [ -f "$RAW_DIR/$FILE_NAME" ]; then
        log "INFO" "SKIP" "$FILE_NAME já existe em raw/"
        continue
    fi

    log "INFO" "MOVE" "Movendo $FILE_NAME"
    mv "$zip" "$RAW_DIR/" 2>>"$LOG_FILE"

    if [ $? -eq 0 ]; then
        log "OK" "MOVE" "$FILE_NAME movido"
    else
        log "ERROR" "MOVE" "Falha ao mover $FILE_NAME"
    fi
done

# =========================
# PREPARAR DB
# =========================

run_sql "
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;
SET autocommit=0;
" "INIT_DB"

# =========================
# UNZIP
# =========================

for zip in "$RAW_DIR"/*.zip; do
    [ -e "$zip" ] || continue

    FILE_NAME=$(basename "$zip")

    log "INFO" "UNZIP" "$FILE_NAME"

    unzip -o "$zip" -d "$EXTRACT_DIR" >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        log "ERROR" "UNZIP" "Falha ao extrair $FILE_NAME"
        continue
    fi

    log "OK" "UNZIP" "$FILE_NAME extraído"
done

# =========================
# IMPORTAÇÃO
# =========================

for file in "$EXTRACT_DIR"/*; do
    [ -e "$file" ] || continue

    FILE_NAME=$(basename "$file")

    log "INFO" "PROCESS" "$FILE_NAME"

    if [[ "$file" == *EMPRECSV ]]; then

        run_sql "
LOAD DATA LOCAL INFILE '$file'
INTO TABLE empresas
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@cnpj,@razao,@nat,@qual,@cap,@porte,@ente)
SET
cnpj_basico=@cnpj,
razao_social=@razao,
natureza_juridica=NULLIF(@nat,''),
qualificacao_responsavel=NULLIF(@qual,''),
capital_social=NULLIF(@cap,''),
porte_empresa=NULLIF(@porte,''),
ente_federativo=@ente;
" "EMPRESAS"

    elif [[ "$file" == *ESTABELE* ]]; then

        run_sql "
LOAD DATA LOCAL INFILE '$file'
INTO TABLE estabelecimentos
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@cnpj,@ord,@dv,@mat,@nome,@sit,@data,@motivo,
@cidade,@pais,@data_ini,@cnae,@cnae_sec,
@tipo_log,@log,@num,@compl,@bairro,@cep,@uf,@mun,
@ddd1,@tel1,@ddd2,@tel2,@faxddd,@fax,@email,@sit_esp,@data_esp)
SET
cnpj_basico=@cnpj,
cnpj_ordem=@ord,
cnpj_dv=@dv,
cnpj=CONCAT(@cnpj,@ord,@dv),
matriz_filial=@mat,
nome_fantasia=@nome,
situacao_cadastral=NULLIF(@sit,''),
data_situacao=STR_TO_DATE(@data,'%Y%m%d'),
motivo_situacao=NULLIF(@motivo,''),
cidade_exterior=@cidade,
pais=NULLIF(@pais,''),
data_inicio_atividade=STR_TO_DATE(@data_ini,'%Y%m%d'),
cnae_principal=NULLIF(@cnae,''),
cnae_secundarios=@cnae_sec,
logradouro=@log,
numero=@num,
complemento=@compl,
bairro=@bairro,
cep=@cep,
uf=@uf,
municipio=NULLIF(@mun,''),
ddd1=@ddd1,
telefone1=@tel1,
email=@email;
" "ESTABELECIMENTOS"

    elif [[ "$file" == *SOCIOCSV ]]; then

        run_sql "
LOAD DATA LOCAL INFILE '$file'
INTO TABLE socios
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
(@cnpj,@tipo,@nome,@doc,@qual,@data,@pais)
SET
cnpj_basico=@cnpj,
identificador_socio=@tipo,
nome_socio=@nome,
documento=@doc,
qualificacao=NULLIF(@qual,''),
data_entrada=STR_TO_DATE(@data,'%Y%m%d'),
pais=NULLIF(@pais,'');
" "SOCIOS"

    fi

    if [ $? -eq 0 ]; then
        mv "$file" "$PROCESSED_DIR/"
        log "OK" "MOVE" "$FILE_NAME processado"
    else
        log "ERROR" "IMPORT" "Falha em $FILE_NAME"
    fi

done

# =========================
# FINALIZAR
# =========================

run_sql "COMMIT;" "COMMIT"

run_sql "
SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;
SET autocommit=1;
" "FINAL_DB"

log "INFO" "END" "Importação finalizada"
