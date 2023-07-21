export WALLET_ROOT=$(pwd)
cd $HOME/.cargo/
rm -rf git registry

cd $HOME/Library/Caches/
rm -rf CocoaPods

cd $HOME/Library/Developer/Xcode/DerivedData/
rm -rf *

cd $HOME/Library/Developer/Xcode/iOS\ Device\ Logs/
rm -rf *

# Then go to wherever the pirate ios github cloned directory is:
cd $WALLET_ROOT
rm -rf Pods

arch -arm64 brew install

# Then from the same directory do command:
arch -x86_64 pod update

#In case you need to install / remove packages. Just uncomment below line..
#arch -x86_64 pod install 