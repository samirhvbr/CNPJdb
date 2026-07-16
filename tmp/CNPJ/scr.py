import psycopg2
import csv
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "database": "cnpj",
    "user": "root",
    "password": ""
}

def connect():
    return psycopg2.connect(**DB_CONFIG)


def parse_date(value):
    if not value or value == "00000000":
        return None
    return datetime.strptime(value, "%Y%m%d").date()


def load_empresas(file_path):
    conn = connect()
    cur = conn.cursor()

    with open(file_path, encoding="latin1") as f:
        reader = csv.reader(f, delimiter=';')

        for row in reader:
            cur.execute("""
                INSERT INTO empresas VALUES (%s,%s,%s,%s,%s,%s,%s)
                ON CONFLICT DO NOTHING
            """, (
                int(row[0]),
                row[1],
                int(row[2]) if row[2] else None,
                int(row[3]) if row[3] else None,
                float(row[4]) if row[4] else None,
                int(row[5]) if row[5] else None,
                row[6]
            ))

        conn.commit()
    cur.close()
    conn.close()


def load_estabelecimentos(file_path):
    conn = connect()
    cur = conn.cursor()

    with open(file_path, encoding="latin1") as f:
        reader = csv.reader(f, delimiter=';')

        for row in reader:
            cnpj = int(row[0] + row[1] + row[2])

            cur.execute("""
                INSERT INTO estabelecimentos VALUES (
                    %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                    %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                    %s,%s,%s,%s,%s,%s,%s,%s
                )
                ON CONFLICT DO NOTHING
            """, (
                cnpj,
                int(row[0]),
                int(row[1]),
                int(row[2]),
                int(row[3]),

                row[4],
                int(row[5]) if row[5] else None,
                parse_date(row[6]),
                int(row[7]) if row[7] else None,

                row[8],
                int(row[9]) if row[9] else None,

                parse_date(row[10]),
                int(row[11]) if row[11] else None,
                row[12],

                row[13],
                row[14],
                row[15],
                row[16],
                row[17],
                row[18],
                row[19],
                row[20],

                row[21],
                row[22],
                row[23],
                row[24],
                row[25],
                row[26],

                row[27],
                row[28]
            ))

        conn.commit()

    cur.close()
    conn.close()


def load_socios(file_path):
    conn = connect()
    cur = conn.cursor()

    with open(file_path, encoding="latin1") as f:
        reader = csv.reader(f, delimiter=';')

        for row in reader:
            cur.execute("""
                INSERT INTO socios (
                    cnpj_basico, identificador_socio, nome_socio,
                    cnpj_cpf_socio, qualificacao_socio, data_entrada,
                    pais, representante_legal, nome_representante,
                    qualificacao_representante, faixa_etaria
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                int(row[0]),
                int(row[1]),
                row[2],
                row[3],
                int(row[4]) if row[4] else None,
                parse_date(row[5]),
                int(row[6]) if row[6] else None,
                row[7],
                row[8],
                int(row[9]) if row[9] else None,
                int(row[10]) if row[10] else None
            ))

        conn.commit()

    cur.close()
    conn.close()
