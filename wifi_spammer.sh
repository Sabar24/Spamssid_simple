#!/bin/bash

INTERFACE="wlp2s0"  # ganti sesuai interface Wi-Fi
SSID_LIST=(
"ZeroDayNetwork" "CryptoGhost" "DarkWebHub" "PhantomPacket"
"RootAccess" "ShadowNode" "FirewallBreaker" "PacketSniffer"
"HexInjector" "BinaryBandit" "MalwareMaze" "CyberSpectre"
"AnonProxy" "IPHijacker" "ExploitZone" "HacktivistHQ"
"TrojanTrail" "CodePhantom" "BotnetBase" "CipherCore"
"KeyloggerKing" "NetNinja" "VirusVault" "PingPwn"
"PayloadPortal" "ScriptKiddie" "BlackHatBase" "CyberShadow"
"PacketPhreak" "EncryptedEdge" "ZeroTrustZone" "ShellShock"
"RootkitRealm" "TorTunnel" "DarkFiber" "CyberPhantom"
"IPMasker" "ProxyPioneer" "AccessDenied" "PacketPirate"
"MalwareManor" "ExploitEmpire" "ByteBandit" "CodeCracker"
"HackHive" "QuantumExploit" "CipherShadow" "VirusVortex"
"StealthSignal" "NetworkNomad"
)
CHANNELS=(1 2 3 4 5 6 7 8 9 10 11)
PIDS=()
MAX_IFACE=10

# Aktifkan monitor mode
function enable_monitor() {
    echo "[*] Mengaktifkan monitor mode..."
    sudo ip link set $INTERFACE down
    sudo iw dev $INTERFACE set type monitor
    sudo ip link set $INTERFACE up
    echo "[*] Monitor mode aktif di $INTERFACE."
}

# Restore ke managed mode
function restore_managed() {
    echo "[*] Mengembalikan interface ke mode Managed..."
    sudo ip link set $INTERFACE down
    sudo iw dev $INTERFACE set type managed
    sudo ip link set $INTERFACE up
    echo "[*] Interface $INTERFACE kembali normal."
}

# Stop broadcast
function stop_spam() {
    echo "[*] Menghentikan semua broadcast..."
    for pid in "${PIDS[@]}"; do
        sudo kill $pid 2>/dev/null
    done
    PIDS=()
    echo "[*] Semua broadcast dihentikan."
}

# Start broadcast semua SSID
function start_spam() {
    count=${#SSID_LIST[@]}
    if [ $count -lt $MAX_IFACE ]; then
        MAX_IFACE=$count
    fi

    # buat virtual interface
    for i in $(seq 0 $((MAX_IFACE-1))); do
        sudo iw dev $INTERFACE interface add mon$i type monitor
    done

    # broadcast SSID
    for idx in "${!SSID_LIST[@]}"; do
        iface="mon$((idx % MAX_IFACE))"
        channel=${CHANNELS[$RANDOM % ${#CHANNELS[@]}]}
        sudo airbase-ng -e "${SSID_LIST[$idx]}" -c $channel $iface > /dev/null 2>&1 &
        PIDS+=($!)
        echo "Broadcasting ${SSID_LIST[$idx]} di $iface channel $channel"
    done

    echo "[*] Semua SSID sudah broadcast. Gunakan menu 2 atau X untuk stop."
}

# Menu sederhana
function show_menu() {
    echo "=============================="
    echo "Wi-Fi SSID Spammer Menu"
    echo "1) Start broadcast"
    echo "2) Stop broadcast"
    echo "X) Exit"
    echo "=============================="
    read -p "Pilih opsi: " choice
    case $choice in
        1) start_spam ;;
        2) stop_spam ;;
        [xX]) stop_spam; restore_managed; echo "Keluar..."; exit 0 ;;
        *) echo "Opsi tidak valid." ;;
    esac
}

# Trap Ctrl+C
trap 'echo "[*] Ctrl+C terdeteksi!"; stop_spam; restore_managed; exit 0' SIGINT SIGTERM

# Aktifkan monitor mode sebelum menu
enable_monitor

# Loop menu
while true; do
    show_menu
done