# Linux Server Security Audit and Hardening Script

This script automates the security audit and hardening process for Linux servers. It includes checks for common security vulnerabilities, IPv4/IPv6 configurations, and the implementation of hardening measures.

## Usage

Run the script with one of the following options:

- `-audit`: Perform a security audit and generate a report.
- `-harden`: Apply hardening measures to the server.
- `-all`: Perform both the security audit and hardening.

### Examples:

```bash
./security_audit_hardening.sh -audit
./security_audit_hardening.sh -harden
./security_audit_hardening.sh -all
