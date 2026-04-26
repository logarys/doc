# User management

Logarys user management is designed around role-based access.

## Recommended roles

| Role | Description |
|---|---|
| Admin | Full platform access |
| Operator | Can inspect logs and manage selected operational resources |
| Viewer | Read-only access to logs and dashboards |

## Permission matrix

| Action | Admin | Operator | Viewer |
|---|---:|---:|---:|
| View logs | Yes | Yes | Yes |
| Run queries | Yes | Yes | Yes |
| Create pipeline | Yes | Optional | No |
| Edit pipeline | Yes | Optional | No |
| Delete pipeline | Yes | No | No |
| Manage users | Yes | No | No |
| Edit global config | Yes | No | No |

## User fields

| Field | Description |
|---|---|
| `id` | Unique technical identifier |
| `name` | Display name |
| `email` | Login email |
| `passwordHash` | Hashed password |
| `role` | User role |
| `enabled` | Account status |
| `createdAt` | Creation date |
| `updatedAt` | Last update date |

## Create the first admin

```bash
docker exec -it logarys-console-manager npm run user:create -- \
  --name "Admin" \
  --email "admin@logarys.local" \
  --password "change-me"
```

!!! warning
    Always change the initial password after the first login.

## Profile update

Users should be able to update name, email, and password.

## Disable instead of delete

For auditability, prefer disabling a user instead of deleting it immediately.

## Security best practices

Use strong passwords, never store plain passwords, rotate admin credentials, use HTTPS, avoid shared accounts, and log user management actions.
