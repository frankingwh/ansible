#!/bin/bash

# Copyright (C) 2018  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Version: 1.0

# Warning! Be sure to download the latest version of this script from its primary source:
# https://access.redhat.com/security/vulnerabilities/speculativeexecution
# DO NOT blindly trust any internet sources and NEVER do `curl something | bash`!

# This script is meant for simple detection of the vulnerability. Feel free to modify it for your
# environment or needs. For more advanced detection, consider Red Hat Insights:
# https://access.redhat.com/products/red-hat-insights#getstarted

# Checking against the list of vulnerable packages is necessary because of the way how features
# are back-ported to older versions of packages in various channels.


basic_args() {
    # Parses basic commandline arguments and sets basic environment.
    #
    # Args:
    #     parameters - an array of commandline arguments
    #
    # Side effects:
    #     Exits if --help parameters is used
    #     Sets COLOR constants and debug variable

    local parameters=( "$@" )

    RED="\033[1;31m"
    YELLOW="\033[1;33m"
    GREEN="\033[1;32m"
    BOLD="\033[1m"
    RESET="\033[0m"
    for parameter in "${parameters[@]}"; do
        if [[ "$parameter" == "-h" || "$parameter" == "--help" ]]; then
            echo "Usage: $( basename "$0" ) [-n | --no-colors] [-d | --debug]"
            exit 1
        elif [[ "$parameter" == "-n" || "$parameter" == "--no-colors" ]]; then
            RED=""
            YELLOW=""
            GREEN=""
            BOLD=""
            RESET=""
        elif [[ "$parameter" == "-d" || "$parameter" == "--debug" ]]; then
            debug=true
        fi
    done
}


basic_reqs() {
    # Prints common disclaimer and checks basic requirements.
    #
    # Args:
    #     CVE - string printed in the disclaimer
    #
    # Side effects:
    #     Exits when 'rpm' command is not available

    local CVE="$1"

    # Disclaimer
    echo
    echo -e "${BOLD}This script is primarily designed to detect $CVE on supported"
    echo -e "Red Hat Enterprise Linux systems and kernel packages."
    echo -e "Result may be inaccurate for other RPM based systems.${RESET}"
    echo

    # RPM is required
    if ! command -v rpm &> /dev/null; then
        echo "'rpm' command is required, but not installed. Exiting."
        exit 1
    fi
}


check_supported_kernel() {
    # Checks if running kernel is supported.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #
    # Side effects:
    #     Exits when running kernel is obviously not supported

    local running_kernel="$1"

    # Check supported platform
    if [[ "$running_kernel" != *".el"[5-7]* ]]; then
        echo -e "${RED}This script is meant to be used only on Red Hat Enterprise"
        echo -e "Linux 5, 6 and 7.${RESET}"
        exit 1
    fi
}


get_rhel() {
    # Gets RHEL number.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #
    # Prints:
    #     RHEL number, e.g. '5', '6', or '7'

    local running_kernel="$1"

    local rhel=$( sed -r -n 's/^.*el([[:digit:]]).*$/\1/p' <<< "$running_kernel" )
    echo "$rhel"
}


check_cpu_vendor() {
    # Checks for supported CPU vendor.
    #
    # Prints:
    #     'Intel' or 'AMD'
    #
    # Returns:
    #     0 if supported CPU vendor found, otherwise 1
    #
    # Notes:
    #     MOCK_CPU_INFO_PATH can be used to mock /proc/cpuinfo file

    local cpuinfo=${MOCK_CPU_INFO_PATH:-/proc/cpuinfo}

    if grep --quiet "GenuineIntel" "$cpuinfo"; then
        echo "Intel"
        return 0
    fi
    if grep --quiet "AuthenticAMD" "$cpuinfo"; then
        echo "AMD"
        return 0
    fi

    return 1
}


check_variants_runtime() {
    # Performs runtime check for mitigation.
    #
    # Args:
    #     vendor - vendor string
    #
    # Side effects:
    #     Overwrites global variables `variant_1`, `variant_2`, and `variant_3`.
    #
    # Returns:
    #     0 if check was successful, 1 if fallback detection is needed
    #
    # Notes:
    #     MOCK_DEBUG_X86_PATH can be used to mock /sys/kernel/debug/x86 file

    local debug_x86=${MOCK_DEBUG_X86_PATH:-/sys/kernel/debug/x86}
    local vendor="$1"

    if [[ "$vendor" == "AMD" ]]; then
        variant_3="AMD is not vulnerable to this variant"
    fi

    if [[ -r "$debug_x86" ]]; then
        echo "/sys/kernel/debug/x86 is mounted and accessible"
        echo
        if [[ -r "${debug_x86}/pti_enabled" && -r "${debug_x86}/ibpb_enabled" && -r "${debug_x86}/ibrs_enabled" ]]; then
            echo "The following files are accessible:"
            echo "/sys/kernel/debug/x86/pti_enabled, /sys/kernel/debug/x86/ibpb_enabled, /sys/kernel/debug/x86/ibrs_enabled"
            echo "Checking files..."
            echo
            pti_enabled=$( <"${debug_x86}/pti_enabled" )
            ibpb_enabled=$( <"${debug_x86}/ibpb_enabled" )
            ibrs_enabled=$( <"${debug_x86}/ibrs_enabled" )

            variant_1="Mitigated"

            if [[ "$vendor" == "Intel" ]]; then
                if (( pti_enabled == 1 && ibpb_enabled == 1 && ibrs_enabled == 1 )); then
                    variant_2="Mitigated"
                    variant_3="Mitigated"
                fi
                if (( pti_enabled == 1 && ibpb_enabled == 0 && ibrs_enabled == 0 )); then
                    variant_3="Mitigated"
                fi
            fi

            if [[ "$vendor" == "AMD" ]]; then
                if (( pti_enabled == 0 && ibpb_enabled == 0 && ibrs_enabled == 2 )); then
                    variant_2="Mitigated"
                fi
                if (( pti_enabled == 0 && ibpb_enabled == 2 && ibrs_enabled == 1 )); then
                    variant_2="Mitigated"
                fi
            fi

            return 0
        else
            echo "Some of the following files are not accessible:"
            echo "/sys/kernel/debug/x86/pti_enabled, /sys/kernel/debug/x86/ibpb_enabled, /sys/kernel/debug/x86/ibrs_enabled"
            echo
        fi
    else
        echo "/sys/kernel/debug/x86 is either not mounted or not accessible"
        echo "Run this script with elevated privileges (e.g. as root) or"
        echo "mount the debugfs by running:"
        echo "# mount -t debugfs nodev /sys/kernel/debug"
        echo
    fi
    return 1
}


fallback_check() {
    # Performs fallback (non-runtime) check for mitigation.
    #
    # Args:
    #     vendor - vendor string
    #
    # Side effects:
    #     Overwrites global variables `variant_1`, `variant_2`, and `variant_3`.
    #
    # Notes:
    #     MOCK_CMDLINE_PATH can be used to mock /proc/cmdline file

    cmdline_path=${MOCK_CMDLINE_PATH:-/proc/cmdline}
    local vendor="$1"

    echo -e "${YELLOW}Fallback (non-runtime heuristics) check${RESET}. Checking dmesg..."
    echo

    if ! dmesg | grep --quiet 'Linux.version'; then
        echo -e "${YELLOW}It seems that dmesg circular buffer already wrapped${RESET},"
        echo -e "${YELLOW}the results may be inaccurate.${RESET},"
        echo
    fi

    # Variant #3
    if [[ "$vendor" == "AMD" ]]; then
        variant_3="AMD is not vulnerable to this variant"
    fi

    if [[ "$vendor" == "Intel" ]]; then
        if dmesg | grep --quiet 'x86/pti: Unmapping kernel while in userspace'; then
            variant_1="Mitigated"
            if ! grep --quiet 'nopti' "$cmdline_path"; then
                variant_3="Mitigated"
            fi
        fi

        # Xen check
        if dmesg | grep --quiet 'x86/pti: Xen PV detected, disabling'; then
            variant_1="Mitigated"
            if ! grep --quiet 'nopti' "$cmdline_path"; then
                variant_3="Mitigated"
            fi
        fi
    fi

    # Variant #2
    ibrs=0
    ibpb=0
    local line

    line=$( dmesg | tac | grep --max-count 1 'FEATURE SPEC_CTRL' )  # Check last
    if [[ "$line" ]]; then
        variant_1="Mitigated"
        if ! grep --quiet 'Not Present' <<< "$line"; then
            if ! grep --quiet 'noibrs' "$cmdline_path"; then
                ibrs=1
            fi
        fi
    fi

    line=$( dmesg | tac | grep --max-count 1 'FEATURE IBPB_SUPPORT' )   # Check last
    if [[ "$line" ]]; then
        variant_1="Mitigated"
        if ! grep --quiet 'Not Present' <<< "$line"; then
            if ! grep --quiet 'noibpb' "$cmdline_path"; then
                ibpb=1
            fi
        fi
    fi

    if [[ "$vendor" == "Intel" ]]; then
        if (( ibpb == 1 && ibrs == 1 )); then
            variant_2="Mitigated"
        fi
    fi

    if [[ "$vendor" == "AMD" ]]; then
        if (( ibrs == 1 )); then
            variant_2="Mitigated"
        fi
    fi
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    basic_args "$@"
    basic_reqs "Spectre / Meltdown"
    running_kernel=$( uname -r )
    check_supported_kernel "$running_kernel"

    rhel=$( get_rhel "$running_kernel" )
    if [[ "$rhel" == "5" ]]; then
        export PATH='/sbin':$PATH
    fi

    variant_1="Vulnerable"
    variant_2="Vulnerable"
    variant_3="Vulnerable"

    # Tests
    vendor=$( check_cpu_vendor )
    if (( $? == 1 )); then
        echo -e "${RED}Your CPU vendor is not supported by the script at the moment.${RESET}"
        echo -e "Only Intel and AMD are supported for now."
        exit 1
    fi
    check_variants_runtime "$vendor"
    if (( $? == 1 )); then
        fallback_check "$vendor"
    fi

    # Debug prints
    if [[ "$debug" ]]; then
        echo "vendor = *$vendor*"
        echo "pti_enabled = *$pti_enabled*"
        echo "ibpb_enabled = *$ibpb_enabled*"
        echo "ibrs_enabled = *$ibrs_enabled*"
        echo "ibrs (fallback) = *$ibrs*"
        echo "ibpb (fallback) = *$ibpb*"
        echo "variant_1 = *$variant_1*"
        echo "variant_2 = *$variant_2*"
        echo "variant_3 = *$variant_3*"
        echo
    fi

    # Results
    (( result = 0 ))
    if [[ "$variant_1" == "Vulnerable" ]]; then
        (( result |= 2 ))
        variant_1="${RED}$variant_1${RESET}"
    else
        variant_1="${GREEN}$variant_1${RESET}"
    fi
    if [[ "$variant_2" == "Vulnerable" ]]; then
        (( result |= 4 ))
        variant_2="${RED}$variant_2${RESET}"
    else
        variant_2="${GREEN}$variant_2${RESET}"
    fi
    if [[ "$variant_3" == "Vulnerable" ]]; then
        (( result |= 8 ))
        variant_3="${RED}$variant_3${RESET}"
    else
        variant_3="${GREEN}$variant_3${RESET}"
    fi

    echo -e "Detected CPU vendor is: ${BOLD}$vendor${RESET}"
    echo
    echo -e "Variant #1 (Spectre): $variant_1"
    echo -e "Variant #2 (Spectre): $variant_2"
    echo -e "Variant #3 (Meltdown): $variant_3"
    echo
    echo -e "For more information see:"
    echo -e "https://access.redhat.com/security/vulnerabilities/speculativeexecution"
    exit "$result"
fi
