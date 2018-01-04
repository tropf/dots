echo "##########################################";
echo "# X Terminal installation                #";
echo "# Press [ENTER] to continue (desktop PC) #";
echo "# Press CTRL-C to abort (server, ssh)    #"
echo "##########################################";

read entered;

echo "Continuing installation...";

echo "Downloading source & patches";

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

echo "need password to install...";
sudo make install
