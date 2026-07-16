#!/bin/bash

# ---------------------------------------
# CONFIG
# ---------------------------------------

#
# ---------------------------------------
# DOCS
# ---------------------------------------
# 	https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj
#
#

BASE_URL="https://arquivos.receitafederal.gov.br/public.php/dav/files"
HASH="YggdBLfdninEJX9"
VERSION="2026-03"

DEST="/srv/backups/CNPJ/$VERSION/raw"
#DEST="/srv/backups/CNPJ/organizando/raw"

mkdir -p "$DEST"
cd "$DEST" || exit 1

echo "==== DOWNLOAD CNPJ $VERSION ===="

BASE="$BASE_URL/$HASH/$VERSION"

# ---------------------------------------
# LISTA DE ARQUIVOS
# ---------------------------------------

FILES=(
Cnaes.zip
Empresas0.zip Empresas1.zip Empresas2.zip Empresas3.zip Empresas4.zip
Empresas5.zip Empresas6.zip Empresas7.zip Empresas8.zip Empresas9.zip
Estabelecimentos0.zip Estabelecimentos1.zip Estabelecimentos2.zip
Estabelecimentos3.zip Estabelecimentos4.zip Estabelecimentos5.zip
Estabelecimentos6.zip Estabelecimentos7.zip Estabelecimentos8.zip
Estabelecimentos9.zip
Motivos.zip
Municipios.zip
Naturezas.zip
Paises.zip
Qualificacoes.zip
Simples.zip
Socios0.zip Socios1.zip Socios2.zip Socios3.zip Socios4.zip
Socios5.zip Socios6.zip Socios7.zip Socios8.zip Socios9.zip
)

# ---------------------------------------
# DOWNLOAD
# ---------------------------------------

for file in "${FILES[@]}"; do
    echo "Baixando $file..."

    wget -c "$BASE/$file" -O "$file"

    if [ $? -ne 0 ]; then
        echo "ERRO ao baixar $file"
        exit 1
    fi
done

echo "==== DOWNLOAD FINALIZADO ===="
