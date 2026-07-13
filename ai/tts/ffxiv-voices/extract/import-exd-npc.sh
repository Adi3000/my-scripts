#!/bin/bash


file_fr="/mnt/stockage/Jeux/FFXIV-extract/dictionnary-fr.csv"
file_en="/mnt/stockage/Jeux/FFXIV-extract/dictionnary-en.csv"

csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd-fr/BNpcName.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 > $file_fr
csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd-fr/ENpcResident.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 >> $file_fr
csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd-fr/EObjName.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 >> $file_fr
csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd/BNpcName.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 > $file_en
csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd/ENpcResident.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 >> $file_en
csvcut -c1,2  /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd/EObjName.csv | egrep -v "^.*.,$"  | egrep  "^[0-9]+.*$" | csvformat -U 2 >> $file_en

psql -c "TRUNCATE dictionnary_en;"
psql -c "\copy dictionnary_en (id, text_label) from '$file_en' WITH (FORMAT csv);"

psql -c "TRUNCATE dictionnary_fr;"
psql -c "\copy dictionnary_fr (id, text_label) from '$file_fr' WITH (FORMAT csv);"
