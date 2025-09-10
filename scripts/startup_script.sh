#!/bin/sh

# Immediately bail out if any command fails:
set -e

CONF_FILE="/home/suwayomi/.local/share/Tachidesk/server.conf"
DATA_DIR="/home/suwayomi/.local/share/Tachidesk"
BIN_DIR="$DATA_DIR/bin"
CACHE_DIR="$DATA_DIR/cache/kcef"

echo "Suwayomi data location inside the container: $DATA_DIR"

# make sure the server.conf file exists
/home/suwayomi/create_server_conf.sh

# Function escapes values ​​to be safe with sed
escape_sed() {
    echo "$1" | sed 's/[&/|\\]/\\&/g'
}

# Function update and setup bool/number
update_conf() {
    key="$1"
    value="$2"
    file="$3"
    safe_value=$(escape_sed "$value")
    sed -i -r "s|^(${key} = ).*|\1${safe_value} #|" "$file"
}

# Function update and setup string (add "")
update_conf_str() {
    key="$1"
    value="$2"
    file="$3"
    safe_value=$(escape_sed "$value")
    sed -i -r "s|^(${key} = ).*|\1\"${safe_value}\" #|" "$file"
}

# Set default values for settings
update_conf "server.initialOpenInBrowserEnabled" "false" "$CONF_FILE"
update_conf "server.systemTrayEnabled" "false" "$CONF_FILE"

# set default values for environment variables:
[ -z "$TZ" ] && TZ="Etc/UTC"
export TZ

# !!! IMPORTANT: make sure to add new env variables to the container.yml workflow step testing the container with providing environment variables

# List key|env_var|type
SETTINGS="
# ==== Server ====
server.initialOpenInBrowserEnabled|INITIAL_OPEN_BROWSER|bool
server.systemTrayEnabled|SYSTEM_TRAY_ENABLED|bool
server.ip|BIND_IP|string
server.port|BIND_PORT|bool

# ==== Proxy ====
server.socksProxyEnabled|SOCKS_PROXY_ENABLED|bool
server.socksProxyVersion|SOCKS_PROXY_VERSION|bool
server.socksProxyHost|SOCKS_PROXY_HOST|string
server.socksProxyPort|SOCKS_PROXY_PORT|string
server.socksProxyUsername|SOCKS_PROXY_USERNAME|string
server.socksProxyPassword|SOCKS_PROXY_PASSWORD|string

# ==== WebUI ====
server.webUIEnabled|WEB_UI_ENABLED|bool
server.webUIFlavor|WEB_UI_FLAVOR|bool
server.webUIChannel|WEB_UI_CHANNEL|bool
server.webUIUpdateCheckInterval|WEB_UI_UPDATE_INTERVAL|bool

# ==== Downloader ====
server.downloadAsCbz|DOWNLOAD_AS_CBZ|bool
server.autoDownloadNewChapters|AUTO_DOWNLOAD_CHAPTERS|bool
server.excludeEntryWithUnreadChapters|AUTO_DOWNLOAD_EXCLUDE_UNREAD|bool
server.autoDownloadNewChaptersLimit|AUTO_DOWNLOAD_NEW_CHAPTERS_LIMIT|bool
server.autoDownloadIgnoreReUploads|AUTO_DOWNLOAD_IGNORE_REUPLOADS|bool

# ==== Requests ====
server.maxSourcesInParallel|MAX_SOURCES_IN_PARALLEL|bool

# ==== Updater ====
server.excludeUnreadChapters|UPDATE_EXCLUDE_UNREAD|bool
server.excludeNotStarted|UPDATE_EXCLUDE_STARTED|bool
server.excludeCompleted|UPDATE_EXCLUDE_COMPLETED|bool
server.globalUpdateInterval|UPDATE_INTERVAL|bool
server.updateMangas|UPDATE_MANGA_INFO|bool

# ==== Authentication ====
server.authMode|AUTH_MODE|bool
server.authUsername|AUTH_USERNAME|string
server.authPassword|AUTH_PASSWORD|string
server.jwtAudience|JWT_AUDIENCE|string
server.jwtTokenExpiry|JWT_TOKEN_EXPIRY|string
server.jwtRefreshExpiry|JWT_REFRESH_EXPIRY|string
server.basicAuthEnabled|BASIC_AUTH_ENABLED|bool
server.basicAuthUsername|BASIC_AUTH_USERNAME|string
server.basicAuthPassword|BASIC_AUTH_PASSWORD|string

# ==== Misc ====
server.debugLogsEnabled|DEBUG|bool
server.maxLogFiles|MAX_LOG_FILES|bool
server.maxLogFileSize|MAX_LOG_FILE_SIZE|string
server.maxLogFolderSize|MAX_LOG_FOLDER_SIZE|string

# ==== Backup ====
server.backupTime|BACKUP_TIME|string
server.backupInterval|BACKUP_INTERVAL|bool
server.backupTTL|BACKUP_TTL|bool

# ==== Cloudflare bypass ====
server.flareSolverrEnabled|FLARESOLVERR_ENABLED|bool
server.flareSolverrUrl|FLARESOLVERR_URL|string
server.flareSolverrTimeout|FLARESOLVERR_TIMEOUT|bool
server.flareSolverrSessionName|FLARESOLVERR_SESSION_NAME|string
server.flareSolverrSessionTtl|FLARESOLVERR_SESSION_TTL|bool
server.flareSolverrAsResponseFallback|FLARESOLVERR_RESPONSE_AS_FALLBACK|bool

# ==== OPDS ====
server.opdsUseBinaryFileSizes|OPDS_USE_BINARY_FILE_SIZES|bool
server.opdsItemsPerPage|OPDS_ITEMS_PER_PAGE|bool
server.opdsEnablePageReadProgress|OPDS_ENABLE_PAGE_READ_PROGRESS|bool
server.opdsMarkAsReadOnDownload|OPDS_MARK_AS_READ_ON_DOWNLOAD|bool
server.opdsShowOnlyUnreadChapters|OPDS_SHOW_ONLY_UNREAD_CHAPTERS|bool
server.opdsShowOnlyDownloadedChapters|OPDS_SHOW_ONLY_DOWNLOADED_CHAPTERS|bool
server.opdsChapterSortOrder|OPDS_CHAPTER_SORT_ORDER|bool

# ==== Koreader ====
server.koreaderSyncServerUrl|KOREADER_SYNC_SERVER_URL|string
server.koreaderSyncUsername|KOREADER_SYNC_USERNAME|string
server.koreaderSyncUserkey|KOREADER_SYNC_USERKEY|string
server.koreaderSyncDeviceId|KOREADER_SYNC_DEVICE_ID|string
server.koreaderSyncChecksumMethod|KOREADER_SYNC_CHECKSUM_METHOD|bool
server.koreaderSyncPercentageTolerance|KOREADER_SYNC_PERCENTAGE_TOLERANCE|bool
server.koreaderSyncStrategyForward|KOREADER_SYNC_STRATEGY_FORWARD|string
server.koreaderSyncStrategyBackward|KOREADER_SYNC_STRATEGY_BACKWARD|string

# ==== Database ====
server.databaseType|DATABASE_TYPE|bool
server.databaseUrl|DATABASE_URL|string
server.databaseUsername|DATABASE_USERNAME|string
server.databasePassword|DATABASE_PASSWORD|string
"

# Apply updates to server.conf from environment variables
while IFS="|" read -r key env_var type; do
    # Skip comment and blank lines
    case "$key" in
        ""|\#*) continue ;;
    esac
    # Get environment variable value
    eval "val=\${$env_var}"
    [ -n "$val" ] || continue
    # Get Function by type
    if [ "$type" = "string" ]; then
        update_conf_str "$key" "$val" "$CONF_FILE"
    else
        update_conf "$key" "$val" "$CONF_FILE"
    fi
done <<EOF
$SETTINGS
EOF

# Special handling for DOWNLOAD_CONVERSIONS
if [ -n "$DOWNLOAD_CONVERSIONS" ]; then
    perl -0777 -i -pe 's/server\.downloadConversions = ({[^#]*})/server.downloadConversions = $ENV{DOWNLOAD_CONVERSIONS}/gs' "$CONF_FILE"
fi

# Special handling for EXTENSION_REPOS
if [ -n "$EXTENSION_REPOS" ]; then
    perl -0777 -i -pe 's/server\.extensionRepos = (\[.*\])/server.extensionRepos = $ENV{EXTENSION_REPOS}/gs' "$CONF_FILE"
fi

# Clean cache KCEF
[ -d "$CACHE_DIR" ] && rm -rf "$CACHE_DIR"/Singleton*

# KCEF + Xvfb
if command -v Xvfb >/dev/null 2>&1; then
    command="xvfb-run --auto-servernum java"
    if [ -d /opt/kcef/jcef ]; then
        mkdir -p "$BIN_DIR"
        [ ! -e "$BIN_DIR/kcef" ] && ln -s /opt/kcef/jcef "$BIN_DIR/kcef"
    fi
    [ -d "$BIN_DIR/kcef" ] && chmod -R a+x "$BIN_DIR/kcef" 2>/dev/null || true
    export LD_PRELOAD="$BIN_DIR/kcef/libcef.so"
else
    command="java"
    echo "Suwayomi built without KCEF support, not starting Xvfb"
fi

# Add catch_abort if present
[ -f /opt/catch_abort.so ] && export LD_PRELOAD="/opt/catch_abort.so $LD_PRELOAD"

echo "LD_PRELOAD=$LD_PRELOAD"
exec $command -Duser.home=/home/suwayomi -jar "/home/suwayomi/startup/tachidesk_latest.jar";
