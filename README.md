# myst.sh

A state-of-the-art bash templating engine with mustache-style syntax, supporting template inheritance, partials, and multiple input formats.

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

```bash
# Clone or download
git clone https://github.com/yourorg/myst.sh.git
cd myst.sh

# Run setup
chmod +x setup.sh
./setup.sh

# Test it out
./myst.sh --help
```

## Quick Start

### Basic Example

Create a template file `hello.myst`:

```mustache
Hello, {{name}}!
You are {{age}} years old.
```

Render it:

```bash
./myst.sh render hello.myst -v name=John -v age=30
```

Output:
```
Hello, John!
You are 30 years old.
```

### Using JSON Variables

Create `vars.json`:

```json
{
  "title": "My Website",
  "author": "Jane Doe",
  "year": 2025
}
```

Template `page.myst`:

```mustache
<h1>{{title}}</h1>
<footer>© 2025 {{author}}</footer>
```

Render:

```bash
./myst.sh render page.myst -j vars.json
```

### Conditionals

Template `conditional.myst`:

```mustache
{{#if premium}}
Welcome Premium User!
{{/if}}

{{#unless premium}}
Upgrade to Premium today!
{{/unless}}
```

Render:

```bash
./myst.sh render conditional.myst -v premium=true
```

### Loops

Template `list.myst`:

```mustache
<ul>
{{#each items}}
  <li>{{this}}</li>
{{/each}}
</ul>
```

Render (comma-separated items):

```bash
./myst.sh render list.myst -v items="Apple,Banana,Cherry"
```

### Partials

Create partial `_header.myst`:

```mustache
<header>
  <h1>{{site_name}}</h1>
</header>
```

Main template `page.myst`:

```mustache
{{> _header}}
<main>
  {{content}}
</main>
```

Render with partials directory:

```bash
./myst.sh render page.myst -p ./partials -v site_name="My Site" -v content="Hello World"
```

### Template Inheritance

Layout file `layout.myst`:

```mustache
<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
</head>
<body>
  <header>{{slot:header}}</header>
  <main>{{slot:content}}</main>
  <footer>{{slot:footer}}</footer>
</body>
</html>
```

Child template `page.myst`:

```mustache
{{#extend layout}}

{{#slot header}}
<h1>Welcome to {{site_name}}</h1>
{{/slot}}

{{#slot content}}
<p>This is the main content.</p>
{{/slot}}

{{#slot footer}}
<p>© 2025 {{author}}</p>
{{/slot}}

{{/extend}}
```

Render:

```bash
./myst.sh render page.myst -l layout.myst -v site_name="MySite" -v year=2025 -v author="John"
```

## Usage

### Command Line

```bash
myst.sh render [OPTIONS] <template>
```

#### Template Input Options

- `<template>` - Path to `.myst` template file
- `-d, --dir <path>` - Template directory (default: current directory)
- `-t, --template <file>` - Explicit template file path
- `--stdin` - Read template from standard input

#### Variable Input Options

- `-v, --var <key=value>` - Set single variable (repeatable)
- `-j, --json <file>` - Load variables from JSON file
- `-y, --yaml <file>` - Load variables from YAML file
- `-e, --env [prefix]` - Load environment variables (default prefix: `MYST_`)
- `--stdin-vars` - Read variables as JSON from stdin

#### Partials &amp; Layouts

- `-p, --partials <dir>` - Directory containing partial templates
- `-l, --layout <file>` - Layout template for inheritance

#### Output Options

- `-o, --output <file>` - Write output to file (default: stdout)

#### Other Options

- `-h, --help` - Show help message
- `-V, --version` - Show version
- `--debug` - Enable debug output

### Examples

```bash
# Basic variable substitution
./myst.sh render template.myst -v name=John -v title="Hello World"

# Load from JSON
./myst.sh render template.myst -j data.json

# Load from YAML
./myst.sh render template.myst -y config.yml

# Use environment variables
export MYST_USER=admin
export MYST_THEME=dark
./myst.sh render template.myst -e

# Custom environment prefix
export APP_NAME=MySite
./myst.sh render template.myst -e APP_

# From stdin
echo 'Hello {{name}}!' | ./myst.sh render --stdin -v name=World

# Complex example with everything
./myst.sh render page.myst \
  -j data.json \
  -y config.yml \
  -e \
  -v extra_var=value \
  -p ./partials \
  -l layout.myst \
  -o output.html

# Read template from directory
./myst.sh render -d ./templates page.myst -v title=Test

# Pipe to other commands
./myst.sh render email.myst -j user.json | sendmail user@example.com
```

## Embedding myst.sh as a Library

You can source `myst.sh` in your own bash scripts:

```bash
#!/usr/bin/env bash

# Source the myst engine
source ./myst.sh

# Set variables programmatically
myst_set_var "username" "alice"
myst_set_var "role" "admin"

# Load from JSON
myst_load_json "config.json"

# Load partials
myst_load_partials_dir "./partials"

# Render a template
template_content=$(cat template.myst)
result=$(myst_render "$template_content")

echo "$result"
```

### Available Functions

When sourcing `myst.sh`, these functions are available:

#### Variable Management

- `myst_set_var <key> <value>` - Set a template variable
- `myst_get_var <key> [default]` - Get a template variable
- `myst_load_json <file>` - Load variables from JSON
- `myst_load_yaml <file>` - Load variables from YAML
- `myst_load_env [prefix]` - Load environment variables
- `myst_load_stdin` - Load variables from stdin
- `myst_set_cli_var <key=value>` - Parse and set variable from assignment

#### Template Loading

- `myst_load_template <path>` - Load template file
- `myst_load_partial <name> [dir]` - Load a partial template
- `myst_load_partials_dir <dir>` - Load all partials from directory

#### Rendering

- `myst_render <content>` - Main render function
- `myst_render_vars <content>` - Render variable interpolations
- `myst_render_conditionals <content>` - Render if/unless blocks
- `myst_render_loops <content>` - Render each loops
- `myst_render_partials <content>` - Render partial inclusions
- `myst_render_inheritance <content>` - Process template inheritance

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

Partials are loaded from:
1. The directory specified with `-p` option
2. Current directory

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

Slots allow child templates to inject content into specific areas of the parent layout.

## Advanced Usage

### Processing Multiple Templates

```bash
#!/usr/bin/env bash

for template in templates/*.myst; do
  output="output/$(basename "$template" .myst).html"
  ./myst.sh render "$template" -j vars.json -o "$output"
done
```

### Building a Static Site Generator

```bash
#!/usr/bin/env bash

source ./myst.sh

# Load global config
myst_load_json "site.json"

# Load partials
myst_load_partials_dir "./partials"

# Load layout
MYST_LAYOUTS["main"]=$(cat "layouts/main.myst")

# Render pages
for page in pages/*.myst; do
  myst_set_var "page_name" "$(basename "$page" .myst)"
  result=$(myst_render "$(cat "$page")")
  
  output="dist/$(basename "$page" .myst).html"
  echo "$result" > "$output"
  echo "Generated: $output"
done
```

### Integration with CI/CD

```yaml
# .github/workflows/docs.yml
name: Generate Documentation

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq
          
      - name: Generate docs
        run: |
          chmod +x myst.sh
          ./myst.sh render docs/index.myst \
            -j docs/data.json \
            -p docs/partials \
            -o public/index.html
            
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
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

## Use Cases

- **Static Site Generation** - Build websites from templates
- **Configuration Management** - Generate config files from templates
- **Documentation** - Create documentation with reusable components
- **Email Templates** - Generate personalized emails
- **Code Generation** - Scaffold projects and boilerplate
- **Reports** - Create reports from data
- **CI/CD Pipelines** - Generate deployment manifests
- **Microservices** - Template-based service configuration

## Design Philosophy

**myst.sh** follows these principles:

1. **Simplicity** - Easy to understand syntax, minimal learning curve
2. **Pure Bash** - No external language dependencies, just bash + jq
3. **Composability** - Can be used standalone or embedded in other tools
4. **Flexibility** - Multiple ways to provide data and templates
5. **Unix Philosophy** - Do one thing well, play nice with pipes

## Comparison with Other Tools

| Feature | myst.sh | mustache | Jinja2 | erb |
|---------|---------|----------|--------|-----|
| Language | Bash | Various | Python | Ruby |
| Template Inheritance | ✅ | ❌ | ✅ | ✅ |
| Partials | ✅ | ✅ | ✅ | ✅ |
| Logic-less | ❌ | ✅ | ❌ | ❌ |
| JSON Input | ✅ | ✅ | ✅ | ✅ |
| YAML Input | ✅ | Varies | ✅ | ✅ |
| ENV Input | ✅ | ❌ | ✅ | ❌ |
| Standalone Binary | ❌ | ✅ | ❌ | ❌ |
| Embeddable | ✅ | ✅ | ✅ | ✅ |
| Shell Integration | ✅ | ❌ | ❌ | ❌ |

## Limitations

- **Array Support** - Currently basic (comma-separated). For complex array operations, pre-process with `jq`
- **Nested Objects** - Flat variable namespace. Use dot notation in JSON keys if needed
- **Performance** - Being pure bash, not optimized for very large templates
- **Whitespace** - Mustache-style whitespace handling not fully implemented

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Roadmap

- [ ] Enhanced array and object support
- [ ] Helper functions (date formatting, string manipulation)
- [ ] Template validation and linting
- [ ] Performance optimizations
- [ ] More examples and templates
- [ ] Plugin system
- [ ] Caching layer for partials
- [ ] HTML/XML escaping
- [ ] Custom delimiters

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Created by the myst.sh team.

Inspired by:
- [Mustache](https://mustache.github.io/)
- [Handlebars](https://handlebarsjs.com/)
- [Jinja2](https://jinja.palletsprojects.com/)

## Support

- **Issues**: https://github.com/yourorg/myst.sh/issues
- **Discussions**: https://github.com/yourorg/myst.sh/discussions
- **Documentation**: https://yourorg.github.io/myst.sh

---

**Built with ❤️ using pure bash**
