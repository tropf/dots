import os
import json

dirname = os.path.dirname(os.path.realpath(__file__))

conf_filename = dirname + '/conf.json'
with open(conf_filename, 'r') as infile:
    conf = json.loads(infile.read())

for conf_entry in conf:
    if 'target' in conf_entry:
        print('=== {} ==='.format(conf_entry['target']))
    else:
        print('=== {} ==='.format('target missing')

    if 'setup' in conf_entry:
        setup_script_file = dirname + '/' + conf_entry['setup']
        print('  running setup script {}'.format(setup_script_file))

        if os.path.isfile(setup_script_file) and os.access(setup_script_file, os.X_OK):
            os.system(setup_script_file)
    else:
        print ('  no setup script, skipping')

import update
