vim +PluginInstall +qall
vim +PluginUpdate +qall

cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --system-libclang --system-boost
