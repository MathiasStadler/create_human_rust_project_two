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
    # export RUSTFLAGS="-C instrument-coverage -C link-dead-code"
	export CARGO_INCREMENTAL=0
    	export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
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
#
# Function: Generate profiling data
tmp_generate_profiling() {
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


}
