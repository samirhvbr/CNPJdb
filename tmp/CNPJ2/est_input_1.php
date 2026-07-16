<?php

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Scripting/EmptyPHP.php to edit this template
 */

// TEMPO DE EXEC SCRIPT
$start = microtime(true);

/*
 * CONEXÃO COM O BANCO DE DADOS
 */
$dbase = "CNPJ";    // database name
$server = "100.64.66.211";       // host
$user = "cnpjUser";           // usuario
$password = "q4j45B4c9NU2rL9qxLMS7aD";  // password
$dbchar = "utf8";                // charset
try {
    $pdo = new PDO("mysql:host=$server;dbname=$dbase", $user, $password, array(PDO::ERRMODE_WARNING));
} catch (PDOException $error) {
    $errorSQL = $error->getMessage();
    echo 'Connection Failed: ' . $errorSQL;
    log_error($errorSQL, "ERROR DB CONNECT");
    exit();
}




/*
 * 
 * FUNCTIONS
 * 
 */

// TROCA DA DATA
function data_format($linear_date) {
    // Extrai os valores dos componentes da data
    $year = substr($linear_date, 0, 4);
    $month = substr($linear_date, 4, 2);
    $day = substr($linear_date, 6, 2);

    $format_date = $year . "-" . $month . "-" . $day;
    return $format_date;
}

// TRATA A RAZAO SOCIAL
function trata_razao($string_read) {
    // Procura pela letra ''' na string
    $string = mb_strtoupper($string_read, 'UTF-8');
    // array de caracteres especiais
    $caracteres_especiais = array(
        'Š' => 'S', 'š' => 's', 'Ð' => 'Dj', 'Â' => 'Z', 'Â' => 'z', 'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A',
        'Å' => 'A', 'Æ' => 'A', 'Ç' => 'C', 'È' => 'E', 'É' => 'E', 'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I', 'Î' => 'I',
        'Ï' => 'I', 'Ñ' => 'N', 'Å' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'O', 'Ø' => 'O', 'Ù' => 'U', 'Ú' => 'U',
        'Û' => 'U', 'Ü' => 'U', 'Ý' => 'Y', 'Þ' => 'B', 'ß' => 'Ss', 'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a',
        'å' => 'a', 'æ' => 'a', 'ç' => 'c', 'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i',
        'ï' => 'i', 'ð' => 'o', 'ñ' => 'n', 'Å' => 'n', 'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o', 'ø' => 'o', 'ù' => 'u',
        'ú' => 'u', 'û' => 'u', 'ü' => 'u', 'ý' => 'y', 'ý' => 'y', 'þ' => 'b', 'ÿ' => 'y', 'ƒ' => 'f',
        'Ä' => 'a', 'î' => 'i', 'â' => 'a', 'È' => 's', 'È' => 't', 'Ä' => 'A', 'Î' => 'I', 'Â' => 'A', 'È' => 'S', 'È' => 'T',
    );
    // substitui os caracteres especiais
    $nova_string = strtr($string, $caracteres_especiais);
    $del = array(";", ",", ".", "'", "\\", "\x");
    $nova_string = str_replace($del, "", $nova_string);
    // retorna a nova string
    return $nova_string;
}

// TRATA O CAMPO OUTROS
// TEM UM PROBLEMA COM A PALAVRA UNIÃO CORRIGIDA AQUI
function trata_outro($string_read) {
    // Procura pela letra ''' na string
    $string = mb_strtoupper($string_read, 'UTF-8');
    $del = array(",", ".", "'", "\\", "\x");
    $string = str_replace($del, "", $string);

    $caracteres_especiais = array(
        'Š' => 'S', 'š' => 's', 'Ð' => 'Dj', 'Â' => 'Z', 'Â' => 'z', 'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A',
        'Å' => 'A', 'Æ' => 'A', 'Ç' => 'C', 'È' => 'E', 'É' => 'E', 'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I', 'Î' => 'I',
        'Ï' => 'I', 'Ñ' => 'N', 'Å' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'O', 'Ø' => 'O', 'Ù' => 'U', 'Ú' => 'U',
        'Û' => 'U', 'Ü' => 'U', 'Ý' => 'Y', 'Þ' => 'B', 'ß' => 'Ss', 'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a',
        'å' => 'a', 'æ' => 'a', 'ç' => 'c', 'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i',
        'ï' => 'i', 'ð' => 'o', 'ñ' => 'n', 'Å' => 'n', 'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o', 'ø' => 'o', 'ù' => 'u',
        'ú' => 'u', 'û' => 'u', 'ü' => 'u', 'ý' => 'y', 'ý' => 'y', 'þ' => 'b', 'ÿ' => 'y', 'ƒ' => 'f',
        'Ä' => 'a', 'î' => 'i', 'â' => 'a', 'È' => 's', 'È' => 't', 'Ä' => 'A', 'Î' => 'I', 'Â' => 'A', 'È' => 'S', 'È' => 'T',
    );

    $nova_string = strtr($string, $caracteres_especiais);

    if ($string_read[0] == "U" && $string_read[1] == "N" && $string_read[2] == "I")
        $nova_string = "UNIAO";

    //if (strlen($nova_string) > 1)
    //echo $nova_string."<BR>";
    return $nova_string;
}


// TRATA ACENTOS
function trata_acento($string) {
    // Procura pela letra ''' na string
    $del = array(",", ".", "'", "\\", "\x");
    $string = str_replace($del, "", $string);
    // TRANSFORMA MAIUSCULO
    $string = strtoupper($string);
    // array de caracteres especiais
    $caracteres_especiais = array(
        'á' => 'Á' , 'à' => 'À' , 'ã' => 'Ã' , 'ä' => 'A' , 'â' => 'Â' ,
        'é' => 'É' , 'ê' => 'Ê' ,
        'í' => 'Í' , 'î' => 'I' , 'ï' => 'I' ,
        'ó' => 'Ó' , 'õ' => 'Õ' , 'ô' => 'Ô' , 'ö' => 'O' ,
        'ú' => 'Ú' , 'ü' => 'U' ,
        'ç' => 'Ç' ,
    );
    $nova_string = strtr($string, $caracteres_especiais);
    return $nova_string;
}

// FUNCAO CORRIGE DATA
function corrige_data($linear_date) {
    $year = substr($linear_date, 0, 4);
    $month = substr($linear_date, 4, 2);
    $day = substr($linear_date, 6, 2);

    $formatted_date = $year . "-" . $month . "-" . $day;

    return $formatted_date;
}

/*
 * 
 * DIRETORIO
 * 
 */
$down_dir = $_SERVER['DOCUMENT_ROOT'] . "/CNPJ/DOWNLOADS";
$arquivos_split = shell_exec("find {$down_dir}/split/ -name 'st*' |sort |head -15");

$arquivos_split = explode("\n", $arquivos_split);

foreach ($arquivos_split as $file_split) {
    // caso 
    if (strlen($file_split) > 1) {
        $file = fopen($file_split, "r");

        $sql_ini = "INSERT INTO estabelecimento VALUES ";

        while (!feof($file)) {
            $read++;
            $line = fgets($file);

            // RETIRANDO CARACTERES
            $line = str_replace("'", "\'", $line);

            // CRIANDO UM ARRAY COM OS DADOS
            $array = explode('";"', $line);
            $array = str_replace("\"", "", $array);

            $res[0] = $array[0];    // cnpj
            $res[1] = $array[1];    // filiar
            $res[2] = $array[2];    // digito
            $res[3] = $array[3];    // matriz

            if (strlen($array[4]) < 4)
                $res[4] = '';
            else
                $res[4] = trata_razao($array[4]);   // nome fantasia

            $res[5] = $array[5];    // situacao

            if (strlen($array[6]) < 4)
                $res[6] = '';
            else
                $res[6] = corrige_data($array[6]);  // data situacao

            $res[7] = $array[7];    // motivo situacao
            $res[8] = trata_outro($array[8]);    // col 11
            $res[9] = $array[9];    // col 12

            if (strlen($array[10]) < 4)
                $res[10] = '';
            else
                $res[10] = corrige_data($array[10]);

            $res[11] = $array[11];  // cnae fiscal principal
            $res[12] = $array[12];  // outros cnaes
            $res[13] = trata_outro($array[13]);  // log tipo
            $res[14] = trata_outro($array[14]);  // logradouro
            $res[15] = trata_outro($array[15]);  // numero
            $res[16] = trata_outro($array[16]);  // complemento
            $res[17] = trata_outro($array[17]);  // bairro
            $res[18] = $array[18];
            $res[19] = $array[19];
            $res[20] = $array[20];
            $res[21] = $array[21];
            $res[22] = $array[22];
            $res[23] = $array[23];
            $res[24] = $array[24];
            $res[25] = $array[25];
            $res[26] = $array[26];
            $res[27] = trata_outro($array[27]); //email
            $res[28] = $array[28];
            $res[29] = $array[29];  // capital?
            $del = array("\"", ",", ".", "R", "$", "S", "U");
            $res[29] = str_replace($del, "", $res[29]);

            if (strlen($res[0]) > 2) {
                $sql_add .= "(NULL,CURRENT_TIMESTAMP(),'{$res[0]}','{$res[1]}','{$res[2]}','{$res[3]}',\"{$res[4]}\",'{$res[5]}','{$res[6]}','{$res[7]}','{$res[8]}','{$res[9]}','{$res[10]}','{$res[11]}','{$res[12]}','{$res[13]}','{$res[14]}','{$res[15]}','{$res[16]}','{$res[17]}','{$res[18]}','{$res[19]}','{$res[20]}','{$res[21]}','{$res[22]}','{$res[23]}','{$res[24]}','{$res[25]}','{$res[26]}','{$res[27]}','{$res[28]}','{$res[29]}'),";
            }
        }
        $sql_add = substr($sql_add, 0, strlen($sql_add) - 1);
        $sql = $sql_ini . $sql_add;
        try {
            $inn = $pdo->query($sql);
            unset($sql_add);
        } catch (PDOException $error) {
            $errorSQL = $error->getMessage();
            echo 'INSERT Failed: ' . $errorSQL;
            exit();
        }
    }
    // vai apagando os arquivos
    shell_exec("rm {$file_split}");
}
// exclui os arquivos temporarios
//shell_exec("rm {$down_dir}/split/*");
//shell_exec("rm {$down_dir}/unzip/*");
// calcula o tempo de execucao do script e printa ele
$end = microtime(true);
$final = $end - $start;
echo "<BR><BR>Script Exec: {$final} s<BR>Total: {$read} lines";
