#!/bin/bash

keranjang=()
username=""
# Fungsi untuk menampilkan menu registrasi akun
function registrasi {
    echo "Registrasi Akun"
    echo -n "Masukkan username: "
    read -r username
    echo -n "Masukkan password: "
    read -r password
    echo "$username;$password" >> user.txt
    echo "Registrasi berhasil"
}

# Fungsi untuk menampilkan menu login
function login {
    echo "Login"
    echo -n "Masukkan username: "
    read -r username
    username=$username
    echo -n "Masukkan password: "
    read -r password
    if grep -q "$username;$password" user.txt; then
        clear
        menu
    else
        echo "Login gagal"
    fi
}

# Fungsi untuk menampilkan menu beli
function beli {
    repeat="y"
    echo "Beli Buku"
    while [ $repeat == "y" ]; do
    echo -n "Masukkan judul buku: "
    read -r judul
    if grep -q "$judul" daftar-buku.txt; then
        grep "$judul" daftar-buku.txt
        echo "-------------------------------------"
        echo -n "Masukkan nama buku: "
        read -r judul_beli
        info_buku=$(grep "$judul_beli" daftar-buku.txt)
        echo -n "Masukkan jumlah buku: "
        read -r jumlah
        if [ "$jumlah" -gt $(echo "$info_buku" | cut -d";" -f4) ]; then
            echo "Jumlah melebihi stok"
        else
            harga=$(echo "$info_buku" | cut -d";" -f5)
            keranjang+=("$username;$judul_beli;$jumlah;$harga")
            echo "Buku berhasil dimasukkan ke keranjang"
            stok_sekarang=$(( $(echo "$info_buku" | cut -d";" -f4) - "$jumlah" ))
            new_info_buku=$(echo "$info_buku" | sed "s/;\([0-9]\+\);/;$stok_sekarang;/")
            sed "s/$info_buku/$new_info_buku/" daftar-buku.txt >> new_daftar-buku.txt
            rm daftar-buku.txt && mv new_daftar-buku.txt daftar-buku.txt
        fi
        echo -n "Tambah buku lain ke dalam keranjang? (y/n): "
        read -r repeat
        echo "-------------------------------------"
    else
        echo "Buku tidak tersedia"
        break
    fi
    done
}

# Fungsi untuk menampilkan menu keranjang
function keranjang {
    echo "Keranjang"
    echo "Judul Buku | Jumlah Buku | Harga Buku"
    echo "-------------------------------------"

    for i in "${keranjang[@]}"; do
        judul_buku=$(echo "$i" | cut -d";" -f2)
        jumlah_buku=$(echo "$i" | cut -d";" -f3)
        harga_buku=$(echo "$i" | cut -d";" -f4)
        echo "$judul_buku | $jumlah_buku | $harga_buku"
    done
}

# Fungsi untuk menampilkan menu proses transaksi
function proses_transaksi {
    echo "Transaksi Anda"
    echo "Atas nama: $username"
    echo "-------------------------------------"
    echo "Judul Buku | Jumlah Buku | Harga Buku | Total Harga"
    echo "--------------------------------------------------"

    for i in "${keranjang[@]}"; do
        judul_buku=$(echo "$i" | cut -d";" -f2)
        jumlah_buku=$(echo "$i" | cut -d";" -f3)
        harga_buku=$(echo "$i" | cut -d";" -f4)
        total_harga=$(( "$jumlah_buku" * "$harga_buku" ))
        echo "$judul_buku | $jumlah_buku | $harga_buku | $total_harga"
    done

    total_semua=0
    for i in "${keranjang[@]}"; do
        harga_buku=$(echo "$i" | cut -d";" -f3)
        total_semua=$(( "$total_semua" + "$harga_buku" ))
    done
    echo "Total: $total_semua"

    save_transaksi

    echo -n "Apakah Anda ingin memproses transaksi? (y/n): "
    read -r pilihan
    if [ "$pilihan" == "y" ]; then
        echo "Transaksi berhasil"
        menu
    else
        echo "Transaksi dibatalkan"
        main
    fi
}

function save_transaksi {
    for i in "${keranjang[@]}"; do
        echo "$i" >> transaksi.txt
    done
}

function menu {
    echo "Menu"
    echo "1. Beli Buku"
    echo "2. Keranjang"
    echo "3. Proses Transaksi"
    echo "0. Keluar"
    echo -n "Masukkan pilihan: "
    read -r pilihan
    case $pilihan in
        1) beli ; menu ;;
        2) keranjang ; menu ;;
        3) proses_transaksi ;;
        0) main ;;
        *) echo "Pilihan tidak tersedia" ; menu ;;
    esac
}

function main {
    echo "Selamat datang di Toko Buku"
    echo "1. Registrasi"
    echo "2. Login"
    echo "0. Keluar"
    echo -n "Masukkan pilihan: "
    read -r pilihan
    case $pilihan in
        1) registrasi ; main ;;
        2) login ;;
        0) exit ;;
        *) echo "Pilihan tidak tersedia" ;;
    esac
}

main
