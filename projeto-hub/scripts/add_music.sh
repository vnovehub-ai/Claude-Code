#!/bin/bash
# Adiciona trilha sonora ao video_broll_v2.mp4
# Uso: bash add_music.sh [caminho_da_musica.mp3]

VIDEO=~/Downloads/video_broll_v2.mp4
MUSIC=${1:-~/Downloads/trilha.mp3}
OUTPUT=~/Downloads/video_final_com_musica.mp4

[ -f "$VIDEO" ] || { echo "ERRO: $VIDEO não encontrado. Rode broll_v2.sh primeiro."; exit 1; }
[ -f "$MUSIC" ] || { echo "ERRO: Música não encontrada em $MUSIC"; echo "Uso: bash add_music.sh /caminho/da/musica.mp3"; exit 1; }

DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
echo "Duração do vídeo: ${DURATION}s"
echo "Adicionando trilha..."

ffmpeg -y \
  -i "$VIDEO" \
  -i "$MUSIC" \
  -filter_complex "
    [1:a]volume=0.08,
         afade=t=in:st=0:d=2,
         afade=t=out:st=$(echo "$DURATION - 2" | bc):d=2[music];
    [0:a][music]amix=inputs=2:duration=first:dropout_transition=2[aout]
  " \
  -map 0:v \
  -map "[aout]" \
  -vcodec copy \
  -acodec aac -b:a 192k \
  -movflags +faststart \
  "$OUTPUT"

echo ""
echo "✅ Pronto! Arquivo salvo em: $OUTPUT"
