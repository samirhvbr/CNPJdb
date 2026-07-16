#!/bin/bash
# ================================================
# Ajusta TODO o banco para CHARACTER SET latin1 (padrão Receita Federal)
# Uso: ./ajustar_charset_latin1.sh
# ================================================

set -e

BANCO="cnpjB"          # ← altere para "cnpj" se quiser ajustar o outro banco

echo "🔧 Ajustando charset do banco ${BANCO} para latin1..."

# 1. Ajusta o banco inteiro
mysql -u root -pSUA_SENHA_AQUI -e "
ALTER DATABASE ${BANCO} CHARACTER SET latin1 COLLATE latin1_general_ci;
"

# 2. Gera apenas os comandos ALTER TABLE (sem cabeçalho)
mysql -u root -pSUA_SENHA_AQUI --skip-column-names -e "
SELECT CONCAT('ALTER TABLE \`', TABLE_NAME, '\` CONVERT TO CHARACTER SET latin1 COLLATE latin1_general_ci;')
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = '${BANCO}'
ORDER BY TABLE_NAME;
" > /tmp/alter_tables.sql

echo "📋 Executando alterações em todas as tabelas..."

# Executa os comandos
mysql -u root -pSUA_SENHA_AQUI ${BANCO} < /tmp/alter_tables.sql

echo "✅ Charset de TODAS as tabelas alterado para latin1 com sucesso!"

# Verificação final
mysql -u root -pSUA_SENHA_AQUI -e "
SELECT TABLE_NAME, TABLE_COLLATION 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = '${BANCO}'
LIMIT 20;
"

rm -f /tmp/alter_tables.sql
