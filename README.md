<div align="center">

# ✨ myst.sh

**State-of-the-Art Bash Templating Engine**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/butter-sh/myst.sh/test.yml?branch=main&style=flat-square&logo=github)](https://github.com/butter-sh/myst.sh/actions)
[![Version](https://img.shields.io/github/v/tag/butter-sh/myst.sh?style=flat-square&label=version&color=4ade80)](https://github.com/butter-sh/myst.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-myst-22c55e?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMjEgMTZWOGEyIDIgMCAwIDAtMS0xLjczbC03LTRhMiAyIDAgMCAwLTIgMGwtNyA0QTIgMiAwIDAgMCAzIDh2OGEyIDIgMCAwIDAgMSAxLjczbDcgNGEyIDIgMCAwIDAgMiAwbDctNEEyIDIgMCAwIDAgMjEgMTZ6IiBzdHJva2U9IiM0YWRlODAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PHBvbHlsaW5lIHBvaW50cz0iMy4yNyA2Ljk2IDEyIDEyLjAxIDIwLjczIDYuOTYiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48bGluZSB4MT0iMTIiIHkxPSIyMi4wOCIgeDI9IjEyIiB5Mj0iMTIiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4=)](https://butter-sh.github.io/myst.sh)

*Mustache-style templating with inheritance, partials, and multiple input formats*

[Documentation](https://butter-sh.github.io/myst.sh) • [GitHub](https://github.com/butter-sh/myst.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Features

🎨 **Mustache-Style Syntax** - Clean, intuitive template syntax with `.myst` file extension

📝 **Rich Template Features**
- String interpolation: `{{variable}}`
- Conditional blocks: `{{#if}}...{{/if}}`
- Loop structures: `{{#each}}...{{/each}}`
- Template partials/transclusion: `{{> partial}}`
- Template inheritance with slots: `{{#extend}}...{{/extend}}`

🔌 **Multiple Input Formats**
- JSON files
- YAML files (requires `yq`)
- Environment variables
- Command-line arguments
- Standard input

🛠️ **Embeddable** - Use as standalone CLI or source as library in your own scripts

## Installation

### Using hammer.sh

```bash
hammer myst my-templates
cd my-templates
```

### Using arty.sh

```bash
# Add to your arty.yml
references:
  - https://github.com/butter-sh/myst.sh.git

# Install dependencies
arty deps

# Use via arty
arty exec myst render --help
```

### Manual Install

```bash
git clone https://github.com/butter-sh/myst.sh.git
cd myst.sh
chmod +x setup.sh
./setup.sh
```

## Dependencies

### Required

- `bash` 4.0+
- `jq` - For JSON parsing

### Optional

- `yq` - For YAML support (https://github.com/mikefarah/yq)

Install dependencies:

```bash
# Debian/Ubuntu
sudo apt-get install jq

# macOS
brew install jq

# For YAML support
brew install yq
# or
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq
```

## Template Syntax Reference

### String Interpolation

```mustache
{{variable_name}}
```

Simple variable substitution. Variables can be set via CLI, JSON, YAML, or environment.

### Conditionals

```mustache
{{#if variable}}
  Content shown if variable is truthy
{{/if}}

{{#unless variable}}
  Content shown if variable is falsy
{{/unless}}
```

Variables are considered truthy if they exist, are not empty, and are not `false` or `0`.

### Loops

```mustache
{{#each array_variable}}
  {{this}} or {{.}}
{{/each}}
```

For comma-separated values: `-v items="one,two,three"`

Inside loops, `{{this}}` or `{{.}}` refers to the current item.

### Partials

```mustache
{{> partial_name}}
```

Include external template file. Partial files should be named `partial_name.myst` or just `partial_name`.

### Template Inheritance

Layout template:

```mustache
<html>
  <head>{{slot:head}}</head>
  <body>{{slot:body}}</body>
</html>
```

Child template:

```mustache
{{#extend layout_name}}
  {{#slot head}}<title>Page Title</title>{{/slot}}
  {{#slot body}}<h1>Content</h1>{{/slot}}
{{/extend}}
```

## Use Cases

- **Static Site Generation** - Build websites from templates
- **Configuration Management** - Generate config files from templates
- **Documentation** - Create documentation with reusable components
- **Email Templates** - Generate personalized emails
- **Code Generation** - Scaffold projects and boilerplate
- **Reports** - Create reports from data
- **CI/CD Pipelines** - Generate deployment manifests

## Integration with butter.sh

myst.sh powers leaf.sh and is used throughout the butter.sh ecosystem:

```bash
# Install leaf.sh (which uses myst.sh)
arty install https://github.com/butter-sh/leaf.sh.git

# leaf.sh uses myst.sh for templating
arty exec leaf . --landing

# Generate project with hammer.sh
hammer myst my-templates

# Use myst.sh directly
arty exec myst render template.myst -j data.json
```

## Related Projects

Part of the butter.sh ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** - Bash library dependency manager
- **[hammer.sh](https://github.com/butter-sh/hammer.sh)** - Project generator from templates
- **[judge.sh](https://github.com/butter-sh/judge.sh)** - Testing framework with assertions
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** - Documentation generator (uses myst.sh)
- **[whip.sh](https://github.com/butter-sh/whip.sh)** - Release cycle management

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by [valknar](https://github.com/valknarogg)

---

<div align="center">

Part of the [butter.sh](https://github.com/butter-sh) ecosystem

**Unlimited. Independent. Fresh.**

</div>
