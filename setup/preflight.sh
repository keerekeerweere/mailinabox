#!/bin/bash
# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Please re-run like this:"
	echo
	echo "sudo $0"
	echo
	exit 1
fi

# Check that we are running on Ubuntu 22.04 LTS (or 22.04.xx).
# Pull in the variables defined in /etc/os-release but in a
# namespace to avoid polluting our variables.
source <(cat /etc/os-release | sed s/^/OS_RELEASE_/)
if [ "${OS_RELEASE_ID:-}" != "ubuntu" ] || [ "${OS_RELEASE_VERSION_ID:-}" != "22.04" ]; then
	echo "Mail-in-a-Box only supports being installed on Ubuntu 22.04, sorry. You are running:"
	echo
	echo "${OS_RELEASE_ID:-"Unknown linux distribution"} ${OS_RELEASE_VERSION_ID:-}"
	echo
	echo "We can't write scripts that run on every possible setup, sorry."
	exit 1
fi

# Check that we have enough memory.
#
# /proc/meminfo reports free memory in kibibytes. Our baseline will be 512 MB,
# which is 500000 kibibytes.
#
# We will display a warning if the memory is below 768 MB which is 750000 kibibytes
#
# Skip the check if we appear to be running inside of Vagrant, because that's really just for testing.
# Also adjust thresholds for containers which may have different memory constraints.
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
if is_lxc_container; then
	# In containers, memory limits are often managed at the container level
	# Be more lenient with memory requirements
	MEMORY_THRESHOLD=256000  # 256MB for containers
	WARNING_THRESHOLD=384000 # 384MB warning for containers
else
	MEMORY_THRESHOLD=490000  # 512MB for VMs
	WARNING_THRESHOLD=750000 # 768MB warning for VMs
fi

if [ "$TOTAL_PHYSICAL_MEM" -lt "$MEMORY_THRESHOLD" ]; then
if [ ! -d /vagrant ]; then
	TOTAL_PHYSICAL_MEM=$(( TOTAL_PHYSICAL_MEM * 1024 / 1000 / 1000 ))
	echo "Your Mail-in-a-Box needs more memory (RAM) to function properly."
	if is_lxc_container; then
		echo "Please allocate at least 512 MB to the LXC container, 1 GB recommended."
	else
		echo "Please provision a machine with at least 512 MB, 1 GB recommended."
	fi
	echo "This machine has $TOTAL_PHYSICAL_MEM MB memory."
	exit
fi
fi
if [ "$TOTAL_PHYSICAL_MEM" -lt "$WARNING_THRESHOLD" ]; then
	echo "WARNING: Your Mail-in-a-Box has less than 768 MB of memory."
	echo "         It might run unreliably when under heavy load."
fi

# Check that tempfs is mounted with exec
MOUNTED_TMP_AS_NO_EXEC=$(grep "/tmp.*noexec" /proc/mounts || /bin/true)
if [ -n "$MOUNTED_TMP_AS_NO_EXEC" ]; then
	echo "Mail-in-a-Box has to have exec rights on /tmp, please mount /tmp with exec"
	exit
fi

# Check that no .wgetrc exists
if [ -e ~/.wgetrc ]; then
	echo "Mail-in-a-Box expects no overrides to wget defaults, ~/.wgetrc exists"
	exit
fi

# Check that we are running on x86_64 or i686 architecture, which are the only
# ones we support / test.
ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ] && [ "$ARCHITECTURE" != "i686" ]; then
	echo
	echo "WARNING:"
	echo "Mail-in-a-Box has only been tested on x86_64 and i686 platform"
	echo "architectures. Your architecture, $ARCHITECTURE, may not work."
	echo "You are on your own."
	echo
fi
