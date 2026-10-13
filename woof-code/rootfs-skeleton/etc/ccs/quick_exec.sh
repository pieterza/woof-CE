#!/bin/sh
# PCManFM asks "This text file seems to be an executable script" unless
# quick_exec=1. ~/.config/libfm/libfm.conf is loaded last and a savefile
# often has quick_exec=0 written by an earlier PCManFM run.
set_quick_exec() {
	conf="$1"
	mkdir -p "${conf%/*}"
	# Rewrite the same inode. sed -i renames the file, and PCManFM
	# drops its config watch on delete instead of reloading.
	if [ ! -f "$conf" ]; then
		printf '[config]\nquick_exec=1\n' > "$conf"
		return
	fi
	if grep -q '^[[:space:]]*quick_exec[[:space:]]*=' "$conf"; then
		sed 's/^[[:space:]]*quick_exec[[:space:]]*=.*/quick_exec=1/' "$conf" > "$conf.new"
	elif grep -q '^\[config\]' "$conf"; then
		sed '/^\[config\]/a quick_exec=1' "$conf" > "$conf.new"
	else
		{ printf '[config]\nquick_exec=1\n'; cat "$conf"; } > "$conf.new"
	fi
	cat "$conf.new" > "$conf"
	rm -f "$conf.new"
}
set_quick_exec /etc/xdg/libfm/libfm.conf
set_quick_exec /root/.config/libfm/libfm.conf
