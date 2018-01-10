echo "####################################################";
echo "# Please use this shell to install zsh, wget & git #";
echo "####################################################";

bash

echo "installing Font...";

cd /tmp/
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts

echo "installing Oh-My-ZSH...";

sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo "installing autosuggestions...";
zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions'
