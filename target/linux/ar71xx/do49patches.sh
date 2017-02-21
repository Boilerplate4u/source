set -x
~/src/lede/scripts/patch-kernel.sh ~/src/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_mikrotik/linux-4.9.10 ~/src/lede/target/linux/ar71xx/patches-4.9 $1
