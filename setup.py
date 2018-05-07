import os
from conf import conf

dirname = os.path.dirname(os.path.realpath(__file__))

for conf_entry in conf:
    if 'target' in conf_entry:
        print('=== ' + conf_entry['target'] + ' ===')
    else:
        print('=== target missing ===')

    if 'setup' in conf_entry:
        setup_script_file = dirname + '/' + conf_entry['setup']
        print('  running setup script ' + setup_script_file)

        if os.path.isfile(setup_script_file) and os.access(setup_script_file, os.X_OK):
            os.system(setup_script_file)
    else:
        print('  no setup script, skipping')

import update
