#!/bin/bash
sudo pacman -Sc
sudo pacman -Rs $(pacman -Qtdq)
yaourt -Sc
yaourt -Rs $(yaourt -Qtdq)
