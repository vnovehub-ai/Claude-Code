#!/usr/bin/env python3
"""
Identifica melhores cortes do vídeo LZ x Renato — Black Z 2026
Usa Claude API com o contexto estratégico da campanha
"""
import json, sys, os
import anthropic

def load_transcript(path):
    with open(path) as f:
        data = json.load(f)
    # Suporta formato ElevenLabs Scribe
    if "words" in data:
        words = data["words"]
        full_text = " ".join(w.get("text","") for w in words)
        return full_text, words
    elif "text" in data:
        return data["text"], []
    return str(data), []

def identify_clips(transcript_path, output_path, context_path):
    text, words = load_transcript(transcript_path)

    context = open(context_path).read() if os.path.exists(context_path) else ""

    prompt = f"""Você é um especialista em cortes virais para o mercado de cripto no Brasil.

CONTEXTO ESTRATÉGICO DA CAMPANHA:
{context}

TRANSCRIÇÃO COMPLETA DO VÍDEO (27 minutos):
{text}

TAREFA:
Identifique os 8–12 melhores momentos para cortes de Reels/TikTok/Shorts.

Para cada corte, retorne um JSON com:
- id: número sequencial
- classificacao: "A" (viral), "B" (conversão) ou "C" (aquecimento)
- titulo: título chamativo para o corte (max 60 chars)
- gancho: por que esse trecho vai viralizar ou converter
- inicio_texto: primeiras palavras do trecho (para localizar no vídeo)
- fim_texto: últimas palavras do trecho
- duracao_estimada: em segundos (idealmente 30–60s para A, até 90s para B/C)
- personagem: LZ / Albani / Analista / Todos
- cta_sugerido: qual dos 3 CTAs encaixa melhor

REGRAS:
- Priorizar momentos com emoção genuína, polêmica, dado chocante ou contraste forte
- Evitar promessas explícitas de lucro
- Priorizar falas do Albani sobre a carteira real
- Priorizar quando analista institucional valida cripto
- Não incluir cenas longas de gráfico sem narrativa humana

Retorne APENAS o JSON, sem texto adicional:
{{"cortes": [...]}}
"""

    client = anthropic.Anthropic()
    print("Analisando transcrição com Claude...")

    message = client.messages.create(
        model="claude-opus-5",
        max_tokens=4096,
        messages=[{"role": "user", "content": prompt}]
    )

    response_text = message.content[0].text

    # Extrair JSON da resposta
    try:
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0]
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0]
        clips = json.loads(response_text.strip())
    except json.JSONDecodeError:
        print("AVISO: Resposta não era JSON puro, salvando como texto")
        clips = {"raw": response_text}

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(clips, f, ensure_ascii=False, indent=2)

    print(f"\n✅ {len(clips.get('cortes', []))} cortes identificados")
    print(f"Salvo em: {output_path}")

    # Preview dos cortes
    for c in clips.get("cortes", []):
        print(f"\n[{c['classificacao']}] {c['titulo']}")
        print(f"   Duração: ~{c['duracao_estimada']}s | {c['personagem']}")
        print(f"   Gancho: {c['gancho'][:80]}...")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python3 lz_identify_clips.py transcript.json output.json [context.md]")
        sys.exit(1)

    context = sys.argv[3] if len(sys.argv) > 3 else ""
    identify_clips(sys.argv[1], sys.argv[2], context)
