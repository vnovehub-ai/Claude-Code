#!/bin/bash
# Pipeline completo: LZ x Renato | Black Z 2026
# Uso: bash lz_pipeline.sh
# Saída: ~/Downloads/lz_cortes/

VIDEO_PATTERN=~/Downloads/"VIDEO YOUTUBE RENATO + LZ"
OUTPUT_DIR=~/Downloads/lz_cortes
CONTEXT_FILE=~/Claude-Code/projeto-hub/context/lz_blackz_context.md
SCRIBE_SCRIPT=~/Claude-Code/projeto-hub/scripts/transcribe_scribe.py
IDENTIFY_SCRIPT=~/Claude-Code/projeto-hub/scripts/lz_identify_clips.py

# Encontrar o arquivo de vídeo (qualquer extensão)
VIDEO=$(ls "${VIDEO_PATTERN}".* 2>/dev/null | head -1)
[ -z "$VIDEO" ] && VIDEO=$(ls ~/Downloads/VIDEO\ YOUTUBE\ RENATO*.* 2>/dev/null | head -1)
[ -z "$VIDEO" ] && { echo "ERRO: Vídeo não encontrado. Verifique o nome em ~/Downloads/"; ls ~/Downloads/*.mp4 2>/dev/null; exit 1; }

echo "Vídeo encontrado: $VIDEO"
mkdir -p "$OUTPUT_DIR"

# 1. TRANSCREVER com ElevenLabs Scribe
TRANSCRIPT_JSON="$OUTPUT_DIR/transcript_lz.json"
if [ ! -f "$TRANSCRIPT_JSON" ]; then
    echo ""
    echo "=== [1/3] TRANSCREVENDO com ElevenLabs Scribe ==="
    python3 "$SCRIBE_SCRIPT" "$VIDEO" "$TRANSCRIPT_JSON"
else
    echo "=== [1/3] Transcrição já existe, pulando... ==="
fi

# 2. IDENTIFICAR melhores cortes com IA
CLIPS_JSON="$OUTPUT_DIR/clips_lz.json"
echo ""
echo "=== [2/3] IDENTIFICANDO CORTES VIRAIS ==="
python3 "$IDENTIFY_SCRIPT" "$TRANSCRIPT_JSON" "$CLIPS_JSON" "$CONTEXT_FILE"

# 3. CORTAR os clipes em 9:16
echo ""
echo "=== [3/3] CORTANDO EM FORMATO REELS ==="
python3 ~/Claude-Code/projeto-hub/scripts/cut_clips.sh "$VIDEO" "$CLIPS_JSON" "$OUTPUT_DIR"

echo ""
echo "✅ Pipeline LZ concluído!"
echo "Cortes salvos em: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"/*.mp4 2>/dev/null
