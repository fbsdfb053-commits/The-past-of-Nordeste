# The Past of Nordeste

RPG 2D de aventura e vida no interior do Nordeste brasileiro, desenvolvido para Godot 4.7.2.

## Protótipo jogável — primeira fatia

Esta versão já contém:
- tela inicial com três espaços independentes de salvamento;
- sítio inicial inspirado em Mulungu, com movimentação em oito direções;
- teclado e controle Xbox (analógico esquerdo, A, X, Y e Menu);
- quatro canteiros onde é possível plantar, avançar o dia e colher;
- dinheiro, sementes, contagem de colheitas e posição persistidos;
- salvamento manual, automático a cada cinco minutos e ao fechar;
- arquivo temporário validado e cópia de segurança .bak.

Os gráficos e a atividade agrícola ainda são protótipos. NPCs, vila explorável, inventário completo, mina, missões, narrativa, música e efeitos sonoros ainda não foram implementados.

## Executar

Abra a pasta no Godot 4.7.2 e pressione F6/F5 ou use Executar projeto.

## Controles

- Analógico esquerdo / WASD / setas: mover
- A / Enter / Espaço: plantar, colher ou interagir
- X / N: avançar um dia
- Y / I: salvar
- Menu / Esc: pausar

## Salvamentos

Os dados ficam em user://saves/, fora da pasta do projeto. Existem três espaços. Cada gravação valida o JSON temporário antes de substituir o arquivo principal, preservando uma cópia anterior.

## Próximas etapas

1. Melhorar personagem, animações e arte pixelada.
2. Construir vila de Mulungu e NPCs com diálogos.
3. Adicionar inventário, coleta, ferramentas e ciclo de dia/noite.
4. Criar mina, missões, relações e áudio regional.
5. Testar salvamento/recuperação e exportar para Linux.

**Validação:** os arquivos foram enviados ao GitHub, mas esta sessão não dispõe do executável Godot para compilar ou testar. A primeira execução precisa ser validada no Godot 4.7.2 local.
