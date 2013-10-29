#!/bin/bash

inkscape --without-gui --export-png="curl.png" --export-background-opacity=0 --export-width=41 --export-height=41 "curl.svg"
inkscape --without-gui --export-png="curl2x.png" --export-background-opacity=0 --export-width=82 --export-height=82 "curl.svg"