# Proxy Server Monitoring Script

This script monitors various system resources for a proxy server and presents the data in a dashboard format. The script can be customized to display specific parts of the dashboard using command-line switches.

## Usage

Run the script with the following switches:

- `-cpu`: Display top 10 applications by CPU and memory usage.
- `-network`: Monitor network activity.
- `-disk`: Show disk usage.
- `-load`: Display system load and CPU usage breakdown.
- `-memory`: Show memory usage.
- `-process`: Monitor processes.
- `-services`: Check the status of essential services.
- `-all`: Display the full dashboard.

Example:

```bash
./monitor_proxy_server.sh -cpu
