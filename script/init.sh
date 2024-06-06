#!/bin/bash

bin_path=~/.local/bin
dotfiles_path=~/work/keisuke/dotfiles

powershell_path=/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0
office_path=/mnt/c/Program\ Files/Microsoft\ Office/root/Office16
win_path=/mnt/c/Windows
system32_path=/mnt/c/WINDOWS/system32

# Path to windows programs
ln -s $powershell_path/powershell.exe $bin_path/powershell.exe
ln -s "$office_path"/excel.exe $bin_path/excel.exe
ln -s "$office_path"/winword.exe $bin_path/winword.exe
ln -s "$office_path"/powerpnt.exe $bin_path/powerpnt.exe
ln -s $win_path/explorer.exe $bin_path/explorer.exe
ln -s $system32_path/cmd.exe $bin_path/cmd.exe

# Other path
ln -s $dotfiles_path/script/excel $bin_path/excel
ln -s $dotfiles_path/script/word $bin_path/word
ln -s $dotfiles_path/script/ppnt $bin_path/ppnt
ln -s $dotfiles_path/script/we $bin_path/we
