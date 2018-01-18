project('mate-window-applets','vala','c',version: '1.5.1',meson_version: '>=0.36.0')


add_global_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

add_global_arguments(['-DWNCK_I_KNOW_THIS_IS_UNSTABLE'],language:'c')

if get_option('prefix') == '/usr/local'

add_global_arguments(['-D', 'LOCAL_PATH'],language:'vala')

elif get_option('prefix') == '/usr/local/'

add_global_arguments(['-D', 'LOCAL_PATH'],language:'vala')

endif

sub = find_program('substitute.sh')

applets_dir = get_option('prefix') + '/lib/mate-applets/mate-window-applets/'
factories_dir = get_option('prefix') + '/' + get_option('datadir') + '/mate-panel/applets/'
service_dir = get_option('prefix') + '/' + get_option('datadir') + '/dbus-1/services/'

glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0')
gdk_dep = dependency('gdk-pixbuf-2.0')
wnck_dep = dependency('libwnck-3.0')

mate_dep = dependency('libmatepanelapplet-4.0')

deps = [glib_dep,gobject_dep,gtk_dep,gdk_dep,wnck_dep,mate_dep]

subdir('window-buttons-applet')
subdir('window-menu-applet')
subdir('window-title-applet')
subdir('data')
