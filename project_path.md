<!-- TODO  missing project name-->
# create_human_rust_project_two

>[!NOTE]
>Symbol to mark web external links [![alt text][1]](./README.md)
<!-- -->
>[!Note]
>Rust Profiling [![alt text][1]](https://doc.rust-lang.org/cargo/reference/profiles.html) a way to alter the compiler settings, influencing things like optimizations and debugging symbols.
<!-- -->
>[!NOTE]
>GCC optimization levels. Which is better? [![alt text][1]](https://stackoverflow.com/questions/32940860/gcc-optimization-levels-which-is-better)

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

# Get home directory and create project path
HOME_DIR="$HOME"
PROJECT_NAME="uppercase-converter"
PROJECT_PATH="$HOME_DIR/$PROJECT_NAME"

# Remove existing project if it exists
if [ -d "$PROJECT_PATH" ]; then
    rm -rf "$PROJECT_PATH"
fi

echo "Setting up project in: $PROJECT_PATH"

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

    # Install from here https://doc.rust-lang.org/rustc/instrument-coverage.html for profiling
    cargo install rustfilt --quiet || true
    
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

# Function: Configure project
configure_project() {
    echo "Configuring project..."
    
    # Create VS Code settings
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOL'
{
    "rust-analyzer.checkOnSave.command": "clippy",
    "coverage-gutters.lcovname": "lcov.info",
    "coverage-gutters.showLineCoverage": true,
    "coverage-gutters.showRulerCoverage": true,
    "editor.formatOnSave": true
}
EOL

    # Initialize git repository
    git init
    echo "target/" > .gitignore
    git add .
    git commit -m "Initial commit"
}

# Function: Configure VS Code settings
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

# Function: Run tests and generate coverage
run_tests_and_coverage() {
    echo "Running tests and generating coverage..."
    
    # Format code
    cargo fmt
    
    # Run tests with coverage
    cargo llvm-cov clean
    cargo llvm-cov --all-features --workspace --lcov --output-path lcov.info
    cargo llvm-cov html
    
    # Check coverage percentage
    local coverage=$(cargo llvm-cov --summarize | grep "line coverage" | awk '{print $4}')
    echo "Coverage: $coverage"
    
    if (( $(echo "$coverage < 100" | bc -l) )); then
        echo -e "${RED}Warning: Coverage below 100% ($coverage%)${NC}"
    else
        echo -e "${GREEN}Full coverage achieved!${NC}"
    fi
}
# Function to open reports in browser
open_reports() {
    echo "Opening reports in browser..."
    
    local COVERAGE_HTML="$PROJECT_PATH/target/llvm-cov/html/index.html"
    local PROFILING_HTML="$PROJECT_PATH/target/debug/profiling/html/index.html"
    
    if [ -f "$COVERAGE_HTML" ]; then
        xdg-open "$COVERAGE_HTML"
        echo -e "${GREEN}Coverage report opened${NC}"
    else
        echo -e "${RED}Coverage report not found${NC}"
    fi
    
    if [ -f "$PROFILING_HTML" ]; then
        xdg-open "$PROFILING_HTML"
        echo -e "${GREEN}Profiling report opened${NC}"
    else
        echo -e "${RED}Profiling report not found${NC}"
    fi
}

#
# Function: Generate profiling data
generate_profiling() {
    echo "Generating profiling data..."
    
    # Set profiling flags
    export RUSTFLAGS="-C instrument-coverage -C link-dead-code"
    
    # Clean and create profiling directory
    rm -rf target/debug/profiling
    mkdir -p target/debug/profiling
    
    # Run tests with profiling
    LLVM_PROFILE_FILE="target/debug/profiling/coverage-%p-%m.profraw" cargo test
    
    # Wait for file system
    sleep 2
    
    # Check for profile data
    if ! compgen -G "target/debug/profiling/*.profraw" > /dev/null; then
        echo -e "${RED}No profile data generated${NC}"
        return 1
    fi
    
    # Merge profile data
    llvm-profdata merge \
        -sparse target/debug/profiling/*.profraw \
        -o target/debug/profiling/merged.profdata || {
        echo -e "${RED}Failed to merge profile data${NC}"
        return 1
    }
    
    # Find the correct test binary
    TEST_BIN=$(find target/debug/deps \
        -type f -executable \
        -name "uppercase_converter-*" \
        ! -name "*.d" \
        -print0 | xargs -0 ls -t | head -n1)
    
    if [ ! -f "$TEST_BIN" ]; then
        echo -e "${RED}Test binary not found${NC}"
        return 1
    fi
    
    echo "Using test binary: $TEST_BIN"
    
    # Generate HTML report
    mkdir -p target/debug/profiling/html
    llvm-cov show \
        --use-color \
        --ignore-filename-regex='/.cargo/registry' \
        --format=html \
        --instr-profile=target/debug/profiling/merged.profdata \
        --object "$TEST_BIN" \
        --output-dir=target/debug/profiling/html \
        --show-instantiations \
        --show-line-counts-or-regions || {
        echo -e "${RED}Failed to generate HTML report${NC}"
        return 1
    }
    
    # Generate text report
    llvm-cov report \
        --use-color \
        --ignore-filename-regex='/.cargo/registry' \
        --instr-profile=target/debug/profiling/merged.profdata \
        --object "$TEST_BIN" \
        --show-branch-summary \
        > target/debug/profiling/coverage_report.txt || {
        echo -e "${RED}Failed to generate text report${NC}"
        return 1
    }
    
    echo -e "${GREEN}Profiling reports generated successfully${NC}"
}
#
# Function: Generate profiling data
tmp_generate_profiling() {
    echo "Generating profiling data..."
    
    # Set profiling flags
    #export RUSTFLAGS="-C instrument-coverage -C link-dead-code"
# Set profiling flags
    # export RUSTFLAGS="-C instrument-coverage -C link-dead-code"
    export CARGO_INCREMENTAL=0
    #old see here https://github.com/torrust/torrust-tracker/issues/1075
    # export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
    export RUSTFLAGS="-Cinstrument-coverage -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
    export RUSTDOCFLAGS="-Cpanic=abort"


    # Clean and create profiling directory
    rm -rf target/debug/profiling
    mkdir -p target/debug/profiling
    
    # Run tests with profiling
    LLVM_PROFILE_FILE="target/debug/profiling/coverage-%p-%m.profraw" cargo test
    
    # Wait for file system
    sleep 2
    
    # Check for profile data
    if ! compgen -G "target/debug/profiling/*.profraw" > /dev/null; then
        echo -e "${RED}No profile data generated${NC}"
        return 1
    fi
    
    # Merge profile data
    llvm-profdata merge \
        -sparse target/debug/profiling/*.profraw \
        -o target/debug/profiling/merged.profdata || {
        echo -e "${RED}Failed to merge profile data${NC}"
        return 1
    }
    
    # Find the correct test binary
    TEST_BIN=$(find target/debug/deps \
        -type f -executable \
        -name "uppercase_converter-*" \
        ! -name "*.d" \
        -print0 | xargs -0 ls -t | head -n1)
    
    if [ ! -f "$TEST_BIN" ]; then
        echo -e "${RED}Test binary not found${NC}"
        return 1
    fi
    
    echo "Using test binary: $TEST_BIN"
    
    # Generate HTML report
    mkdir -p target/debug/profiling/html
    llvm-cov show \
        --use-color \
        --ignore-filename-regex='/.cargo/registry' \
        --format=html \
        --instr-profile=target/debug/profiling/merged.profdata \
        --object "$TEST_BIN" \
        --output-dir=target/debug/profiling/html \
        --show-instantiations \
        --show-line-counts-or-regions || {
        echo -e "${RED}Failed to generate HTML report${NC}"
        return 1
    }
    
    # Generate text report
    llvm-cov report \
        --use-color \
        --ignore-filename-regex='/.cargo/registry' \
        --instr-profile=target/debug/profiling/merged.profdata \
        --object "$TEST_BIN" \
        --show-branch-summary \
        > target/debug/profiling/coverage_report.txt || {
        echo -e "${RED}Failed to generate text report${NC}"
        return 1
    }
    
    echo -e "${GREEN}Profiling reports generated successfully${NC}"
}
# Main execution
main() {
    echo "Starting project setup at $(date)"
    
    check_requirements || exit 1
    setup_project || exit 1
    create_source_files || exit 1
    configure_project || exit 1
    
    # Run tests and generate reports
    cargo fmt || true
    cargo clippy
    cargo test
    cargo llvm-cov --html --output-dir target/llvm-cov/html
    cargo llvm-cov --lcov --output-path target/llvm-cov/lcov.info
    generate_profiling || echo -e "${YELLOW}Profiling failed but continuing...${NC}"
    open_reports
    
    echo -e "${GREEN}Project setup complete!${NC}"
    echo "Project location: $PROJECT_PATH"
    echo "Coverage report: $PROJECT_PATH/target/llvm-cov/html/index.html"
    echo "Profiling report: $PROJECT_PATH/target/debug/profiling/html/index.html"
    echo "Log file: $LOG_FILE"
}

# Run main function with error handling
main || {
    echo -e "${RED}Script failed! Check the log file: $LOG_FILE${NC}"
    exit 1
}

:
}
```

>[!TIP]
>Shows the version of LLVM **used** by the Rust compiler
><!-- -->
>```bash
>rustc --verbose --version
>```
><!-- -->
<!-- -->
>[!TIP]
> LLVM version **local installed** shows the tool's LLVM version number
><!-- -->
> ```text
>llvm-cov --version
>```
<!-- -->
>[!NOTE]
>Installing LLVM coverage tools - If you are building the Rust compiler from source, you can optionally use the bundled LLVM tools [![alt text][1]](https://doc.rust-lang.org/rustc/instrument-coverage.html#installing-llvm-coverage-tools)
<!-- -->

>[!NOTE]
>Error: unknown unstable option: profile running coverage report workflow [![alt text][1]](https://github.com/torrust/torrust-tracker/issues/1075)
>
> First web match - The Rust flag profile was removed: [![alt text][1]](https://github.com/rust-lang/compiler-team/issues/798)
>
<!--    -->
>[!NOTe]
>Instrumentation-based Code Coverage [![alt text][1]](https://doc.rust-lang.org/rustc/instrument-coverage.html)

## for later

```txt
# https://users.rust-lang.org/t/panic-unwind-is-not-compiled-with-this-crates-panic-strategy-abort/97154
-C prefer-dynamic -C opt-level=3 -C panic=abort -C codegen-units=1
```

[profile.src]
-Zpanic-in-drop=abort

export CARGO_PROFILE_RELEASE_PANIC="abort"

## General Markdown Project hints and useful tips

### Use of sccache to improve the speed of Rust Build

- Install sccache

```bash
cargo install sccache
```

>[!TIP]
>List all installed Rust binary
><!-- -->
>```BASH
>cargo install --list
>```
><!-- -->
> DESCRIPTION - part of this, the full description is called like this => cargo help install\
>>This command manages Cargo’s local set of installed binary crates. Only packages which have executable [[bin]] or [[example]] targets can be installed, and all executables are installed into the
installation root’s bin folder. By default only binaries, not examples, are installed
<!-- -->
>[!TIP]
> **Markdown line break**\
> Try adding 2 spaces (or a backslash \) after the first line:
<!-- -->
>[!NOTE]
> **Info vs. Note**\
> Info often refers to factual data or knowledge obtained through study or instruction,\ while a note is a brief written record for later reference.
<!-- -->
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

## Markdown Marker - works on GitHub

> [!NOTE]
> Useful information that users should know, even when skimming content
<!-- -->
> [!TIP]
> Helpful advice for doing things better or more easily
<!-- -->
> [!IMPORTANT]
> Key information users need to know to achieve their goal
<!-- -->
> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems
<!-- -->
> [!CAUTION]
> Advises about risks or negative outcomes of certain actions
&rarr;

## Markdown arrow - works on GitHub

- Up arrow (↑): `&uarr;`
- Down arrow (↓): `&darr;`
- Left arrow (←): `&larr;`
- Right arrow (→): `&rarr;`
- Double headed arrow (↔): `&harr;`

## Another  good-looking notification or warning box in Github Flavoured Markdown?[![alt text][1]](https://stackoverflow.com/questions/58737436/how-to-create-a-good-looking-notification-or-warning-box-in-github-flavoured-mar)

| :memo:        | Take note of this       |
|---------------|:------------------------|

| :point_up:    | Remember to not forget! |
|---------------|:------------------------|

| :link:    | Link to click! |
|---------------|:------------------------|

| :warning: WARNING          |
|:---------------------------|
| I should warn you ...      |

| :boom: DANGER              |
|:---------------------------|
| Will explode when clicked! |

## Creative Commons BY-SA [![alt text][1]](https://creativecommons.org/share-your-work/cclicenses/) Icon ![Alt-Text](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

>[!NOTE]
>Link address
<!-- -->
>```text
>![Alt-Text](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)
>```
<!-- -->
<!--
<a href="mailto:example@webnots.com?cc=example1@webnots.com&bcc=example2@webnots.com&Subject= Thanks%20for%20tutorials" target="_blank">Contact Us</a>
-->
>[!TIP]
>How to Add Images in Markdown [![alt text][1]](https://hostman.com/tutorials/how-to-add-images-in-markdown/)
<!-- -->
>```txt
>![Alt-Text](URL of image)
>e.g.
>![Alt-Text](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)
>```
<!-- -->
<!-- -->
>[!TIP]
>How to Create HTML Email Links with Subject, CC and BCC? [![alt text][1]](https://www.webnots.com/html-email-links-tutorial/)
><!-- -->
>```html
><a href="mailto:example@webnots.com?cc=example1@webnots.com&bcc=example2@webnots.com&Subject= Thanks%20for%20tutorials" target="_blank">Contact Us</a>
>```
<!-- -->
<!-- 
FIXIT  remove is possible
<img style="vertical-align:middle" alt="Creative Commons BY-SA" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png">
-->

I never plan too far in advance. Carpe diem - Make the most of the day

```txt
check of env - which env / os / hardware > feedback file
time stop
testcase
code coverage
profiling
size of files
size of dev env
2. this article
https://doc.rust-lang.org/rustc/instrument-coverage.html#installing-llvm-coverage-tools
why prof files no merge, must prov files merge
3, Jenkins CI for rust project
4. What do the optimization levels `-Os` and `-Oz` do in rustc?
https://stackoverflow.com/questions/45608392/what-do-the-optimization-levels-os-and-oz-do-in-rustc
5. # https://users.rust-lang.org/t/panic-unwind-is-not-compiled-with-this-crates-panic-strategy-abort/97154
-C prefer-dynamic -C opt-level=3 -C panic=abort -C codegen-units=1
```

<!-- Link sign - Don't Found a better way :-( - You know a better method? - send me a email -->
[1]: ./img/link_symbol.svg
