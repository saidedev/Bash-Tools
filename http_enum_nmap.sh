#!/bin/bash

# Colors
script_name='\033[38;2;255;64;0m'
yellow='\033[1;33m'  # Yellow for findings
blue='\033[38;2;0;110;255m'  # RSB(0, 110, 255) for script names
reset='\033[0m'  # Reset color

# Note about http-slowloris-check.nse
echo -e "${yellow}I didn't include ${script_name}http-slowloris-check.nse ${reset}"
echo -e "${yellow}Because it takes too much time to check ${reset}"
# Ask for the target domain name or IPv4
echo -n "Enter the target domain name or IPv4 (without http:// or https://): "
read target

# Verify the input is not empty
if [[ -z "$target" ]]; then
    echo "Target cannot be empty. Please run the script again and provide a valid target."
    exit 1
fi

# Output file
output_file="http-enum.txt"

# Clear the output file if it already exists
echo "Nmap HTTP Enumeration Results" > "$output_file"

# List of HTTP-related scripts
http_scripts=(
    "http-adobe-coldfusion-apsa1301.nse"
    "http-affiliate-id.nse"
    "http-apache-negotiation.nse"
    "http-apache-server-status.nse"
    "http-aspnet-debug.nse"
    "http-auth-finder.nse"
    "http-auth.nse"
    "http-avaya-ipoffice-users.nse"
    "http-awstatstotals-exec.nse"
    "http-axis2-dir-traversal.nse"
    "http-backup-finder.nse"
    "http-barracuda-dir-traversal.nse"
    "http-bigip-cookie.nse"
    "http-brute.nse"
    "http-cakephp-version.nse"
    "http-chrono.nse"
    "http-cisco-anyconnect.nse"
    "http-coldfusion-subzero.nse"
    "http-comments-displayer.nse"
    "http-config-backup.nse"
    "http-cookie-flags.nse"
    "http-cors.nse"
    "http-cross-domain-policy.nse"
    "http-csrf.nse"
    "http-date.nse"
    "http-default-accounts.nse"
    "http-devframework.nse"
    "http-dlink-backdoor.nse"
    "http-dombased-xss.nse"
    "http-domino-enum-passwords.nse"
    "http-drupal-enum.nse"
    "http-drupal-enum-users.nse"
    "http-enum.nse"
    "http-errors.nse"
    "http-exif-spider.nse"
    "http-favicon.nse"
    "http-feed.nse"
    "http-fetch.nse"
    "http-fileupload-exploiter.nse"
    "http-form-brute.nse"
    "http-form-fuzzer.nse"
    "http-frontpage-login.nse"
    "http-generator.nse"
    "http-git.nse"
    "http-gitweb-projects-enum.nse"
    "http-google-malware.nse"
    "http-grep.nse"
    "http-headers.nse"
    "http-hp-ilo-info.nse"
    "http-huawei-hg5xx-vuln.nse"
    "http-icloud-findmyiphone.nse"
    "http-icloud-sendmsg.nse"
    "http-iis-short-name-brute.nse"
    "http-iis-webdav-vuln.nse"
    "http-internal-ip-disclosure.nse"
    "http-joomla-brute.nse"
    "http-jsonp-detection.nse"
    "http-litespeed-sourcecode-download.nse"
    "http-ls.nse"
    "http-majordomo2-dir-traversal.nse"
    "http-malware-host.nse"
    "http-mcmp.nse"
    "http-methods.nse"
    "http-method-tamper.nse"
    "http-mobileversion-checker.nse"
    "http-ntlm-info.nse"
    "http-open-proxy.nse"
    "http-open-redirect.nse"
    "http-passwd.nse"
    "http-phpmyadmin-dir-traversal.nse"
    "http-phpself-xss.nse"
    "http-php-version.nse"
    "http-proxy-brute.nse"
    "http-put.nse"
    "http-qnap-nas-info.nse"
    "http-referer-checker.nse"
    "http-rfi-spider.nse"
    "http-robots.txt.nse"
    "http-robtex-reverse-ip.nse"
    "http-robtex-shared-ns.nse"
    "http-sap-netweaver-leak.nse"
    "http-security-headers.nse"
    "http-server-header.nse"
    "http-shellshock.nse"
    "http-sitemap-generator.nse"
    "http-sql-injection.nse"
    "https-redirect.nse"
    "http-stored-xss.nse"
    "http-svn-enum.nse"
    "http-svn-info.nse"
    "http-title.nse"
    "http-tplink-dir-traversal.nse"
    "http-trace.nse"
    "http-traceroute.nse"
    "http-trane-info.nse"
    "http-unsafe-output-escaping.nse"
    "http-useragent-tester.nse"
    "http-userdir-enum.nse"
    "http-vhosts.nse"
    "http-virustotal.nse"
    "http-vlcstreamer-ls.nse"
    "http-vmware-path-vuln.nse"
    "http-vuln-cve2006-3392.nse"
    "http-vuln-cve2009-3960.nse"
    "http-vuln-cve2010-0738.nse"
    "http-vuln-cve2010-2861.nse"
    "http-vuln-cve2011-3192.nse"
    "http-vuln-cve2011-3368.nse"
    "http-vuln-cve2012-1823.nse"
    "http-vuln-cve2013-0156.nse"
    "http-vuln-cve2013-6786.nse"
    "http-vuln-cve2013-7091.nse"
    "http-vuln-cve2014-2126.nse"
    "http-vuln-cve2014-2127.nse"
    "http-vuln-cve2014-2128.nse"
    "http-vuln-cve2014-2129.nse"
    "http-vuln-cve2014-3704.nse"
    "http-vuln-cve2014-8877.nse"
    "http-vuln-cve2015-1427.nse"
    "http-vuln-cve2015-1635.nse"
    "http-vuln-cve2017-1001000.nse"
    "http-vuln-cve2017-5638.nse"
    "http-vuln-cve2017-5689.nse"
    "http-vuln-cve2017-8917.nse"
    "http-vuln-misfortune-cookie.nse"
    "http-vuln-wnr1000-creds.nse"
    "http-waf-detect.nse"
    "http-waf-fingerprint.nse"
    "http-webdav-scan.nse"
    "http-wordpress-brute.nse"
    "http-wordpress-enum.nse"
    "http-wordpress-users.nse"
    "http-xssed.nse"
    "ip-https-discover.nse"
    "membase-http-info.nse"
    "riak-http-info.nse"
)


# Loop through each script and run nmap
for script in "${http_scripts[@]}"; do
    # Print the script name in the desired color
    echo -e "${blue}Running nmap with script: ${script_name}$script${reset}"
    echo -e "${blue}Running nmap with script: ${script_name}$script${reset}" >> "$output_file"

    # Run the nmap command and color the findings in yellow
    nmap -p 80,443 --script "$script" "$target" | tee -a "$output_file" | awk \
    '{ if ($0 ~ /HTTP/ || $0 ~ /Result/ || $0 ~ /Found/) { print "\033[1;33m" $0 "\033[0m" } else { print $0 } }'

    # Add a separator line
    echo "-------------------------------------" | tee -a "$output_file"
    echo -e "Sleeping for 1s..."
    sleep 1s
done

# Completion message
echo "Scanning complete. Results saved in $output_file"
