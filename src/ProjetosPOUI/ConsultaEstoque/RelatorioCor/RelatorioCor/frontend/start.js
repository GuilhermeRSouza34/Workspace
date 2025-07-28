const { execSync } = require('child_process');
const path = require('path');

// Muda para o diretório correto
process.chdir(__dirname);

// Executa o ng serve
try {
  const result = execSync('node ./node_modules/@angular/cli/bin/ng.js serve', {
    stdio: 'inherit',
    cwd: __dirname
  });
} catch (error) {
  console.error('Erro ao executar ng serve:', error.message);
}
