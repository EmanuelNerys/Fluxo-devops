const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World! Deploy 100% automatizado no AWS ECS com sucesso!');
});

app.listen(port, () => {
  console.log(`App rodando na porta ${port}`);
});