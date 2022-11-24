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

# Then from the same directory do command for M1/M2 chipsets:
arch -x86_64 pod update
