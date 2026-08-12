# 💻 Projetos das Aulas

Bem-vindos! Este repositório contém todos os projetos práticos desenvolvidos em sala de aula. 

## ⬇️ Como baixar o projeto do dia

Para não lotar o seu computador baixando todos os projetos de uma vez, vamos usar um recurso do Git chamado `sparse-checkout`. 

Abra o seu terminal e execute os 4 passos abaixo:

**1. Clone a estrutura do repositório (sem baixar os arquivos finais):**
```bash
git clone --no-checkout <URL_DO_SEU_REPOSITORIO_AQUI>

```

**2. Entre na pasta do repositório que acabou de ser criada:**

```bash
cd <NOME_DO_REPOSITORIO_AQUI>

```

**3. Informe ao Git qual pasta específica você quer baixar hoje:**
*(Substitua o nome da pasta pelo nome correto da aula)*

```bash
git sparse-checkout set aula-02-calculadora

```

**4. Baixe os arquivos da pasta escolhida:**

```bash
git checkout main

```
