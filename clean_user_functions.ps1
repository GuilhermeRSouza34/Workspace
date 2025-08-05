# Script para remover User Functions e substituir por estrutura de classe
$filePath = "c:\Users\Guilherme Souza\WorkspacePe\Workspace\src\Advpl\ProjetosPessoais\Projetos\Tlpp\QualidadeAvancada.tlpp"

# Ler o conteúdo do arquivo
$content = Get-Content $filePath -Raw

# Remover todas as User Functions desnecessárias (manter apenas QualidadeRouter)
$content = $content -replace '@Get\("/qualidade/tendencias[^"]*"\)\s*\r?\n\s*User Function Qual\w+\(\)[^}]*?\r?\n\s*Return[^}]*?setResponse\([^)]*\)', ''
$content = $content -replace '@Get\("/qualidade/comparativo[^"]*"\)\s*\r?\n\s*User Function Qual\w+\(\)[^}]*?\r?\n\s*Return[^}]*?setResponse\([^)]*\)', ''
$content = $content -replace '@Get\("/qualidade/alertas[^"]*"\)\s*\r?\n\s*User Function Qual\w+\(\)[^}]*?\r?\n\s*Return[^}]*?setResponse\([^)]*\)', ''
$content = $content -replace '@Post\("/qualidade/[^"]*"\)\s*\r?\n\s*User Function Qual\w+\(\)[^}]*?\r?\n\s*Return[^}]*?setResponse\([^)]*\)', ''

# Remover User Functions restantes individualmente 
$content = $content -replace 'User Function QualTendencias\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualComparativo\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualAlertas\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualOtimizarAmostragem\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualGerarCertificado\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualMonitorarLotes\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''
$content = $content -replace 'User Function QualCriarTemplate\(\)[^}]*?Return oRest:setResponse\(cJson\)', ''

# Limpar linhas em branco duplascadas
$content = $content -replace '\r?\n\s*\r?\n\s*\r?\n', "`r`n`r`n"

# Salvar o arquivo
Set-Content $filePath $content -Encoding UTF8

Write-Host "User Functions removidas com sucesso! Mantida apenas QualidadeRouter como ponto de entrada único."
