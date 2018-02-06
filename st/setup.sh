echo "################################";
echo "# Simple Terminal - Step 1     #";
echo "# Installing Terminfo files    #";
echo "# (required for tmux etc.)     #";
echo "# Downloading source & patches #";
echo "################################";

echo "cleaning up old files...";
xargs rm -r < .gitignore

wget https://dl.suckless.org/st/st-0.7.tar.gz;
wget https://st.suckless.org/patches/clipboard/st-clipboard-0.7.diff
wget https://st.suckless.org/patches/scrollback/st-scrollback-0.7.diff
wget https://st.suckless.org/patches/visualbell/st-visualbell-20160727-308bfbf.diff

echo "extracting source...";

tar -xzf st-0.7.tar.gz
cd st-0.7

echo "applying patches...";

patch -i ../st-clipboard-0.7.diff
patch -i ../st-scrollback-0.7.diff
patch -i ../st-visualbell-20160727-308bfbf.diff

make config.h

patch -i ../mine.patch

echo "installing terminfo locally...";
tic -s st-0.7/st.info

echo "installing terminfo globally... (you can abort this step)";
sudo tic -s st-0.7/st.info

echo "##########################################";
echo "# Simple Terminal - Step 2               #";
echo "# Installing GUI                         #";
echo "##########################################";
echo "# X Terminal installation                #";
echo "# Press [ENTER] to continue (desktop PC) #";
echo "# Press CTRL-C to abort (server, ssh)    #"
echo "##########################################";

read entered;
echo "Continuing installation...";

echo "need password to install...";
sudo make install

echo "you can now set st as the standard terminal emulator";
