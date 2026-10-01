#!/usr/bin/env python3
"""
Transcreve vídeo usando ElevenLabs Scribe com timestamps por palavra
"""
import sys, json, os
import requests

ELEVENLABS_API_KEY = os.environ.get("ELEVENLABS_API_KEY", "")

def transcribe(video_path, output_path):
    if not ELEVENLABS_API_KEY:
        print("ERRO: defina a variável ELEVENLABS_API_KEY")
        print("export ELEVENLABS_API_KEY=sua_chave_aqui")
        sys.exit(1)

    print(f"Enviando para ElevenLabs Scribe: {video_path}")
    print("Isso pode levar alguns minutos para vídeos longos...")

    url = "https://api.elevenlabs.io/v1/speech-to-text"
    headers = {"xi-api-key": ELEVENLABS_API_KEY}

    with open(video_path, "rb") as f:
        files = {"file": (os.path.basename(video_path), f, "video/mp4")}
        data = {
            "model_id": "scribe_v1",
            "language_code": "pt",
            "timestamps_granularity": "word",
            "diarize": "true"
        }
        response = requests.post(url, headers=headers, files=files, data=data)

    if response.status_code != 200:
        print(f"ERRO {response.status_code}: {response.text}")
        sys.exit(1)

    result = response.json()

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    word_count = len(result.get("words", []))
    duration = result.get("words", [{}])[-1].get("end", 0) if result.get("words") else 0
    print(f"✅ Transcrição concluída: {word_count} palavras, {duration:.1f}s")
    print(f"Salvo em: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python3 transcribe_scribe.py video.mp4 output.json")
        sys.exit(1)
    transcribe(sys.argv[1], sys.argv[2])
