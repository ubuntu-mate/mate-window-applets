schema_dir = get_option('prefix') + '/' + get_option('datadir') + '/' + 'glib-2.0/schemas'

gschema = custom_target('gscema',
output: 'org.mate.window-applets.gschema.xml',
input: 'org.mate.window-applets.gschema.xml',
command: [sub,'@INPUT@', '@OUTPUT@'],
install: true,
install_dir: schema_dir,
)
