#!/bin/bash
# Membuat menu registrasi akun
# Membuat menu login -> menyimpan data ke dalam file record.txt
# Membuat menu cari -> mencari data di dalam file record.txt
# Jika jumlah stok = 0, menampilkan pesan "Stok habis". Jika stok > 0, menampilkan pesan "Stok tersedia"
# Buku yang tersedia dapat dimasukkan ke keranjang
# User dapat menambahkan buku lain ke dalam keranjang
# Memproses transaksi -> menghitung total harga buku yang dibeli

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
    echo -n "Masukkan password: "
    read -r password
    if grep -q "$username;$password" user.txt; then
        echo "Login berhasil"
        # menu
    else
        echo "Login gagal"
    fi
}

# Fungsi untuk menampilkan menu beli
function beli {
    keranjang=()
    echo "Beli Buku"
    echo -n "Masukkan judul buku: "
    read -r judul
    if grep -q "$judul" daftar-buku.txt; then
        if grep -q "$judul" daftar-buku.txt | grep -q "0"; then
            echo "Stok habis"
        else
            grep "$judul" daftar-buku.txt
            repeat="y"
            while [ $repeat == "y" ]; do
                echo -n "Masukkan nama buku: "
                read -r judul_beli
                info_buku=$(grep "$judul_beli" daftar-buku.txt)
                echo -n "Masukkan jumlah buku: "
                read -r jumlah
                if [ "$jumlah" -gt $(echo "$info_buku" | cut -d";" -f4) ]; then
                    # Code to be executed if the condition is true
                    echo "Jumlah melebihi stok"
                else
                    harga=$(echo "$info_buku" | cut -d";" -f5)
                    keranjang+=("$judul_beli;$jumlah;$harga")
                    echo "Buku berhasil dimasukkan ke keranjang"
                    stok_sekarang=$(( $(echo "$info_buku" | cut -d";" -f4) - "$jumlah" ))
                    new_info_buku=$(echo "$info_buku" | sed "s/;\([0-9]\+\);/;$stok_sekarang;/")
                    sed "s/$info_buku/$new_info_buku/" daftar-buku.txt >> new_daftar-buku.txt
                    rm daftar-buku.txt && mv new_daftar-buku.txt daftar-buku.txt
                fi
                echo -n "Tambah buku lain ke dalam keranjang? (y/n): "
                read -r repeat
            done
        fi
    else
        echo "Buku tidak tersedia"
    fi
}

# Fungsi untuk menampilkan menu keranjang
function keranjang {
    echo "Keranjang"
    echo "Judul Buku | Jumlah Buku"
    cat keranjang.txt
}

$1
