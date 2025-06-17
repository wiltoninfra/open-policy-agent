package authz

import data.roles_permissions
import data.group_roles

default allow = false

# Extrai partes do ARN
parse_arn(arn) = output if {
    parts := split(arn, ":")
    res_parts := split(parts[5], "/")
    output = {
        "org": parts[0],
        "community": parts[1],
        "domain": parts[2],
        "module": parts[4],
        "resource": res_parts[0],
        "action": res_parts[1]
    }
}

# Regra de autorização
allow if {
    parsed := parse_arn(input.arn)
    module := parsed.module
    resource := parsed.resource
    action := parsed.action

    some g
    g = input.groups[_]
    role := data.group_roles[g]

    perms := data.roles_permissions[module][resource][role]
    perms[_] == action

    full_path := concat("", ["AuditLog: ", module, "/", resource, "/", action, "\n"])
    trace(full_path)
    print(full_path)
}