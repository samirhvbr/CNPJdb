<html>
    
</html>

<?php
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Scripting/EmptyPHP.php to edit this template
 */

// TEMPO DE EXEC SCRIPT
$start = microtime(true);

//header('Content-Type: text/html; charset=UTF-8');

// Definindo Timezone
date_default_timezone_set('America/Sao_Paulo');

//ini_set('session.referer_check', 'TRUE');

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

// LE TODOS OS ARQUIVOS EMPRESAx.ZIP E LISTA ELES EM UM ARRAY
$arquivo = $down_dir . "/Motivos.zip";

// TIRA A ULTIMA LINHA CASO SEJA CRIADA EM BRANCO
$zip_obj = new ZipArchive;
$zip_obj->open($arquivo);
$zip_obj->extractTo($down_dir . "/unzip/");
$zip_obj->close();

$zip = zip_open($arquivo);
while ($res = zip_read($zip)) {
    $filename = zip_entry_name($res);
}

// PRECISA TROCAR O NOME DO ARQUIVO, ARQUIVO COM SIMBOLOS
shell_exec("rm {$arquivo}");
shell_exec("mv {$down_dir}/unzip/*CSV {$down_dir}/split/MOTIVO");
shell_exec("iconv -f ISO-8859-1 -t UTF-8//TRANSLIT {$down_dir}/split/MOTIVO -o {$down_dir}/split/MOTIVO.s");

$filedir = "{$down_dir}/split/MOTIVO.s";
$file = fopen($filedir, "r");

$sql_ini = "INSERT INTO motivo VALUES ";
while (!feof($file)) {
    $read++;

    $line = fgets($file);
    
    // RETIRANDO CARACTERES
    $line = str_replace("'", "\'", $line);

    // CRIANDO UM ARRAY COM OS DADOS
    $array = explode('";"', $line);
    $array = str_replace("\"", "", $array);

    $res[0] = $array[0];
    $res[1] = $array[1];
    $res[1] = trata_acento($res[1]);

    if (strlen($res[0]) > 1) {
        $sql_add .= "(NULL,CURRENT_TIMESTAMP(),'{$res[0]}','{$res[1]}'),";
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
shell_exec("rm {$down_dir}/split/*");
shell_exec("rm {$down_dir}/unzip/*");
$end = microtime(true);
$final = $end - $start;
echo "<BR><BR>Script Exec: {$final} s<BR>Total: {$read} lines";
