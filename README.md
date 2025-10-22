<div align="center">

<img src="./icon.svg" width="100" height="100" alt="myst.sh">

# myst.sh

**Bash Templating Engine**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-22c55e?style=for-the-badge)](https://github.com/butter-sh/myst.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-myst-4ade80?style=for-the-badge)](https://butter-sh.github.io)

*Advanced mustache-style templating with conditionals, loops, partials, inheritance, and multi-format input*

[Documentation](https://butter-sh.github.io/myst.sh) • [GitHub](https://github.com/butter-sh/myst.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Overview

myst.sh is a state-of-the-art templating engine for bash, bringing powerful mustache-style template processing to shell scripts. With support for conditionals, loops, partials, and template inheritance, it enables sophisticated text generation from structured data.

### Key Features

- **Mustache Syntax** — Clean, intuitive template syntax with `.myst` extension
- **Conditionals & Loops** — Full control flow with `{{#if}}` and `{{#each}}`
- **Partials & Inheritance** — Reusable components and template layouts
- **Multi-Format Input** — JSON, YAML, environment variables, CLI args
- **Nested Data Access** — Dot notation for deep object traversal
- **Embeddable** — Use as CLI or source as library

---

## Installation

### Using arty.sh

```bash
arty install https://github.com/butter-sh/myst.sh.git
arty exec myst --help
```

### Manual Installation

```bash
git clone https://github.com/butter-sh/myst.sh.git
cd myst.sh
sudo cp myst.sh /usr/local/bin/myst
sudo chmod +x /usr/local/bin/myst
```

### Using hammer.sh

```bash
hammer myst my-templates
cd my-templates
```

---

## System Requirements

- **Bash** 4.0 or higher
- **jq** for JSON processing
- **yq** (optional) for YAML support

---

## Usage

### Basic Usage

```bash
# From JSON file
myst template.myst -d data.json -o output.txt

# From YAML file
myst template.myst -y config.yml -o output.txt

# From command-line variables
myst template.myst -v name=John -v age=30

# From environment variables
export NAME="John"
myst template.myst -e

# From stdin
echo '{"name": "John"}' | myst template.myst
```

### Options

```bash
-d, --data FILE       Load data from JSON file
-y, --yaml FILE       Load data from YAML file
-v, --var KEY=VALUE   Set variable from command line
-e, --env             Use environment variables
-o, --output FILE     Write output to file
-p, --partial DIR     Directory for partial templates
-h, --help            Show help message
```

---

## Template Syntax

### Variables

```mustache
Hello, {{name}}!
Your email is {{user.email}}
```

### Conditionals

```mustache
{{#if logged_in}}
  Welcome back, {{username}}!
{{/if}}

{{#if admin}}
  You have admin privileges.
{{else}}
  You have standard access.
{{/if}}
```

### Loops

```mustache
{{#each users}}
  - {{name}} ({{email}})
{{/each}}
```

### Nested Data

```mustache
{{user.profile.firstName}} {{user.profile.lastName}}
{{company.address.city}}, {{company.address.country}}
```

### Partials

**template.myst:**
```mustache
<html>
  {{> header}}
  <body>
    {{> content}}
  </body>
  {{> footer}}
</html>
```

**partials/header.myst:**
```mustache
<head>
  <title>{{title}}</title>
</head>
```

### Template Inheritance

**base.myst:**
```mustache
<!DOCTYPE html>
<html>
  <head>
    {{#slot:head}}
      <title>Default Title</title>
    {{/slot:head}}
  </head>
  <body>
    {{#slot:content}}
      Default content
    {{/slot:content}}
  </body>
</html>
```

**page.myst:**
```mustache
{{#extend:base}}
  {{#fill:head}}
    <title>{{page_title}}</title>
  {{/fill:head}}

  {{#fill:content}}
    <h1>{{heading}}</h1>
    <p>{{body}}</p>
  {{/fill:content}}
{{/extend:base}}
```

---

## Examples

### Example 1: Configuration File Generation

**template.myst:**
```mustache
server {
  listen {{port}};
  server_name {{domain}};

  {{#if ssl}}
  ssl_certificate {{ssl.cert}};
  ssl_certificate_key {{ssl.key}};
  {{/if}}

  location / {
    proxy_pass {{backend}};
  }
}
```

**data.json:**
```json
{
  "port": 443,
  "domain": "example.com",
  "ssl": {
    "cert": "/etc/ssl/cert.pem",
    "key": "/etc/ssl/key.pem"
  },
  "backend": "http://localhost:3000"
}
```

**Usage:**
```bash
myst template.myst -d data.json -o nginx.conf
```

### Example 2: Email Template

**email.myst:**
```mustache
To: {{recipient.email}}
Subject: {{subject}}

Hello {{recipient.name}},

{{#if has_items}}
Your order contains:
{{#each items}}
  - {{name}}: ${{price}}
{{/each}}

Total: ${{total}}
{{else}}
Your cart is empty.
{{/if}}

Thank you!
```

**Usage:**
```bash
myst email.myst -d order.json -o email.txt
```

### Example 3: Documentation Generation

**readme.myst:**
```mustache
# {{project.name}}

{{project.description}}

## Installation

\`\`\`bash
{{install.command}}
\`\`\`

## Features

{{#each features}}
- **{{name}}** — {{description}}
{{/each}}

## License

{{license}}
```

**Usage:**
```bash
myst readme.myst -y project.yml -o README.md
```

---

## Integration with arty.sh

Add myst.sh to your project's `arty.yml`:

```yaml
name: "my-project"
version: "1.0.0"

references:
  - https://github.com/butter-sh/myst.sh.git

scripts:
  generate: "arty exec myst templates/main.myst -d data.json"
  docs: "arty exec myst templates/readme.myst -y config.yml -o README.md"
```

Then run:

```bash
arty deps       # Install myst.sh
arty generate   # Generate from templates
arty docs       # Generate documentation
```

---

## Embedding in Scripts

Use myst.sh as a library in your own scripts:

```bash
#!/usr/bin/env bash

# Source myst.sh
source <(arty source myst)

# Use myst functions
render_template "template.myst" "data.json" "output.txt"
```

---

## Related Projects

Part of the [butter.sh](https://github.com/butter-sh) ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** — Dependency manager
- **[judge.sh](https://github.com/butter-sh/judge.sh)** — Testing framework
- **[hammer.sh](https://github.com/butter-sh/hammer.sh)** — Project scaffolding (uses myst.sh)
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** — Documentation generator (uses myst.sh)
- **[whip.sh](https://github.com/butter-sh/whip.sh)** — Release management
- **[clean.sh](https://github.com/butter-sh/clean.sh)** — Linter and formatter

---

## License

MIT License — see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">

**Part of the [butter.sh](https://github.com/butter-sh) ecosystem**

*Unlimited. Independent. Fresh.*

Crafted by [Valknar](https://github.com/valknarogg)

</div>
