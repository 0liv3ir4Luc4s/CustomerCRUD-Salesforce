# Prática de Desenvolvimento - Automação de Customer

## Requisitos
- Contexto de Trigger em Massa
- Modelo de desenvolvimento Trigger - Handler - Util
- Tipo de registro para Customer e Conta, Pessoa Física e Pessoa Jurídica
- Manter padrão BR em CPF, CNPJ e Telefone

### Campos do objeto Customer
- Nome (Texto, obrigatório, único)
- Conta relacionada (Pesquisa)
- Status (Lista de opções, obrigatório)
- Novo
- Em análise
- Enviado para integração *
- Integrado
- CPF (Inteiro, obrigatório quando Pessoa Física) - View: Apenas Layout PF
- CNPJ (Inteiro, obrigatório quando Pessoa Jurídica) - View: Apenas Layout PJ
- Telefone (Telefone)
- E-mail (Email)

### 1. Automação, Conta relacionada não preenchida
- Não deve ser possível criar um registro de Customer com CPF/CNPJ já cadastrado
em alguma Conta (Ao atualizar esta regra deve ser reproduzida)
- Para Customers recém criados, campo status deve ser obrigatoriamente Novo
- Campo status apenas pode ser passado para Enviado para integração se
Telefone/E-mail estiver preenchido
- Quando status for Enviado para integração:
- Deve ser iniciado um Processo de aprovação
- Caso o Processo seja recusado: 
<br/> ⇾ Status deve voltar para Em análise
- Caso o Processo seja aprovado:
<br/> ⇾ Deve ser criado uma Conta utilizando os dados necessários de Customer
<br/> ⇾ Também, deve ser criado um Contato utilizando os dados de Customer
<br/> ⇾ Campo Conta relacionada deve ser preenchido com essa Conta
<br/> ⇾ Status deve ser alterado para Integrado
<br/> ⇾ Não deve mais ser possível alterar Customer

### 2. Automação, Conta relacionada preenchida
- O valor do CPF/CNPJ deve ser preenchido de acordo com a Conta relacionada
- Não deve ser possível modificar CPF/CNPJ inserido
- Para Customers recém criados, campo status deve ser obrigatoriamente Novo
- Campo status apenas pode ser passado para Enviado para integração se
Telefone/E-mail estiver preenchido
- Quando status for Enviado para integração:
- Deve ser iniciado um Processo de aprovação
- Caso o Processo seja recusado: 
<br/> ⇾ Status deve voltar para Em análise
- Caso o Processo seja aprovado:
<br/> ⇾ Deve ser criado um Contato utilizando os dados de Customer
<br/> ⇾ Status deve ser alterado para Integrado
<br/> ⇾ Não deve mais ser possível alterar Customer

- Caso os dados da Conta referente ao campo Conta relacionada sejam
modificados, as alterações devem ser refletidas em Customer

### 3. Delete de Customer e Classes de Teste
##### 1. Customer com Conta relacionada sem outros contatos:
- Deletar Customer, Conta e Contato gerados pelo customer.
##### 2. Customer com Conta relacionada com outros contatos:
- Deletar Customer e Contato gerado pelo customer.
##### 3. Deletar Contato:
- Deletar Contato e Customer que gerou esse contato.
##### 4. Deletar Conta:
- Deletar Conta, Contatos e Customers referentes àquela Conta.
##### 5. Desenvolver todas as Classes de Teste necessárias.
