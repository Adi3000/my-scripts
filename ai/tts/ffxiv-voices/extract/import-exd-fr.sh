#!/bin/bash



for file in $(find /mnt/stockage/Jeux/FFXIV-extract/SaintCoinach.Cmd/2026.06.10.0000.0000/exd-fr -name "*.csv"); do
    if grep -q "int32,str,str" "$file"; then

        echo "${file#*/exd-fr/}..."       
        psql -c "TRUNCATE saintcoinach_file_fr;" 
        psql -c "\copy saintcoinach_file_fr (num_line, id_line, line) from '$file' WITH (FORMAT csv); delete from saintcoinach_file_fr where num_line in ('#', 'int32', 'key'); delete from saintcoinach_file_fr where line = ''; delete from saintcoinach_file_fr where id_line not like 'TEXT_%'; insert into ffxiv_lines_fr (file, num_line, id_line, line) select '${file#*/exd-fr/}', num_line, id_line, line from saintcoinach_file_fr;"
    fi
done
