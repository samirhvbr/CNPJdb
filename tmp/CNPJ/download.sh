#!/bin/bash

# ================================================
# Script de download dos arquivos da Receita Federal - 2026-03
# Salve como: download_receita_2026-03.sh
# ================================================

BASE_URL="https://arquivos.receitafederal.gov.br/public.php/dav/files/YggdBLfdninEJX9/2026-03/"
BASE_URL="https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9?dir=/2026-04"
BASE_URL="https://arquivos.receitafederal.gov.br/public.php/dav/files/YggdBLfdninEJX9/2026-04/"
DESTINO="/srv/backups/CNPJ/2026-04/"

mkdir -p "$DESTINO"
cd "$DESTINO" || { echo "❌ Não consegui entrar em $DESTINO"; exit 1; }

echo "🚀 Iniciando downloads na pasta: $DESTINO"
echo "📡 URL base: $BASE_URL"
echo "=================================================="

# Lista de arquivos (adicione aqui qualquer outro que aparecer na pasta)
ARQUIVOS=(
    "Cnaes.zip"
    "Simples.zip"
    "Socios9.zip"
    "Socios8.zip"
    "Socios7.zip"
    "Socios6.zip"
    "Socios5.zip"
    "Socios4.zip"
    "Socios3.zip"
    "Socios2.zip"
    "Socios1.zip"
    "Socios0.zip"
    "Qualificacoes.zip"
    "Paises.zip"
    "Naturezas.zip"
    "Municipios.zip"
    "Motivos.zip"
    "Estabelecimentos9.zip"
    "Estabelecimentos8.zip"
    "Estabelecimentos7.zip"
    "Estabelecimentos6.zip"
    "Estabelecimentos5.zip"
    "Estabelecimentos4.zip"
    "Estabelecimentos3.zip"
    # ← Adicione aqui os que faltarem (ex: Empresas0.zip, Estabelecimentos2.zip, etc.)
)

for arquivo in "${ARQUIVOS[@]}"; do
    echo "📦 Processando: $arquivo"

    # Testa se o download já começou (arquivo existe e tem tamanho > 0)
    if [ -f "$arquivo" ] && [ -s "$arquivo" ]; then
        echo "✅ $arquivo já existe e está completo → pulando"
        echo "--------------------------------------------------"
        continue
    fi

    echo "⬇️  Baixando (ou continuando) $arquivo..."

    # Loop persistente até conseguir baixar
    while true; do
        wget -c \
             --tries=0 \
             --retry-connrefused \
             --waitretry=10 \
             --timeout=60 \
             --progress=bar:force:noscroll \
             "${BASE_URL}${arquivo}"

        # Verifica se deu certo
        if [ -f "$arquivo" ] && [ -s "$arquivo" ]; then
            echo "✅ $arquivo baixado com sucesso!"
            break
        else
            echo "❌ Falha ao baixar $arquivo. Tentando novamente em 5 segundos..."
            sleep 5
        fi
    done

    echo "--------------------------------------------------"
done

echo "🎉 Todos os downloads foram finalizados!"
echo "Pasta: $DESTINO"
