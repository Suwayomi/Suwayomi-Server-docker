#!/bin/sh

# Immediately bail out if any command fails:
set -e

echo "Suwayomi data location inside the container: /home/suwayomi/.local/share/Tachidesk"

# make sure the server.conf file exists
/home/suwayomi/create_server_conf.sh

# set default values for environment variables:
export TZ="${TZ:-Etc/UTC}"

# Set default values for settings
sed -i -r "s/server.initialOpenInBrowserEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.initialOpenInBrowserEnabled = false #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.systemTrayEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.systemTrayEnabled = false #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# !!! IMPORTANT: make sure to add new env variables to the container.yml workflow step testing the container with providing environment variables

# Overwrite configuration values with environment variables
# the "( #)?" at the end of the regex prevents the settings comment from getting removed
# some settings might not have a comment, however, "sed" does not support non matching groups in a regex, thus, an empty
# comment will just be created for these settings

# Server ip and port bindings
sed -i -r "s/server.ip = \"(.*?)\"( #)?/server.ip = \"${BIND_IP:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.port = ([0-9]+|[a-zA-Z]+)( #)?/server.port = ${BIND_PORT:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# Socks5 proxy
sed -i -r "s/server.socksProxyEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.socksProxyEnabled = ${SOCKS_PROXY_ENABLED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.socksProxyHost = \"(.*?)\"( #)?/server.socksProxyHost = \"${SOCKS_PROXY_HOST:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.socksProxyPort = \"(.*?)\"( #)?/server.socksProxyPort = \"${SOCKS_PROXY_PORT:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# webUI
sed -i -r "s/server.webUIEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.webUIEnabled = ${WEB_UI_ENABLED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.webUIFlavor = \"(.*?)\"( #)?/server.webUIFlavor = \"${WEB_UI_FLAVOR:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.webUIChannel = \"(.*?)\"( #)?/server.webUIChannel = \"${WEB_UI_CHANNEL:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.webUIUpdateCheckInterval = ([0-9]+|[a-zA-Z]+)( #)?/server.webUIUpdateCheckInterval = ${WEB_UI_UPDATE_INTERVAL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# downloader
sed -i -r "s/server.downloadAsCbz = ([0-9]+|[a-zA-Z]+)( #)?/server.downloadAsCbz = ${DOWNLOAD_AS_CBZ:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.autoDownloadNewChapters = ([0-9]+|[a-zA-Z]+)( #)?/server.autoDownloadNewChapters = ${AUTO_DOWNLOAD_CHAPTERS:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.excludeEntryWithUnreadChapters = ([0-9]+|[a-zA-Z]+)( #)?/server.excludeEntryWithUnreadChapters = ${AUTO_DOWNLOAD_EXCLUDE_UNREAD:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.autoDownloadNewChaptersLimit = ([0-9]+|[a-zA-Z]+)( #)?/server.autoDownloadNewChaptersLimit = ${AUTO_DOWNLOAD_NEW_CHAPTERS_LIMIT:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.autoDownloadIgnoreReUploads = ([0-9]+|[a-zA-Z]+)( #)?/server.autoDownloadIgnoreReUploads = ${AUTO_DOWNLOAD_IGNORE_REUPLOADS:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# extension repos
if [ -n "$EXTENSION_REPOS" ]; then
    perl -0777 -i -pe 's/server\.extensionRepos = (\[.*\])/server.extensionRepos = $ENV{EXTENSION_REPOS}/gs' /home/suwayomi/.local/share/Tachidesk/server.conf
fi

# requests
sed -i -r "s/server.maxSourcesInParallel = ([0-9]+|[a-zA-Z]+)( #)?/server.maxSourcesInParallel = ${MAX_SOURCES_IN_PARALLEL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# updater
sed -i -r "s/server.excludeUnreadChapters = ([0-9]+|[a-zA-Z]+)( #)?/server.excludeUnreadChapters = ${UPDATE_EXCLUDE_UNREAD:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.excludeNotStarted = ([0-9]+|[a-zA-Z]+)( #)?/server.excludeNotStarted = ${UPDATE_EXCLUDE_STARTED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.excludeCompleted = ([0-9]+|[a-zA-Z]+)( #)?/server.excludeCompleted = ${UPDATE_EXCLUDE_COMPLETED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.globalUpdateInterval = ([0-9]+|[a-zA-Z]+)( #)?/server.globalUpdateInterval = ${UPDATE_INTERVAL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.updateMangas = ([0-9]+|[a-zA-Z]+)( #)?/server.updateMangas = ${UPDATE_MANGA_INFO:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# Authentication
sed -i -r "s/server.basicAuthEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.basicAuthEnabled = ${BASIC_AUTH_ENABLED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.basicAuthUsername = \"(.*?)\"( #)?/server.basicAuthUsername = \"${BASIC_AUTH_USERNAME:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.basicAuthPassword = \"(.*?)\"( #)?/server.basicAuthPassword = \"${BASIC_AUTH_PASSWORD:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# misc
sed -i -r "s/server.debugLogsEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.debugLogsEnabled = ${DEBUG:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# backup
sed -i -r "s/server.backupTime = \"(.*?)\"( #)?/server.backupTime = \"${BACKUP_TIME:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.backupInterval = ([0-9]+|[a-zA-Z]+)( #)?/server.backupInterval = ${BACKUP_INTERVAL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.backupTTL = ([0-9]+|[a-zA-Z]+)( #)?/server.backupTTL = ${BACKUP_TTL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf


# cloudflare bypass
sed -i -r "s/server.flareSolverrEnabled = ([0-9]+|[a-zA-Z]+)( #)?/server.flareSolverrEnabled = ${FLARESOLVERR_ENABLED:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s|server.flareSolverrUrl = \"(.*?)\"( #)?|server.flareSolverrUrl = \"${FLARESOLVERR_URL:-\1}\" #|" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.flareSolverrTimeout = ([0-9]+|[a-zA-Z]+)( #)?/server.flareSolverrTimeout = ${FLARESOLVERR_TIMEOUT:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.flareSolverrSessionName = \"(.*?)\"( #)?/server.flareSolverrSessionName = \"${FLARESOLVERR_SESSION_NAME:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.flareSolverrSessionTtl = ([0-9]+|[a-zA-Z]+)( #)?/server.flareSolverrSessionTtl = ${FLARESOLVERR_SESSION_TTL:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf

# opds
sed -i -r "s/server.opdsUseBinaryFileSizes = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsUseBinaryFileSizes = ${OPDS_USE_BINARY_FILE_SIZES:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsItemsPerPage = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsItemsPerPage = ${OPDS_ITEMS_PER_PAGE:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsEnablePageReadProgress = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsEnablePageReadProgress = ${OPDS_ENABLE_PAGE_READ_PROGRESS:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsMarkAsReadOnDownload = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsMarkAsReadOnDownload = ${OPDS_MARK_AS_READ_ON_DOWNLOAD:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsShowOnlyUnreadChapters = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsShowOnlyUnreadChapters = ${OPDS_SHOW_ONLY_UNREAD_CHAPTERS:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsShowOnlyDownloadedChapters = ([0-9]+|[a-zA-Z]+)( #)?/server.opdsShowOnlyDownloadedChapters = ${OPDS_SHOW_ONLY_DOWNLOADED_CHAPTERS:-\1} #/" /home/suwayomi/.local/share/Tachidesk/server.conf
sed -i -r "s/server.opdsChapterSortOrder = \"(.*?)\"( #)?/server.opdsChapterSortOrder = \"${OPDS_CHAPTER_SORT_ORDER:-\1}\" #/" /home/suwayomi/.local/share/Tachidesk/server.conf

if command -v Xvfb >/dev/null; then
  Xvfb :0 -screen 0 800x680x24 -nolisten tcp >/dev/null 2>&1 &
  export DISPLAY=:0
else
  echo "Suwayomi built without KCEF support, not starting Xvfb"
fi
exec java -Duser.home=/home/suwayomi -jar "/home/suwayomi/startup/tachidesk_latest.jar";
