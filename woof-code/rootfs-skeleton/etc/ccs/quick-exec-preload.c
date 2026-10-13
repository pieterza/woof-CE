/* Interpose gtk_dialog_run so PCManFM's "Execute File" dialog never appears.
 *
 * Libfm treats a readable .desktop file as an executable and asks
 * Execute / Cancel unless quick_exec is set. A savefile often puts that
 * back to 0. Returning the Execute response (1) before the dialog is
 * shown launches the desktop entry instead.
 *
 * Build (x86_64, glibc <= the target's):
 *   gcc -shared -fPIC -O2 -fno-stack-protector -o libccs-quick-exec.so quick-exec-preload.c -ldl
 *
 * Loaded only into pcmanfm. The constructor drops this library from
 * LD_PRELOAD so programs pcmanfm starts do not inherit it.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned long gtype;

static int (*real_gtk_dialog_run)(void *dialog);
static const char *(*gtk_widget_get_name)(void *widget);
static const char *(*gtk_window_get_title)(void *window);
static void (*gtk_container_forall)(void *container, void (*cb)(void *, void *), void *data);
static gtype (*gtk_container_get_type)(void);
static int (*g_type_check_instance_is_a)(void *instance, gtype type);

static void resolve(void)
{
	if (!real_gtk_dialog_run)
		real_gtk_dialog_run = dlsym(RTLD_NEXT, "gtk_dialog_run");
	if (!gtk_widget_get_name)
		gtk_widget_get_name = dlsym(RTLD_DEFAULT, "gtk_widget_get_name");
	if (!gtk_window_get_title)
		gtk_window_get_title = dlsym(RTLD_DEFAULT, "gtk_window_get_title");
	if (!gtk_container_forall)
		gtk_container_forall = dlsym(RTLD_DEFAULT, "gtk_container_forall");
	if (!gtk_container_get_type)
		gtk_container_get_type = dlsym(RTLD_DEFAULT, "gtk_container_get_type");
	if (!g_type_check_instance_is_a)
		g_type_check_instance_is_a = dlsym(RTLD_DEFAULT, "g_type_check_instance_is_a");
}

struct found {
	int msg;
	int exec;
};

static int is_container(void *widget)
{
	if (!widget || !gtk_container_get_type || !g_type_check_instance_is_a)
		return 0;
	return g_type_check_instance_is_a(widget, gtk_container_get_type());
}

static void visit(void *widget, void *data)
{
	struct found *found = data;
	const char *name;

	if (!widget || !found)
		return;
	if (gtk_widget_get_name) {
		name = gtk_widget_get_name(widget);
		if (name) {
			if (strcmp(name, "msg") == 0)
				found->msg = 1;
			else if (strcmp(name, "exec") == 0)
				found->exec = 1;
		}
	}
	if (found->msg && found->exec)
		return;
	if (is_container(widget) && gtk_container_forall)
		gtk_container_forall(widget, visit, found);
}

/* Libfm exec-file.ui: Execute response is 1 (FM_FILE_LAUNCHER_EXEC). */
static int is_exec_file_dialog(void *dialog)
{
	struct found found;
	const char *title;

	memset(&found, 0, sizeof found);
	if (is_container(dialog) && gtk_container_forall && gtk_widget_get_name) {
		gtk_container_forall(dialog, visit, &found);
		if (found.msg && found.exec)
			return 1;
	}
	if (gtk_window_get_title) {
		title = gtk_window_get_title(dialog);
		if (title && strcmp(title, "Execute File") == 0)
			return 1;
	}
	return 0;
}

static int entry_is_ours(const char *s, size_t len)
{
	const char *mark = "libccs-quick-exec.so";
	size_t mlen = strlen(mark);

	if (len < mlen || memcmp(s + len - mlen, mark, mlen) != 0)
		return 0;
	return len == mlen || s[len - mlen - 1] == '/';
}

/* pcmanfm's children (Chrome, Linphone) must not inherit this preload. */
static void strip_self_from_preload(void)
{
	const char *old;
	const char *p;
	char buf[4096];
	size_t n = 0;
	size_t len;

	old = getenv("LD_PRELOAD");
	if (!old || !strstr(old, "libccs-quick-exec.so"))
		return;
	for (p = old; *p; ) {
		while (*p == ':' || *p == ' ')
			p++;
		if (!*p)
			break;
		len = 0;
		while (p[len] && p[len] != ':' && p[len] != ' ')
			len++;
		if (!entry_is_ours(p, len)) {
			if (n + len + 2 >= sizeof buf)
				break;
			if (n)
				buf[n++] = ':';
			memcpy(buf + n, p, len);
			n += len;
		}
		p += len;
	}
	buf[n] = '\0';
	if (n == 0)
		unsetenv("LD_PRELOAD");
	else
		setenv("LD_PRELOAD", buf, 1);
}

__attribute__((constructor)) static void init(void)
{
	strip_self_from_preload();
}

int gtk_dialog_run(void *dialog)
{
	resolve();
	if (dialog && is_exec_file_dialog(dialog))
		return 1;
	if (!real_gtk_dialog_run)
		return -6; /* GTK_RESPONSE_CANCEL: do not hang if gtk is missing */
	return real_gtk_dialog_run(dialog);
}
