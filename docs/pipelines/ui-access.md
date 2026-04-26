# Pipeline UI access

The Logarys UI provides an administration area for pipeline management.

## Access path

Typical path:

```txt
/pipelines
```

## Screens

### Pipeline list

The list should display name, ID, enabled state, input type, target collection, tags, and last update date.

### Create pipeline

The creation screen should ask for all configuration areas:

- metadata
- input
- parser
- transforms
- routing
- storage
- indexing
- access rules
- tags

### Edit pipeline

The edit screen should allow all pipeline parameters to be updated.

Recommended behavior:

- show validation errors before saving
- preserve unknown fields when possible
- clearly distinguish draft and enabled states
- require confirmation when disabling a production pipeline

## Permissions

| Action | Admin | Operator | Viewer |
|---|---:|---:|---:|
| List pipelines | Yes | Yes | No |
| View pipeline | Yes | Yes | No |
| Create pipeline | Yes | Optional | No |
| Edit pipeline | Yes | Optional | No |
| Delete pipeline | Yes | No | No |
| Enable or disable | Yes | Optional | No |

## UI design guidance

Use the Logarys visual identity: dark navy layout, left sidebar navigation, bordered cards, cyan primary button, readable labels, and clear error states.
