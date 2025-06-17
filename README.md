# Sistema de Autorização com OPA (RBAC)

## Visão Geral

Este projeto implementa um sistema de controle de acesso baseado em roles (RBAC) utilizando [Open Policy Agent (OPA)](https://www.openpolicyagent.org/). Ele avalia se um usuário tem permissão para executar determinadas ações com base em seus grupos de afiliação e nas permissões associadas a esses grupos.

---

## Estrutura de Arquivos

```
.
├── authz.rego             # Política de autorização principal
├── group_roles.json       # Mapeamento de grupos para roles
├── roles_permissions.json # Permissões por role para cada recurso
└── input.json             # Exemplo de entrada para teste
```

---

## Componentes Principais

### 1. `group_roles.json`

Mapeia grupos organizacionais para roles funcionais:

```json
{
  "group_roles": {
    "GRP_MFO_Master": "Admin",
    "GRP_MFO_Employee": "Employee",
    "GRP_MFO_Auditor": "Auditor"
    // ... outros mapeamentos
  }
}
```

---

### 2. `roles_permissions.json`

Define as permissões para cada role em diferentes recursos:

```json
{
  "roles_permissions": {
    "modulo": {
      "recurso": {
        "Role": ["create", "read", "update", "delete"]
      }
    }
  }
}
```

---

### 3. `authz.rego`

A política principal que:

- Analisa o ARN (Amazon Resource Name) da requisição  
- Verifica as permissões do usuário  
- Registra logs de auditoria  

---

## Como Executar

### 1. Baixe o OPA

https://www.openpolicyagent.org/

### 2. Inicie o servidor OPA

```bash
./opa run --server --set=decision_logs.console=true authz.rego group_roles.json roles_permissions.json
```

### 3. Envie requisições para avaliar permissões

```bash
curl -X POST http://localhost:8181/v1/data/authz/allow   -H "Content-Type: application/json"   -d @input.json
```

---

## Exemplo de Entrada (`input.json`)

```json
{
  "input": {
    "user.name": "leo.dias",
    "arn": "org:com:sn::mod:func/action",
    "groups": ["GRP_EMP_Standard"]
  }
}
```

---

## Formato do ARN

O sistema espera ARNs no formato:

```
org:community:domain:service:module/recurso/action
```

**Exemplo:**  
```
org:com:sn::santo:graal/read
```

---

## Logs de Auditoria

O sistema gera logs no formato:

```
AuditLog: modulo/recurso/action
```

---

## Testando a Política

Para testar localmente sem o servidor:

```bash
opa eval -d authz.rego -d group_roles.json -d roles_permissions.json -i input.json "data.authz.allow"
```

---

## Modelo de Decisão

- Extrai módulo, recurso e ação do ARN  
- Mapeia grupos do usuário para roles  
- Verifica se alguma role associada ao usuário tem a permissão necessária  
- Retorna `true` se permitido, `false` caso contrário  

---

## Personalização

- Atualize `group_roles.json` com seus grupos organizacionais  
- Modifique `roles_permissions.json` para refletir sua matriz de permissões  
- Ajuste o parser de ARN em `authz.rego` se necessário  

---

> Desenvolvido com ❤️ utilizando OPA para decisões de política seguras e auditáveis.