if get_option('build-window-menu') == true 

message('Building with Window Menu')

target_name = 'window-menu-applet'
target_files = ['window-menu-applet.vala','window-menu-button.vala']
window_menu_dir = applets_dir + 'window-menu/'

executable(target_name,target_files,dependencies: deps,install: true,install_dir: window_menu_dir)

menu_factory = custom_target('menu_factory',
output: 'org.mate.panel.WindowMenuApplet.mate-panel-applet',
input: 'org.mate.panel.WindowMenuApplet.mate-panel-applet.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_menu_dir + target_name],
install: true,
install_dir: factories_dir)

menu_service = custom_target('menu_service',
output: 'org.mate.panel.applet.WindowMenuAppletFactory.service',
input: 'org.mate.panel.applet.WindowMenuAppletFactory.service.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_menu_dir + target_name],
install: true,
install_dir: service_dir)

menu_ui = custom_target('menu_ui',
output: 'dialog.ui',
input: 'dialog.ui',
command: [sub,'@INPUT@', '@OUTPUT@'],
install: true,
install_dir: window_menu_dir)

endif
