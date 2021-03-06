conf = [
    {
        "target": ".zshrc",
        "rc": "zshrc",
        "inc": "zshrc.inc",
        "comment": "zshrc.comment",
        "setup": "zshrc.setup.sh"
    },
    {
        "target": ".vimrc",
        "rc": "vimrc",
        "inc": "vimrc.inc",
        "comment": "vimrc.comment",
        "setup": "vimrc.setup.sh",
        "update": "vimrc.update.sh"
    },
    {
        "target": ".gitconfig",
        "rc": "gitconfig",
        "inc": "gitconfig.inc",
        "comment": "gitconfig.comment"
    },
    {
        "target": ".tmux.conf",
        "rc": "tmux.conf",
        "inc": "tmux.conf.inc",
        "comment": "tmux.conf.comment"
    },
    {
        "_note": "Simple Terminal, ST is recompiled on change of its config, so it is basically reinstalled, hence the same script",
        "setup": "st/setup.sh",
        "update": "st/setup.sh"
    }
]
