#!/bin/sh

# The container starts as root so that the suwayomi user can be remapped to the
# UID/GID requested via the PUID/PGID environment variables (following the
# pattern established by the LinuxServer.io images). After remapping and fixing
# the ownership of the data directory, privileges are dropped and the actual
# command runs as the suwayomi user.

set -e

# When the container is started with an explicit user (eg "docker run --user"
# or "user:" in a compose file) there are no root privileges to remap with,
# so behave exactly like before PUID/PGID support existed and just run the
# command as that user.
if [ "$(id -u)" -ne 0 ]; then
    if [ -n "$PUID" ] || [ -n "$PGID" ]; then
        echo "WARNING: ignoring PUID/PGID because the container user was overridden (--user), which prevents remapping" >&2
    fi
    exec "$@"
fi

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

case "${PUID}${PGID}" in
    *[!0-9]*)
        echo "ERROR: PUID and PGID must be non-negative integers, got PUID='${PUID}' PGID='${PGID}'" >&2
        exit 1
        ;;
esac

# groupmod also updates the primary group of the suwayomi user in /etc/passwd,
# usermod also updates the owner of files inside /home/suwayomi that are owned
# by the old UID. When PUID/PGID match the current IDs (the default), nothing
# is modified, which keeps eg read-only containers working.
if [ "$PGID" -ne "$(id -g suwayomi)" ]; then
    groupmod -o -g "$PGID" suwayomi
fi
if [ "$PUID" -ne "$(id -u suwayomi)" ]; then
    usermod -o -u "$PUID" suwayomi
fi

echo "Starting Suwayomi as UID:GID $(id -u suwayomi):$(id -g suwayomi)"

# Hand anything left that is not owned by the (possibly remapped) user over to
# it, most importantly the mounted data directory. Only files with a wrong
# owner are touched so that startups with big libraries stay fast. A failed
# chown (eg rootless podman with the ID not mapped) is only a warning, since
# the server may still have access through the file mode bits.
find /home/suwayomi \( ! -user suwayomi -o ! -group suwayomi \) -print0 \
    | xargs -0 -r chown -h suwayomi:suwayomi \
    || echo "WARNING: could not fix the ownership of some files in /home/suwayomi" >&2

# setpriv is the util-linux equivalent of gosu/su-exec; --init-groups keeps
# the supplementary audio/video group memberships of the suwayomi user.
exec setpriv --reuid=suwayomi --regid=suwayomi --init-groups "$@"
