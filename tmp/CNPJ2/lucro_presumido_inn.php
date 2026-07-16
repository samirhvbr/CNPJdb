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
        'á' => 'Á', 'à' => 'À', 'ã' => 'Ã', 'ä' => 'A', 'â' => 'Â',
        'é' => 'É', 'ê' => 'Ê',
        'í' => 'Í', 'î' => 'I', 'ï' => 'I',
        'ó' => 'Ó', 'õ' => 'Õ', 'ô' => 'Ô', 'ö' => 'O',
        'ú' => 'Ú', 'ü' => 'U',
        'ç' => 'Ç',
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
$arquivos = shell_exec("find {$down_dir} -name 'Lucro_Pre*' |sort |head -1");
$arquivos = explode("\n", $arquivos);

if (strlen($arquivos[0])>2)
    $arquivo = $arquivos[0];
else {
    echo "Não tem mais arquivos!";
    exit();
}


// SPLIT DO ARQUIVO
shell_exec("split --lines=155000 {$arquivo} -d {$down_dir}/split/ss");
shell_exec("rm {$arquivo}");
$arquivos_split = shell_exec("find {$down_dir}/split/ -name 'ss*' |sort");
$arquivos_split = explode("\n", $arquivos_split);

foreach ($arquivos_split as $file_split) {
    if (strlen($file_split) > 2) {
        $file = fopen($file_split, "r");
        $sql_ini = "INSERT INTO `z_lucro_presumido` VALUES ";
        while (!feof($file)) {
            
            $read++;

            $line = fgets($file);

            // RETIRANDO CARACTERES
            $line = str_replace("'", "\'", $line);
            $arrchar = array(".","-","/");
            $line = str_replace($arrchar, "", $line);

            // CRIANDO UM ARRAY COM OS DADOS
            $array = explode(',' , $line);
            
            $cnpj = str_pad($array[1],14,'0',STR_PAD_LEFT);
            if ($array[2] > 1) { $scp = str_pad($array[2],14,'0',STR_PAD_LEFT);
            } else { $scp = ''; }
            
            if ($array[0] != 'ano' && $array[0] != '')
                $sql_add .= "(NULL,CURRENT_TIMESTAMP(),'{$array[0]}','{$cnpj}','{$scp}','{$array[3]}','{$array[4]}'),";
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
shell_exec("rm {$down_dir}/split/*");
shell_exec("rm {$down_dir}/unzip/*");
$end = microtime(true);
$final = $end - $start;
echo "<BR><BR>Arquivo: {$arquivo}<BR><BR>Script Exec: {$final} s<BR>Total: {$read} lines";
