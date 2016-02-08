#!/bin/bash
pactl load-module module-alsa-sink device=bluetooth
pactl load-module module-alsa-source device=bluetooth
