# The Past of Nordeste

RPG 2D de aventura e vida no interior do Nordeste brasileiro, desenvolvido em Godot 4.7.2.

## Estado atual
**Fundação inicial do projeto.** Esta primeira entrega prepara:
- projeto Godot 4.7.2 com renderizador Compatibility, pensado para PCs modestos;
- primeira cena jogável com movimentação em oito direções;
- suporte a teclado e controle Xbox (analógico/D-pad e botões);
- protótipo visual simples do sítio;
- sistema inicial de 3 espaços de salvamento, gravação atômica e cópia de segurança.

Ainda não é o jogo completo: personagens, mapa expandido, agricultura, mineração, áudio e conteúdo narrativo serão adicionados em etapas. Os gráficos desta base são provisórios.

## Executar
Abra este diretório no Godot 4.7.2 e pressione F6/F5 ou use Executar projeto.

## Controles
- Analógico esquerdo / WASD / setas: mover
- A / Enter / Espaço: interagir
- Y / I: salvar rapidamente
- Menu / Esc: pausar

## Salvamentos
Os dados ficam em `user://saves/`, fora da pasta do projeto. Há três espaços. Cada gravação usa arquivo temporário, validação JSON e substituição do arquivo principal, mantendo uma cópia `.bak` anterior quando possível.

## Próximas etapas
1. Arte pixelada definitiva, personagem e animações.
2. Mapa de Mulungu, trilhas, vila e NPCs.
3. Agricultura, inventário, coleta e ciclo de dia/noite.
4. Mina, missões, relações e áudio regional.
5. Testes de recuperação de salvamento e exportação Linux.

**Importante:** esta versão inicial foi escrita para Godot 4.7.2, mas precisa ser aberta e executada no Godot local para validar a integração com o ambiente da máquina.
