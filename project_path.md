<!-- TODO  missing project name-->
# create_human_rust_project_two

## Repo for the symbol to mark web links [![alt text][1]](./README.md)

## Start Date of project

```bash <!-- markdownlint-disable-line code-block-style -->
$ date
Wed Jun 11 04:23:36 PM CEST 2025
```

## OS-Version

```bash <!-- markdownlint-disable-line code-block-style -->
$ uname -a
Linux debian 6.1.0-28-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.119-1 (2024-11-22) x86_64 GNU/Linux
```

## The BASH script should check if a project folder exists, and if not, create a folder, otherwise ask what should happen

```bash
# Function: Check system requirements

#!/bin/bash

# Enable error handling and debugging
set -e
set -x

# Setup logging with timestamps
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/project_setup_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Color definitions for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Project configuration
HOME_DIR="$HOME"
PROJECT_NAME="uppercase-converter"
PROJECT_PATH="$HOME_DIR/$PROJECT_NAME"

# Function: Check system requirements
check_requirements() {
    echo "Checking system requirements..."
#NOTE     
    # Check and install required packages
    sudo apt-get update -qq
    sudo apt-get install -y -qq llvm lldb
    
    # Update Rust toolchain
    rustup update stable
    rustup component add llvm-tools-preview
    
    # Install cargo tools
    cargo install cargo-llvm-cov --quiet || true
    cargo install cargo-binutils --quiet || true
    
    # Install VS Code extensions
    code --install-extension ryanluker.vscode-coverage-gutters
    code --install-extension rust-lang.rust-analyzer
}

# Function: Setup project
setup_project() {
    if [ -d "$PROJECT_PATH" ]; then
        read -p "Project exists. Remove? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_PATH"
        else
            exit 1
        fi
    fi

    cargo new "$PROJECT_PATH" --lib
    cd "$PROJECT_PATH"
    
    # Add dependencies
    cargo add clap --features derive
    cargo add thiserror
    cargo add anyhow
    cargo add --dev assert_cmd
    cargo add --dev predicates
    
    # Create directory structure
    mkdir -p src/{bin,tests}
}

# Function: Setup project
setup_project() {
    if [ -d "$PROJECT_PATH" ]; then
        read -p "Project exists. Remove? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_PATH"
        else
            exit 1
        fi
    fi

    cargo new "$PROJECT_PATH" --lib
    cd "$PROJECT_PATH"
    
    # Add dependencies
    cargo add clap --features derive
    cargo add thiserror
    cargo add anyhow
    cargo add --dev assert_cmd
    cargo add --dev predicates
    
    # Create directory structure
    mkdir -p src/{bin,tests}
}

# Function: Create source files
create_source_files() {
    # Create error.rs first
    cat > src/error.rs << 'EOL'
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UppercaseError {
    #[error("Input string cannot be empty")]
    EmptyInput,
}
EOL

    # Create lib.rs
    cat > src/lib.rs << 'EOL'
mod error;

use crate::error::UppercaseError;

#[derive(Debug)]
pub struct Converter;

impl Converter {
    pub fn new() -> Self { Self }

    pub fn convert_to_uppercase(&self, input: &str) -> Result<String, UppercaseError> {
        if input.is_empty() {
            return Err(UppercaseError::EmptyInput);
        }
        Ok(input.to_uppercase())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new() {
        let converter = Converter::new();
        assert!(matches!(converter, Converter));
    }

    #[test]
    fn test_convert_to_uppercase() {
        let converter = Converter::new();
        assert_eq!(converter.convert_to_uppercase("hello").unwrap(), "HELLO");
        assert_eq!(converter.convert_to_uppercase("Test123").unwrap(), "TEST123");
    }

    #[test]
    fn test_empty_input() {
        let converter = Converter::new();
        assert!(converter.convert_to_uppercase("").is_err());
    }
}
EOL

    # Create main.rs
    cat > src/bin/main.rs << 'EOL'
use clap::{Command, Arg};
use std::process;
use uppercase_converter::Converter;

fn main() {
    let matches = Command::new("Uppercase Converter")
        .version("1.0")
        .about("Converts input strings to uppercase")
        .arg(
            Arg::new("input")
                .help("The string to convert to uppercase")
                .required(true)
                .index(1),
        )
        .get_matches();

    let input = matches.get_one::<String>("input").unwrap();
    let converter = Converter::new();
    
    match converter.convert_to_uppercase(input) {
        Ok(result) => println!("{}", result),
        Err(e) => {
            eprintln!("Error: {}", e);
            process::exit(1);
        }
    }
}
EOL
}

 Function: Configure VS Code settings
configure_vscode() {
    mkdir -p .vscode
    
    # Create VS Code settings
    cat > .vscode/settings.json << 'EOL'
{
    "cSpell.words": [
        "binutils",
        "lldb",
        "profdata",
        "profraw",
        "rustup",
        "RUSTFLAGS",
        "ryanluker"
    ],
    "cSpell.ignorePaths": [
        "node_modules",
        "**/node_modules",
        "**/node_modules/**",
        "target/**"
    ],
    "rust-analyzer.checkOnSave.command": "clippy",
    "coverage-gutters.lcovname": "target/llvm-cov/lcov.info",
    "coverage-gutters.showLineCoverage": true,
    "coverage-gutters.showRulerCoverage": true,
    "editor.formatOnSave": true
}
EOL

    # Create cspell configuration
    cat > .cspell.json << 'EOL'
{
    "version": "0.2",
    "language": "en",
    "words": [
        "binutils",
        "clippy",
        "lldb",
        "profdata",
        "profraw",
        "rustup",
        "RUSTFLAGS",
        "ryanluker"
    ],
    "flagWords": []
}
EOL
}

main() {
    # ...existing code...
    check_requirements || exit 1
    setup_project || exit 1
    configure_vscode || exit 1  # Add this line
    create_source_files || exit 1
    # ...existing code...
}
```

```    ```

>[!TIP]
>Fetch the link symbol from repo via command curl
>
>```bash
>curl --create-dirs --output-dir img -O  "https://raw.githubusercontent.com/MathiasStadler/link_symbol_svg/360d1327d05280d53de5fa816c522f89a35891ca/img/link_symbol.svg"
>```
<!-- To comply with the format -->
&nbsp;;
>[!TIP]
>cSpell - Enable / Disable checking sections of code [![alt text][1]](https://cspell.org/docs/Configuration/document-settings)
<!-- To comply with the format -->
>```text
><!-- spell-checker: disable -->
><!-- spell-checker: enable -->
>```
<!-- To comply with the format -->
&nbsp;;
>[!TIP]
>Shortcut to create a new file VSCode
<!-- To comply with the format -->
>```bash
>#code <file_name>
>code test.txt
>```

I never plan never far ahead. Carpe diam

<!-- Link sign - Don't Found a better way :-( - You know a better method? - send me a email -->
[1]: ./img/link_symbol.svg
