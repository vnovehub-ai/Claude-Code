# Preset de Edição — Reels V9 HUB
# Desenvolvido e validado em sessão prática com IMG_9489

Substitui NOME_DO_VIDEO pelo nome do arquivo antes de colar no Claude CLI.

---

Tenho um vídeo em ~/Downloads/NOME_DO_VIDEO (testa as extensões .mp4, .mov, .MP4, .MOV). Edita ele pra Reels seguindo exatamente este preset:

## 1. TRANSCRIÇÃO
Transcreve com ElevenLabs Scribe (model_id=scribe_v1, language_code=por, timestamps_granularity=word, tag_audio_events=true), usando ELEVENLABS_API_KEY do ambiente.

## 2. CORTES DE CONTEÚDO
(Se o vídeo já estiver cortado, pula esta etapa e as etapas 3 e 4)
- Remove: falsos começos e palavras cortadas ("menta be--"), frases ou ideias repetidas (mantém só a melhor versão, a mais fluida e completa, normalmente a última), frases abandonadas no meio, comentários fora do roteiro (sobre câmera, gravação, exclamações), muletas de hesitação soltas ("é...", "ã", "hmm", "sabe?" solto)
- NÃO remove repetição retórica proposital (sem pausa e sem tropeço). Se estiver em dúvida, pergunta antes
- ANTES de executar, mostra a lista de cortes (timestamp + o que sai + o que fica) para aprovação

## 3. CORTES SECOS (ritmo acelerado)
- Sem fade, sem crossfade: corte direto de uma fala pra outra
- Remove toda pausa entre palavras
- Mantém só 0,02s antes e 0,02s depois de cada fala
- Alinha os cortes ao frame para não dessincronizar áudio e vídeo

## 4. ZOOM DINÂMICO
A cada corte, alterna o enquadramento entre 100% e zoom de 115% centralizado (disfarça os pulos de imagem)

## 5. TÍTULOS ATRÁS DA PESSOA
- Recorta a pessoa do fundo frame a frame usando segmentação de pessoas do Vision da Apple (VNGeneratePersonSegmentationRequest, qualidade accurate, via Swift). Se o swiftc der erro "redefinition of module SwiftBridging", contorna com -vfsoverlay escondendo /Library/Developer/…/swift/module.modulemap
- Compõe em camadas: fundo → título → pessoa (o texto fica atrás da cabeça e do corpo)
- Cerca de 1 título a cada 6–8 segundos, nos momentos de maior impacto: 1 ou 2 linhas, em MAIÚSCULAS, curtas (~14 caracteres por linha), fiéis à fala. Usa "≠" em contrastes do tipo "X não é Y"
- Fonte Futura Condensed ExtraBold (~/Library/Fonts/ ou /System/Library/Fonts/Supplemental/Futura.ttc, index 4), gigante (largura máx. 92% da tela). Linha principal em branco, linha de destaque em bege claro #E9DCC9. Fundo desfocado
- Animação de entrada de ~0,3s: título sobe de trás do corpo (deslocamento de 22% da altura da tela) de 0% a 100%. A 2ª linha entra 2 frames depois da 1ª
- Enquanto o título está na tela, escurece só o fundo em 32% (a pessoa não escurece)
- Posição: a base do texto fica rente ao topo da cabeça (a cabeça só encosta na base das letras, nunca esconde a palavra). Mede a altura da cabeça pela máscara durante cada título. Se a pessoa chega perto da câmera, o título sobe e diminui pra caber, sem passar de ~7,5% do topo (safe area do Instagram)
- O título aparece quando a ideia começa a ser dita, fica até o fim da frase (+0,3s) e sai em corte seco. Títulos não se sobrepõem
- Mostra a lista de títulos (timestamp + texto) para aprovação antes de renderizar

## 6. PREVIEW E VALIDAÇÃO
Antes do final, gera um preview rápido (encoder de hardware h264_videotoolbox) e confere que os títulos estão legíveis e não cobertos pela cabeça

## 7. EXPORTAÇÃO PRO INSTAGRAM
- 1080×1920 (Reels exibe no máximo 1080p), 30fps, gerado a partir do vídeo original
- H.264 libx264 CRF 17 preset slow, perfil high, yuv420p, AAC 256kbps 48kHz, -movflags +faststart
- Salva em ~/Downloads/NOME_DO_VIDEO_editado.mp4 (se já existir, pergunta antes de sobrescrever)
