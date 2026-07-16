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



/*
 * 
 * DIRETORIO
 * 
 */
$down_dir = $_SERVER['DOCUMENT_ROOT'] . "/CNPJ/DOWNLOADS";

// LE TODOS OS ARQUIVOS EMPRESAx.ZIP E LISTA ELES EM UM ARRAY
$arquivos = shell_exec("find {$down_dir} -name 'Empre*zip' |sort");
//$arquivos = shell_exec("find {$down_dir}/ -name 'Empresas9.zip'");    // exclude
$arquivos = explode("\n", $arquivos);

// VARRE O QUE FIND
$xx = 0;
foreach ($arquivos as $file) {
    // TIRA A ULTIMA LINHA CASO SEJA CRIADA EM BRANCO
    if (strlen($file) > 2) {
        $zip_obj = new ZipArchive;
        $zip_obj->open($file);
        $zip_obj->extractTo($down_dir . "/unzip/");
        $zip_obj->close();

        $zip = zip_open($file);
        while ($res = zip_read($zip)) {
            $filename = zip_entry_name($res);
        }

        // move o arquivo descompactado para uma pasta onde será feito o split
        shell_exec("mv {$down_dir}/unzip/{$filename}* {$down_dir}/split/.");
        
        // split os arquivos em 250.000 linhas cada um        
        $linhas = 250000;
        
        shell_exec("split --lines={$linhas} {$down_dir}/split/{$filename} -d {$down_dir}/split/e{$xx}");
        // exclui o arquivo descompactado ficando só os arquivos split
        shell_exec("rm {$down_dir}/split/{$filename}");
        // exclui arquivo zip fonte
        shell_exec("rm {$file}");
    }
    $xx++;
}


$arquivos_split = shell_exec("find {$down_dir}/split/ -name 'e*' |sort");
$arquivos_split = explode("\n", $arquivos_split);

foreach ($arquivos_split as $file_split) {
    // caso 
    if (strlen($file_split) > 2) {
        $file = fopen($file_split, "r");

        $sql_ini = "INSERT INTO empresa VALUES ";

        while (!feof($file)) {
            $read++;
            $line = fgets($file);
            // RETIRANDO CARACTERES
            //$delv = array("L;","B;","F;","K;","P;","M;");
            //$line = str_replace($delv, "", $line);
            //$line = str_replace("LTDA;", "LTDA", $line);
            //$line = str_replace("\"", "", $line);
            $line = str_replace("'", "\'", $line);

            
            // CRIANDO UM ARRAY COM OS DADOS
            $array = explode('";"', $line);
            $array = str_replace("\"", "", $array);

            $cnpj = $array[0];
            $razao = trata_razao($array[1]);
            $outro = trata_outro($array[6]);
            
            $natureza = $array[2];
            $capital = $array[4];

            $estado = $array[3];
            if (strlen($estado) > 2)
                $estado = $estado[0] . $estado[1];
            $porte = $array[5];
            if (strlen($porte) > 2)
                $porte = $porte[0] . $porte[1];
            if (strlen($cnpj) > 10)
                $cnpj = $cnpj[0] . $cnpj[1] . $cnpj[2] . $cnpj[3] . $cnpj[4] . $cnpj[5] . $cnpj[6] . $cnpj[7] . $cnpj[8] . $cnpj[9];

            $capital = $array[4];
            $del = array("\"",",", ".", "R", "$", "S", "U");
            $capital = str_replace($del, "", $capital);
            if (strlen($capital) > 15)
                $capital = $capital[0] . $capital[1] . $capital[2] . $capital[3] . $capital[4] . $capital[5] . $capital[6] . $capital[7] . $capital[8] . $capital[9] . $capital[10] . $capital[11] . $capital[12] . $capital[13] . $capital[14];

            if (strlen($cnpj)>2 && strlen($razao)>3)
                if ($natureza != 0 && $natureza != 0000)
                    $sql_add .= "(NULL,CURRENT_TIMESTAMP(),'{$cnpj}',\"{$razao}\",'{$natureza}','{$estado}','{$capital}','{$porte}','{$outro}'),";
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
shell_exec("rm {$down_dir}/split/*");
shell_exec("rm {$down_dir}/unzip/*");

// calcula o tempo de execucao do script e printa ele
$end = microtime(true);
$final = $end - $start;
echo "<BR><BR>Script Exec: {$final} s<BR>Total: {$read} lines";
