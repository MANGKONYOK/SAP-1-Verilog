#!/bin/bash
# SAP-1 Control Unit Test Script

echo "=========================================="
echo "SAP-1 Control Unit Testing"
echo "=========================================="
echo ""

# Check if Icarus Verilog is installed
if ! command -v iverilog &> /dev/null; then
    echo "WARNING: Icarus Verilog (iverilog) is not installed."
    echo "Install it with: apt-get install iverilog (Linux) or brew install icarus-verilog (macOS)"
    echo ""
    echo "To run the CU tests manually, use these commands:"
    echo "1. Compile and run CU testbench:"
    echo "   iverilog -o cu_test main_modules/CU.v testbench/CU_tb.v"
    echo "   vvp cu_test"
    echo ""
    echo "2. Compile and run verification testbench:"
    echo "   iverilog -o cu_verify main_modules/CU.v testbench/CU_verification.v"
    echo "   vvp cu_verify"
    exit 0
fi

# Compile CU with comprehensive testbench
echo "Compiling CU with comprehensive testbench..."
iverilog -o cu_test main_modules/CU.v testbench/CU_tb.v 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
    echo ""
    echo "Running CU testbench..."
    echo "=========================================="
    vvp cu_test
    echo "=========================================="
else
    echo "✗ Compilation failed"
    exit 1
fi

echo ""
echo "Running verification testbench..."
iverilog -o cu_verify main_modules/CU.v testbench/CU_verification.v 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
    echo ""
    echo "=========================================="
    vvp cu_verify
    echo "=========================================="
else
    echo "✗ Compilation failed"
    exit 1
fi

echo ""
echo "Test completed!"
