if get_option('build-window-title') == true

message('Building with Window Menu')

target_name = 'window-title-applet'
target_files = ['window-title-applet.vala']
window_title_dir = applets_dir + 'window-title/'

executable(target_name,target_files,dependencies: deps,install: true,install_dir: window_title_dir)

title_factory = custom_target('title_factory',
output: 'org.mate.panel.WindowTitleApplet.mate-panel-applet',
input: 'org.mate.panel.WindowTitleApplet.mate-panel-applet.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_title_dir + target_name],
install: true,
install_dir: factories_dir)

title_service = custom_target('title_service',
output: 'org.mate.panel.applet.WindowTitleAppletFactory.service',
input: 'org.mate.panel.applet.WindowTitleAppletFactory.service.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_title_dir + target_name],
install: true,
install_dir: service_dir)

title_ui = custom_target('title_ui',
output: 'dialog.ui',
input: 'dialog.ui',
command: [sub,'@INPUT@', '@OUTPUT@'],
install: true,
install_dir: window_title_dir)

endif
