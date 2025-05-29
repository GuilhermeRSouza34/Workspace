<?php
include "functions.php";

//Se a sessão não estiver criada, inicia ela
if (!isset($_SESSION))
  session_start();

//Se não tiver usuário, redireciona para o login
if (!isset($_SESSION['FranqueadorUserID'])) {
  session_destroy();
  header("Location: login.php");
  exit;
}

$filial = "";
$nf = "";
$serie = "";
$conteudo = "";
$encode = "";

//Se algum dos parâmetros estiver vazios
if ( (!isset($_GET['filial']) && empty($_GET['filial'])) || (!isset($_GET['nf']) && empty($_GET['nf'])) || (!isset($_GET['serie']) && empty($_GET['serie'])) ) {
	echo 'Falha, parâmetros inválidos!';
	exit;
}

//Define os valores dos parâmetros em variáveis
$filial = $_GET['filial'];
$nf = $_GET['nf'];
$serie = $_GET['serie'];

$token = 'TOKEN_DO_SEU_ERP';
$urlWsdl = 'http://link:porta/ws/ZWSINVOICE.apw?WSDL';
$invoiceWS = null;

// Conexao com WebService
try {
	$soapClient = new SoapClient($urlWsdl, ['exceptions' => true]);
} catch (SoapFault $exception) {
	$conteudo = 'Houve um erro ao buscar os dados, <b>contate o Administrador</b>. Exception: <br>';
	$conteudo .= $exception->getMessage();
}

if (empty($conteudo)) {
	
	/* Carregamento dos dados do Vendedor */
	try {
		$requestData = array(
			"GETDANFE" => array(
				"CDANFERECE" => 
					'{'.
					'	"Dados": {'.
					'		"Filial":"'. $filial .'", '.
					'		"NotaFiscal":"'. $nf .'", '.
					'		"Serie":"'. $serie .'" '.
					'	},'.
					'	"Token": "'.$token.'"'.
					'}'
				)
			);
		
		$response = $soapClient->__soapCall("GETDANFE", $requestData);

		$jsonResult = json_decode($response->GETDANFERESULT);
		if (json_last_error() == 0) {
			$invoiceWS = $jsonResult->Dados;
			$encode = $invoiceWS->Danfe;
		}
		else {
			/*
			echo '<br><center>';
			switch (json_last_error()) {
		        case JSON_ERROR_NONE:
		            echo ' - No errors';
		        break;
		        case JSON_ERROR_DEPTH:
		            echo ' - Maximum stack depth exceeded';
		        break;
		        case JSON_ERROR_STATE_MISMATCH:
		            echo ' - Underflow or the modes mismatch';
		        break;
		        case JSON_ERROR_CTRL_CHAR:
		            echo ' - Unexpected control character found';
		        break;
		        case JSON_ERROR_SYNTAX:
		            echo ' - Syntax error, malformed JSON';
		        break;
		        case JSON_ERROR_UTF8:
		            echo ' - Malformed UTF-8 characters, possibly incorrectly encoded';
		        break;
		        default:
		            echo ' - Unknown error';
		        break;
		    }
		    echo 'json: ' . json_encode($jsonResult, JSON_PRETTY_PRINT);
		    echo '</center><br>';
		    */
		    $conteudo = "Falha no JSON!";
		}
		
	} catch (SoapFault $exception) {
		$conteudo = 'Houve um erro ao buscar os dados, <b>contate o Administrador</b>. Exception: <br>';
		$conteudo .= $exception->getMessage();
	}
}

//Define o arquivo pdf
$decoded = base64_decode($encode);
$file = "pdfs/" . $nf . "_" . $serie . ".pdf";
file_put_contents($file, $decoded);

//Se existir, mostra um prompt para download
if (file_exists($file)) {
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="'.basename($file).'"');
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($file));
    readfile($file);
    exit;
}

?>