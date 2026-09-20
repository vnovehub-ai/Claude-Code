#!/bin/bash
# B-roll composition correto para copy_03442D26...
# Rode no terminal local: bash ~/Claude-Code/projeto-hub/scripts/broll_v2.sh

INPUT=~/Downloads/copy_03442D26-AE71-42D7-938B-8A93775DC3DF.mp4
OUTPUT=~/Downloads/video_broll_v2.mp4
BROLL_DIR=~/Downloads/broll
MANDELA=~/Downloads/Nelson_Mandela-2008_\(edit\).jpg

# Verificar arquivos
echo "Verificando arquivos..."
for f in "$INPUT" "$BROLL_DIR/broll_01.mp4" "$BROLL_DIR/broll_02.mp4" \
          "$BROLL_DIR/broll_04.mp4" "$BROLL_DIR/broll_05.mp4" "$BROLL_DIR/broll_06.mp4"; do
    [ -f "$f" ] || { echo "FALTANDO: $f"; exit 1; }
done
echo "Todos os arquivos encontrados!"

# Duração do vídeo principal
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT")
echo "Duração do vídeo: ${DURATION}s"

# Resolução alvo: 1080x1920 (9:16 vertical)
W=1080
H=1920

ffmpeg -y \
  -i "$INPUT" \
  -i "$BROLL_DIR/broll_01.mp4" \
  -i "$BROLL_DIR/broll_02.mp4" \
  -i "$BROLL_DIR/broll_04.mp4" \
  -i "$BROLL_DIR/broll_05.mp4" \
  -i "$BROLL_DIR/broll_06.mp4" \
  -loop 1 -i "$MANDELA" \
  -filter_complex "
    [0:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,
          eq=contrast=1.05:brightness=0.02:saturation=1.08[main];

    [1:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,trim=duration=2[b01];

    [2:v]crop=iw/2:ih:0:0,
          scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,trim=duration=2[b02];

    [3:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,trim=duration=2[b04];

    [4:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,trim=duration=2[b05];

    [5:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,
          pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,trim=duration=3[b06];

    [6:v]scale=378:213,trim=duration=1.5[mandela_scaled];

    [main][b01]overlay=enable='between(t,3,5)',x=0,y=0[v1];
    [v1][b02]overlay=enable='between(t,10,12)',x=0,y=0[v2];
    [v2][b04]overlay=enable='between(t,13.64,15.64)',x=0,y=0[v3];
    [v3][b05]overlay=enable='between(t,28,30)',x=0,y=0[v4];
    [v4][b06]overlay=enable='between(t,68.14,71.14)',x=0,y=0[v5];
    [v5][mandela_scaled]overlay=enable='between(t,87.04,88.54)',x=${W}-378-10,y=100[vout];

    [0:a]afade=t=out:st=$(echo "$DURATION - 0.5" | bc):d=0.5[aout]
  " \
  -map "[vout]" -map "[aout]" \
  -vcodec libx264 -preset fast -crf 22 \
  -acodec aac -b:a 192k \
  -movflags +faststart \
  "$OUTPUT"

echo ""
echo "✅ Pronto! Arquivo salvo em: $OUTPUT"
