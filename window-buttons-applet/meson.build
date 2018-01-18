if get_option('build-window-buttons') == true 

message('Building with Window Buttons')

target_name = 'window-buttons-applet'
target_files = ['window-buttons-applet.vala','window-button.vala']
window_buttons_dir = applets_dir + 'window-buttons/'

executable(target_name,target_files,dependencies: deps,install: true,install_dir: window_buttons_dir)

factory = custom_target('factory',
output: 'org.mate.panel.WindowButtonsApplet.mate-panel-applet',
input: 'org.mate.panel.WindowButtonsApplet.mate-panel-applet.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_buttons_dir + target_name],
install: true,
install_dir: factories_dir)

service = custom_target('service',
output: 'org.mate.panel.applet.WindowButtonsAppletFactory.service',
input: 'org.mate.panel.applet.WindowButtonsAppletFactory.service.in',
command: [sub,'@INPUT@', '@OUTPUT@',window_buttons_dir + target_name],
install: true,
install_dir: service_dir)

ui = custom_target('ui',
output: 'dialog.ui',
input: 'dialog.ui',
command: [sub,'@INPUT@', '@OUTPUT@'],
install: true,
install_dir: window_buttons_dir)

endif
