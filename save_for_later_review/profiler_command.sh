#!/bin/bash

# Enable error handling and debugging
set -e
set -x

<<'###BLOCK-COMMENT'
/home/trapapa/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc - --crate-name ___  \
--print=file-names \
-Zprofile \
-Ccodegen-units=1 \ 
-Copt-level=0 \
-Clink-dead-code \ 
-Coverflow-checks=off \ 
-Zpanic_abort_tests  \
-Cpanic=abort \
--crate-type bin \ 
--crate-type rlib \
--crate-type dylib \
--crate-type cdylib \
--crate-type staticlib \ 
--crate-type proc-macro \
--print=sysroot \
--print=split-debuginfo \
--print=crate-name \
--print=cfg
###BLOCK-COMMENT

# FOUND HERE
# https://stackoverflow.com/questions/43158140/way-to-create-multiline-comments-in-bash

# change -Zprofile \ with  -Cinstrument-coverage

/home/trapapa/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustc - --crate-name ___  \
--print=file-names \
-Cinstrument-coverage \
-Ccodegen-units=1 \ 
-Copt-level=0 \
-Clink-dead-code \ 
-Coverflow-checks=off \ 
-Zpanic_abort_tests  \
-Cpanic=abort \
--crate-type bin \ 
--crate-type rlib \
--crate-type dylib \
--crate-type cdylib \
--crate-type staticlib \ 
--crate-type proc-macro \
--print=sysroot \
--print=split-debuginfo \
--print=crate-name \
--print=cfg 