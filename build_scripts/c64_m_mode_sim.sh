#!/bin/bash
# =====================================================================
# c64_m_mode_sim.sh - Configure and build a MACHINE-ONLY (M-mode) 64-bit SoC
# =====================================================================

set -e
set -o pipefail
set -u

# ------------------------------
# Fixed bus width
# ------------------------------
BUS_WIDTH=64

# ------------------------------
# Setup paths
# ------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

echo "=== Building SoC with BUS_WIDTH = $BUS_WIDTH ==="
echo "Project root: $ROOT_DIR"

# ------------------------------
# Python environment setup
# ------------------------------
echo "=== Upgrading pip ==="
pip install --upgrade pip

echo "=== Uninstalling existing Python packages ==="
if [ -f requirements.txt ]; then
    pip uninstall -r requirements.txt -y || true
fi
pip uninstall soc_config -y || true

echo "=== Installing dependencies ==="
pip install -r requirements.txt

# ------------------------------
# Repo management
# ------------------------------
echo "=== Cleaning and updating dependencies ==="
soc_config --deps "$ROOT_DIR/test_soc/c64_c32/c64_deps.yaml"

# ------------------------------
# Machine-only (M-mode) configuration
# ------------------------------
# Apply su_removal_c64.patch to strip all Supervisor/User-mode CSRs from the
# c64 sample config so soc_config generates a machine-mode-only core. The patch
# edits three files under sample_config/c64:
#   - csr_grouping64.yaml : drops S/U CSRs (SSTATUS, SATP, S* interrupts, etc.)
#   - rv64i_debug.yaml    : removes S/U-specific dcsr WARL fields (prv, ebreaks/u)
#   - rv64i_isa.yaml      : ISA RV64IMAFDCSU... -> RV64IMAFDC..., disables S/U CSRs
PATCH_FILE="$SCRIPT_DIR/su_removal_c64.patch"
echo "=== Applying machine-only (S/U removal) patch ==="
if git apply --reverse --check "$PATCH_FILE" 2>/dev/null; then
    echo "Patch already applied; skipping"
else
    git apply "$PATCH_FILE"
    echo "Patch applied"
fi

# ------------------------------
# Configuration update
# ------------------------------
echo "=== Updating bus width in core configuration ==="
yq -i ".bus_protocol_configuration.bus_width = ${BUS_WIDTH}" \
    "$ROOT_DIR/sample_config/c64/core64.yaml"

# ------------------------------
# SoC configuration
# ------------------------------
echo "=== Running soc_config ==="
soc_config \
  -ispec "$ROOT_DIR/sample_config/c64/rv64i_isa.yaml" \
  -customspec "$ROOT_DIR/sample_config/c64/rv64i_custom.yaml" \
  -cspec "$ROOT_DIR/sample_config/c64/core64.yaml" \
  -gspec "$ROOT_DIR/sample_config/c64/csr_grouping64.yaml" \
  -dspec "$ROOT_DIR/sample_config/c64/rv64i_debug.yaml" \
  --verbose info

# ------------------------------
# Verilog generation and linking
# ------------------------------
echo "=== Generating Verilog and boot files ==="
make -j$(nproc) generate_verilog
make link_verilator generate_boot_files

echo "=== Build completed successfully with BUS_WIDTH = $BUS_WIDTH ==="

# ------------------------------
# Run tests
# ------------------------------
echo "=== Running tests ==="
make test opts='--test=add --suite=rv64ui --debug' \
    CONFIG_ISA=RV64IMAFDCZicsr_zifencei
