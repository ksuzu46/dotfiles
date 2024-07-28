#!/bin/bash

bin_path=~/.local/bin
dotfiles_path=~/work/src/github.com/ksuzu46/dotfiles

powershell_path=/mnt/c/Program\ Files/PowerShell/7
office_path=/mnt/c/Program\ Files/Microsoft\ Office/root/Office16
win_path=/mnt/c/Windows

# Path to windows programs
ln -nfs "$powershell_path"/pwsh.exe $bin_path/pwsh.exe
ln -nfs "$office_path"/excel.exe $bin_path/excel.exe
ln -nfs "$office_path"/winword.exe $bin_path/winword.exe
ln -nfs "$office_path"/powerpnt.exe $bin_path/powerpnt.exe
ln -nfs $win_path/explorer.exe $bin_path/explorer.exe

# Other path
ln -nfs $dotfiles_path/script/excel $bin_path/excel
ln -nfs $dotfiles_path/script/word $bin_path/word
ln -nfs $dotfiles_path/script/ppnt $bin_path/ppnt
ln -nfs $dotfiles_path/script/we $bin_path/we
