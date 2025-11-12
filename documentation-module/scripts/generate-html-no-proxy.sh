#!/bin/bash
# Wrapper to run generate-html.sh without proxy settings

# Unset proxy environment variables temporarily
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy
unset ftp_proxy
unset FTP_PROXY

# Run the actual script
"$(dirname "$0")/generate-html.sh"
