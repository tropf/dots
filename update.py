'''updates stuff according to doc'''
import os
import sys
from conf import conf

dirname = os.path.dirname(os.path.realpath(__file__))
homedir = os.path.expanduser("~")

for conf_entry in conf:
    if 'target' in conf_entry:
        print('=== ' + conf_entry['target'] + ' ===')
    else:
        print('=== target missing ===')

    try:
        rc_included_filename = dirname + '/' + conf_entry['rc']
        rc_actual_filename = homedir + '/' + conf_entry['target']
        with open(dirname + '/' + conf_entry['comment']) as commentfile:
            comment_template = commentfile.read().strip()
            comment_template += '\n'

        comment_begin = comment_template.replace('$COMMENT', '***** BEGIN INCLUDE BLOCK *****')
        comment_end = comment_template.replace('$COMMENT', '***** END INCLUDE BLOCK *****')

        with open(dirname + '/' + conf_entry['inc']) as incfile:
            inc_template = incfile.read().strip()
        inc_line = inc_template.replace("$FILE", rc_included_filename)

        newlines = []
        keep_copying = True

        if (os.path.isfile(rc_actual_filename)):
            with open(rc_actual_filename, 'r') as rcfile:
                for line in rcfile:
                    line = line.strip()
                    if line == comment_begin:
                        keep_copying = False

                    if keep_copying:
                        newlines.append(line)

                    if line == comment_end:
                        keep_copying = True

        if len(sys.argv) >= 2 and '-r' == sys.argv[1]:
            print('  removing include block')
        else:
            print('  injecting include block')
            newlines.append(comment_begin)
            newlines.append(inc_line)
            newlines.append(comment_end)

        # writeback
        with open(rc_actual_filename, 'w') as rcfile:
            for line in newlines:
                rcfile.write(line + '\n')

    except Exception as e:
        print('something bad happened, will continue')

    try:
        # run update script
        if 'update' in conf_entry:
            update_script = dirname + '/' + conf_entry['update']
            print('  running update script')
            os.system(update_script)
    except Exception as e:
        print('  was not able to execute update script')
