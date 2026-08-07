/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { Student, Turma } from "./types";

export interface QuickAction {
  id: string;
  category: "positivo" | "negativo";
  title: string;
  description: string;
}

export const QUICK_ACTIONS: QuickAction[] = [
  {
    id: "qa_1",
    category: "positivo",
    title: "Apoio a Colegas",
    description: "Ajudou colegas de classe com extrema atenção, paciência e empatia durante as tarefas difíceis."
  },
  {
    id: "qa_2",
    category: "positivo",
    title: "Liderança Construtiva",
    description: "Liderou a equipe do projeto com proatividade, organizando as tarefas de forma justa e alegre."
  },
  {
    id: "qa_3",
    category: "positivo",
    title: "Excelência Pedagógica",
    description: "Entregou todas as atividades pedagógicas com dedicação excepcional e criatividade acima do comum."
  },
  {
    id: "qa_4",
    category: "positivo",
    title: "Cuidado Ambiental",
    description: "Zelou voluntariamente pela limpeza e organização da sala de aula e do refeitório comum."
  },
  {
    id: "qa_5",
    category: "positivo",
    title: "Superação Pessoal",
    description: "Demonstrou persistência brilhante ao superar dificuldades em uma matéria que considerava impossível."
  },
  {
    id: "qa_6",
    category: "negativo",
    title: "Tumulto de Aula",
    description: "Fez barulho excessivo, gritos ou brincadeiras inconvenientes que impediram o andamento da aula."
  },
  {
    id: "qa_7",
    category: "negativo",
    title: "Falta de Organização",
    description: "Deixou de trazer todos os livros, cadernos de matéria, lápis ou caneta para a atividade de avaliação."
  },
  {
    id: "qa_8",
    category: "negativo",
    title: "Agressividade / Falta de Educação",
    description: "Xingou colega de classe ou agiu com grosseria e má vontade ao ser solicitado a colaborar num trabalho."
  },
  {
    id: "qa_9",
    category: "negativo",
    title: "Desprezo aos Espaços comuns",
    description: "Jogou papéis de bala, embalagem no chão ou rabiscou as paredes da carteira intencionalmente."
  }
];

export const INITIAL_TURMAS: Turma[] = [
  {
    id: "turma_2ds_pami_a",
    nome: "2DS_PAMI_A",
    criadoEm: "2026-05-28T10:00:00Z",
    pontosProfessor: 850,
    students: [
      {
        id: "stud_a_1",
        name: "ANDRÉ DE PAULA OLIVEIRA",
        points: 350,
        avatarSeed: "andre",
        history: [
          {
            id: "rec_a_1_1",
            date: "2026-05-25",
            description: "Auxiliou os colegas no desenvolvimento do projeto mobile com grande boa vontade.",
            points: 150,
            justification: "Atitude colaborativa voluntária de grande valia para o grupo.",
            feedback: "Excelente! Sua ajuda acelerou o progresso dos companheiros e elevou sua Aura para o patamar do Coelho Celestial."
          },
          {
            id: "rec_a_1_2",
            date: "2026-05-27",
            description: "Entregou as tarefas de PAMI completas antes do prazo final estabelecido.",
            points: 200,
            justification: "Demonstração de pontualidade e dedicação acadêmica marcantes.",
            feedback: "Seu compromisso ilumina sua trajetória escolar! Continue focado e polindo sua Aura Celestial."
          }
        ]
      },
      {
        id: "stud_a_2",
        name: "ARTHUR MIGUEL DE SOUZA",
        points: -120,
        avatarSeed: "arthur",
        history: [
          {
            id: "rec_a_2_1",
            date: "2026-05-26",
            description: "Conversas paralelas persistentes durante a explicação de lógica de programação.",
            points: -120,
            justification: "Prejuízo à própria atenção e ao foco dos colegas circundantes.",
            feedback: "Lembre-se de silenciar o ambiente para que as grandes ideias se formem. Evite que as distrações sombrias limitem seu potencial cósmico."
          }
        ]
      },
      {
        id: "stud_a_3",
        name: "BRUNO VILAÇA DE OLIVEIRA",
        points: 50,
        avatarSeed: "bruno",
        history: [
          {
            id: "rec_a_3_1",
            date: "2026-05-27",
            description: "Emprestou material didático e ajudou na arrumação do laboratório da escola.",
            points: 50,
            justification: "Pró-atividade simples e cuidado com as ferramentas de aprendizado comuns.",
            feedback: "Pequenos atos de generosidade geram grandes repercussões harmônicas. Continue assim!"
          }
        ]
      },
      {
        id: "stud_a_4",
        name: "CLARICE GUIMARÃES SILVANO",
        points: 1200,
        avatarSeed: "clarice",
        history: [
          {
            id: "rec_a_4_1",
            date: "2026-05-20",
            description: "Desenvolveu um protótipo de aplicativo inovador focado no auxílio a estudantes com TDAH.",
            points: 800,
            justification: "Contribuição técnica e social brilhante no âmbito escolar e comunitário.",
            feedback: "Genialidade e empatia andam juntas! Seu protótipo irradia a energia vigorosa e nobre do Cavalo Celestial."
          },
          {
            id: "rec_a_4_2",
            date: "2026-05-24",
            description: "Liderou a equipe na modelagem de telas do projeto acadêmico de PAMI.",
            points: 400,
            justification: "Excelente coordenação e distribuição equilibrada de metas entre os colegas.",
            feedback: "Sua liderança inspira! Ao guiar seus colegas com leveza, você atrai o respeito e o brilho místico cósmico."
          }
        ]
      },
      {
        id: "stud_a_5",
        name: "DANIEL BARROS CRUZ",
        points: -250,
        avatarSeed: "daniel",
        history: [
          {
            id: "rec_a_5_1",
            date: "2026-05-22",
            description: "Faltas de atenção generalizada e uso inadequado do celular em momentos práticos do laboratório.",
            points: -150,
            justification: "Uso indevido de telas que diminui o ritmo do desenvolvimento prático individual.",
            feedback: "Guarde as telas virtuais para sintonizar sua atenção com a explicação. Concentre sua energia no código real para progredir."
          },
          {
            id: "rec_a_5_2",
            date: "2026-05-25",
            description: "Desatenção ao chamado do professor para envio das resoluções das telas de Android.",
            points: -100,
            justification: "Atraso simples nas entregas práticas semanais requeridas.",
            feedback: "O tempo flui rápido no laboratório. Estabeleça metas internas para afastar os efeitos sombrios do Galo Sombrio."
          }
        ]
      },
      {
        id: "stud_a_6",
        name: "DIEGO LUCAS PEREIRA LEITE",
        points: 0,
        avatarSeed: "diego",
        history: []
      },
      {
        id: "stud_a_7",
        name: "FELIPE ALBANO DE OLIVEIRA PEREIRA",
        points: 450,
        avatarSeed: "felipealbano",
        history: [
          {
            id: "rec_a_7_1",
            date: "2026-05-24",
            description: "Apresentação impecável sobre APIs REST de localização no ecossistema mobile Android.",
            points: 300,
            justification: "Seminário inovador demonstrando amplo domínio de pesquisa autônoma.",
            feedback: "Parabéns pela fantástica desenvoltura técnica! Conhecimento compartilhado eleva a Aura de todos na turma."
          },
          {
            id: "rec_a_7_2",
            date: "2026-05-26",
            description: "Apoiou um colega que estava com extrema dúvida no posicionamento de componentes na tela.",
            points: 150,
            justification: "Colaboração harmoniosa que estimula o trabalho solidário.",
            feedback: "Sua paciência ajuda a desfazer os nós das dificuldades alheias. Excelente atitude de Coelho Celestial!"
          }
        ]
      },
      {
        id: "stud_a_8",
        name: "FELIPE MÜLLER PONCE",
        points: 80,
        avatarSeed: "felipemuller",
        history: [
          {
            id: "rec_a_8_1",
            date: "2026-05-27",
            description: "Comportamento exemplar de recolhimento dos computadores e fios no término do laboratório.",
            points: 80,
            justification: "Zelo importante pelos recursos escolares comuns compartilhados.",
            feedback: "Manter a ordem onde estudamos atrai serenidade mental. continue contribuindo para esse clima agradável de paz."
          }
        ]
      },
      {
        id: "stud_a_9",
        name: "FELIPE SOARES DA SILVA",
        points: -480,
        avatarSeed: "felipesoares",
        history: [
          {
            id: "rec_a_9_1",
            date: "2026-05-21",
            description: "Recusa em colaborar no desenvolvimento prático do grupo após solicitações insistentes dos colegas.",
            points: -280,
            justification: "Falta de espírito coletivo e cooperação em um projeto integralmente em equipe.",
            feedback: "Trabalhar em conjunto fortalece nossas pontes mentais. A reclusão e a recusa atraem energias densas. Tente cooperar na próxima jornada!"
          },
          {
            id: "rec_a_9_2",
            date: "2026-05-24",
            description: "Demonstrou desrespeito verbal ao ser alertado por colega sobre prazos de desenvolvimento.",
            points: -200,
            justification: "Falta de polidez nas interações sociais de cobrança legítima.",
            feedback: "A agressividade turva nossa percepção mística. Trate a todos com o devido respeito para encontrar o alinhamento de calmaria."
          }
        ]
      },
      {
        id: "stud_a_10",
        name: "FELIPE SOUSA SINICIO ABIB",
        points: 150,
        avatarSeed: "felipesousa",
        history: [
          {
            id: "rec_a_10_1",
            date: "2026-05-26",
            description: "Desenvolveu um guia passo-a-passo detalhado para configuração do Vite na máquina de estudo.",
            points: 150,
            justification: "Produção espontânea de documentação didática útil para a comunidade escolar.",
            feedback: "Iniciativa fantástica! Ao simplificar caminhos para os outros, você desperta os dons engenhosos do Rato Celestial."
          }
        ]
      },
      {
        id: "stud_a_11",
        name: "GABRIEL AUGUSTO DA SILVA ALVES",
        points: 600,
        avatarSeed: "gabrielaugusto",
        history: [
          {
            id: "rec_a_11_1",
            date: "2026-05-23",
            description: "Engajou brilhantemente a classe em debate ético sobre o uso respeitoso de Inteligência Artificial.",
            points: 400,
            justification: "Mediação exemplar e instigação de reflexões profundas de cidadania.",
            feedback: "Sua fluência filosófica e respeito às opiniões alheias emanam a sensibilidade e equilíbrio da Cabra Celestial."
          },
          {
            id: "rec_a_11_2",
            date: "2026-05-25",
            description: "Acolheu colegas de outros grupos que estavam com dúvidas na instalação de emuladores.",
            points: 200,
            justification: "Atitude colaborativa intergrupos estimulando a unificação da sala.",
            feedback: "Zelar pelo sucesso geral da turma é uma qualidade maravilhosa. Sua Aura brilha intensamente!"
          }
        ]
      },
      {
        id: "stud_a_12",
        name: "GABRIEL RIBEIRO DE LIMA MENEGHINI PAIVA",
        points: -350,
        avatarSeed: "gabrielribeiro",
        history: [
          {
            id: "rec_a_12_1",
            date: "2026-05-24",
            description: "Brincadeiras inapropriadas utilizando o cabo de rede para perturbar colegas no laboratório.",
            points: -200,
            justification: "Desvio do uso correto dos equipamentos pedagógicos que geram ruídos de atenção.",
            feedback: "Os cabos conectam nosso saber, não devem ser usados para distração física. Evite sintonizar com vibrações turbulentas."
          },
          {
            id: "rec_a_12_2",
            date: "2026-05-26",
            description: "Atraso relevante no retorno do intervalo, reduzindo o tempo de mentoria coletiva.",
            points: -150,
            justification: "Descumprimento sem aviso prévio dos horários escolares estipulados.",
            feedback: "Zele pelo seu próprio tempo e pelo dos outros. A pontualidade é amparada pela disciplina essencial do Galo Sombrio quando negligenciada."
          }
        ]
      },
      {
        id: "stud_a_13",
        name: "GABRIELA FALEIROS MOREIRA",
        points: 2100,
        avatarSeed: "gabrielafaleiros",
        history: [
          {
            id: "rec_a_13_1",
            date: "2026-05-18",
            description: "Desenvolveu com perfeição absoluta todas as conexões de API móvel do projeto escolar.",
            points: 1000,
            justification: "Excelência técnica incomparável e entrega de qualidade profissional renomada.",
            feedback: "Incrível! Suas conexões integradas com maestria absoluta e precisão expandiram sua energia cósmica para o nível de Macaco Celestial!"
          },
          {
            id: "rec_a_13_2",
            date: "2026-05-22",
            description: "Conquistou o prêmio principal em maratona estadual de programação júnior.",
            points: 1100,
            justification: "Conquista científica notória e exaltação do nome da escola na comunidade externa.",
            feedback: "Suas conquistas transcendem as paredes do colégio! O brilho de sua mente irradia as virtudes brilhantes e místicas cósmicas."
          }
        ]
      },
      {
        id: "stud_a_14",
        name: "HAYSLAN PIRES GONCALVES FILHO",
        points: 10,
        avatarSeed: "hayslan",
        history: [
          {
            id: "rec_a_14_1",
            date: "2026-05-26",
            description: "Esqueceu as instruções básicas e precisou de ajuda repetida, mas demonstrou paciência ao ouvir.",
            points: 10,
            justification: "Pequena dedicação em se reestruturar com calma frente às dúvidas do projeto.",
            feedback: "O recomeço paciente é nobre. Mantenha os ouvidos abertos e continue firme na busca pelo alinhamento favorável."
          }
        ]
      },
      {
        id: "stud_a_15",
        name: "HEITOR COSTA NEVES",
        points: 320,
        avatarSeed: "heitor",
        history: [
          {
            id: "rec_a_15_1",
            date: "2026-05-25",
            description: "Criou belíssimas ilustrações visuais para enriquecer o design das interfaces da equipe.",
            points: 320,
            justification: "Desenvolvimento estético de excelência para fins de apresentação funcional do projeto.",
            feedback: "Sua sensibilidade artística trouxe vida ao código árido! Continue expressando sua verdade e polindo sua Aura."
          }
        ]
      },
      {
        id: "stud_a_16",
        name: "HENRIQUE AGUIAR FERREIRA",
        points: -150,
        avatarSeed: "henriqueaguiar",
        history: [
          {
            id: "rec_a_16_1",
            date: "2026-05-26",
            description: "Sair repetidamente da sala antes da finalização dos exercícios sem justificativa plausível.",
            points: -150,
            justification: "Interrupção do fluxo de trabalho prático e desatenção às combinatórias pedagógicas.",
            feedback: "Evite saídas dispersivas. Permanecer focado na conclusão das suas metas afasta o assédio sutil das energias escuras."
          }
        ]
      },
      {
        id: "stud_a_17",
        name: "HENRIQUE ALVES RIBEIRO",
        points: 550,
        avatarSeed: "henriquealves",
        history: [
          {
            id: "rec_a_17_1",
            date: "2026-05-24",
            description: "Identificou e consertou bugs críticos que bloqueavam a compilação do código de três grupos colegas.",
            points: 400,
            justification: "Salvamento técnico heróico de projetos alheios demonstrando enorme solidariedade e aptidão.",
            feedback: "Fantástico! Solucionar mistérios técnicos para os colegas eleva sua vibração e expressa a arte da Cabra Celestial."
          },
          {
            id: "rec_a_17_2",
            date: "2026-05-27",
            description: "Zelou pela arrumação das cadeiras no fim da mentoria com sorriso caloroso e presteza.",
            points: 155,
            justification: "Zelo pelo ambiente amável de estudo solidário no laboratório móvel.",
            feedback: "Pequenos brilhos de gentileza silenciosa constroem o templo da harmonia coletiva. Continue assim!"
          }
        ]
      },
      {
        id: "stud_a_18",
        name: "HENRIQUE CAVALINI PEREIRA",
        points: 0,
        avatarSeed: "henriquecavalini",
        history: []
      },
      {
        id: "stud_a_19",
        name: "JOÃO VÍCTOR BRÁS FERREIRA",
        points: 1650,
        avatarSeed: "joaobras",
        history: [
          {
            id: "rec_a_19_1",
            date: "2026-05-15",
            description: "Desenvolveu com perfeição e de forma 100% autônoma um banco de dados local Room completo.",
            points: 950,
            justification: "Inovação tecnológica que simplifica a arquitetura mobile do aplicativo do grupo.",
            feedback: "Uma verdadeira façanha arquitetônica! Sua resiliência em códigos densos desperta a força do Boi Celestial místico."
          },
          {
            id: "rec_a_19_2",
            date: "2026-05-22",
            description: "Criou tutoriais de vídeos rápidos excelentes orientando a sala sobre deploy do emulador.",
            points: 700,
            justification: "Criação de mídias de suporte pedagógico inovadoras facilitando o ritmo geral do PAMI.",
            feedback: "Incrível contribuição audiovisual! Gravar ajuda aos outros espalha a sabedoria cósmica pelos horizontes da escola."
          }
        ]
      },
      {
        id: "stud_a_20",
        name: "JOÃO VÍCTOR SILVA RODRIGUES",
        points: -90,
        avatarSeed: "joao_rodrigues",
        history: [
          {
            id: "rec_a_20_1",
            date: "2026-05-25",
            description: "Se atrasou na entrega inicial da arquitetura do projeto de desenvolvimento prático.",
            points: -90,
            justification: "Planejamento inadequado do tempo prejudicou as tarefas iniciais das metas do grupo.",
            feedback: "Não se perca nos labirintos da procrastinação. Organize suas trilhas de estudo e restabeleça o equilíbrio de sua Aura."
          }
        ]
      }
    ]
  },
  {
    id: "turma_2ds_pami_b",
    nome: "2DS_PAMI_B",
    criadoEm: "2026-05-28T11:00:00Z",
    pontosProfessor: 1100,
    students: [
      {
        id: "stud_b_1",
        name: "KAUAN CAMPOS SILVA",
        points: 400,
        avatarSeed: "kauan",
        history: [
          {
            id: "rec_b_1_1",
            date: "2026-05-24",
            description: "Demonstrou foco admirável e dedicação contínua na estruturação das classes de dados Android.",
            points: 250,
            justification: "Foco primoroso no refinamento da arquitetura técnica de desenvolvimento.",
            feedback: "Excelente! Sua dedicação firme estruturou caminhos firmes e refinou sua essência Celestial."
          },
          {
            id: "rec_b_1_2",
            date: "2026-05-26",
            description: "Explicou calmamente para novos companheiros a mecânica de versionamento Git.",
            points: 150,
            justification: "Compartilhamento útil e acolhedor de metodologias ágeis de versão.",
            feedback: "Que belo passo rumo ao progresso mútuo! A mentoria de código eleva sua sabedoria do Coelho Celestial."
          }
        ]
      },
      {
        id: "stud_b_2",
        name: "LIRA TERRA FAGUNDES VAISMENOS",
        points: 1800,
        avatarSeed: "lira",
        history: [
          {
            id: "rec_b_2_1",
            date: "2026-05-19",
            description: "Criou e editou um documentário maravilhoso integrando desenvolvimento de software e sustentabilidade urbana.",
            points: 1000,
            justification: "Inovação sociocultural interdisciplinar de enorme impacto intelectual e artístico.",
            feedback: "Trabalho inspirador, unindo a urgência ambiental ao brilho artístico da Cabra Celestial! Sua dedicação é monumental."
          },
          {
            id: "rec_b_2_2",
            date: "2026-05-23",
            description: "Organizou as metodologias de design thinking em dinâmicas que animaram profundamente os colegas.",
            points: 800,
            justification: "Liderança alegre, empática e focada na promoção da saúde mental e engajamento da sala.",
            feedback: "Liderar estimulando sorrisos e união é um dom celestial puro! Você irradia os alinhamentos grandiosos do Boi Celestial."
          }
        ]
      },
      {
        id: "stud_b_3",
        name: "LUAN SHINJI DOMINIQUE KUMAZAWA",
        points: -110,
        avatarSeed: "luan",
        history: [
          {
            id: "rec_b_3_1",
            date: "2026-05-25",
            description: "Perdeu o debate técnico inicial do PAMI devido a atrasos persistentes desnecessários.",
            points: -110,
            justification: "Perda de oportunidade didática decorrente de falta de comprometimento com horários.",
            feedback: "A perda de foco retarda o progresso do aprendizado. Desperte sua pontualidade para afastar influências sombrias temporárias."
          }
        ]
      },
      {
        id: "stud_b_4",
        name: "LUCAS PEIXOTO AGUIAR",
        points: 50,
        avatarSeed: "lucaspeixoto",
        history: [
          {
            id: "rec_b_4_1",
            date: "2026-05-27",
            description: "Ajudou a carregar as caixas de computadores no início da dinâmica acadêmica do laboratório.",
            points: 50,
            justification: "Ajuda física espontânea de presteza comunitária no pátio escolar.",
            feedback: "A colaboração física e o entusiasmo auxiliam na formação de um espaço coletivo próspero. Continue cooperando!"
          }
        ]
      },
      {
        id: "stud_b_5",
        name: "MANUEL CORRÊA VIANA MUÑOZ",
        points: -350,
        avatarSeed: "manuel",
        history: [
          {
            id: "rec_b_5_1",
            date: "2026-05-23",
            description: "Atrapalhou o ensaio geral da dinâmica mobile gritando intermitentemente piadas em volumes excessivos.",
            points: -200,
            justification: "Tumulto deliberado e perturbação da harmonia e respeito devidos no laboratório.",
            feedback: "O humor é precioso, mas nunca deve abafar a voz do colega ou o foco de desenvolvimento. Restabeleça seu centramento."
          },
          {
            id: "rec_b_5_2",
            date: "2026-05-26",
            description: "Apresentou recusa ao receber feedbacks construtivos dos monitores da classe de forma brusca.",
            points: -150,
            justification: "Falta de autocrítica construtiva atrapalha o avanço pedagógico harmonioso.",
            feedback: "Ouvir críticas construtivas abre portas para a sabedoria. Afaste as sombras desarmoniosas e acolha o conhecimento."
          }
        ]
      },
      {
        id: "stud_b_6",
        name: "MANUELA CORREIA LIMA",
        points: 1400,
        avatarSeed: "manuela",
        history: [
          {
            id: "rec_b_6_1",
            date: "2026-05-20",
            description: "Elaborou a estrutura lógica interna das rotas e telas mobile com performance excepcional comprovada.",
            points: 900,
            justification: "Excelência técnica na arquitetura de software móvel.",
            feedback: "Sua determinação indomável na criação científica inspira! Uma performance digna da realeza do Cavalo Celestial."
          },
          {
            id: "rec_b_6_2",
            date: "2026-05-24",
            description: "Ministrou apoio focado e acolhedor a duas alunas novatas que necessitavam de reforço didático.",
            points: 500,
            justification: "Empatia e responsabilidade social exemplar na classe.",
            feedback: "Excelente abraço solidário de boas-vindas na sala! Suas atitudes refinadas iluminam generosamente sua Aura."
          }
        ]
      },
      {
        id: "stud_b_7",
        name: "MARCOS FILIPE DA SILVA SANTOS",
        points: 0,
        avatarSeed: "marcosfilipe",
        history: []
      },
      {
        id: "stud_b_8",
        name: "MARINA SOARES SILVA",
        points: 850,
        avatarSeed: "marina",
        history: [
          {
            id: "rec_b_8_1",
            date: "2026-05-22",
            description: "Desenvolveu com imensa sensibilidade visual o guia de cores e branding inclusivo do projeto da turma.",
            points: 850,
            justification: "Contribuição artística marcante de acessibilidade e acolhimento cromático no PAMI.",
            feedback: "Sua arte inclusiva aquece a alma escolar! O capricho absoluto irradia a generosidade pura do Boi Celestial."
          }
        ]
      },
      {
        id: "stud_b_9",
        name: "MATHEUS FELIPE DE MARTINO",
        points: -600,
        avatarSeed: "matheusfelipe",
        history: [
          {
            id: "rec_b_9_1",
            date: "2026-05-21",
            description: "Atitude rude e xingamentos graves contra colega durante desentendimento na divisão de tarefas.",
            points: -350,
            justification: "Hostilidade severa desrespeitando o código de conduta comportamental escolar.",
            feedback: "A discórdia desmedida envenena as correntes de Aura da turma. Pare de alimentar o Cabra Sombrio e busque o entendimento fraterno."
          },
          {
            id: "rec_b_9_2",
            date: "2026-05-25",
            description: "Deixou de entregar as documentações estruturadas de design na data estipulada cumulativamente.",
            points: -250,
            justification: "Falta de responsabilidade e dedicação aos acordos letivos semanais estabelecidos.",
            feedback: "Metas inacabadas bloqueiam os canais de sabedoria escolar. Fortaleça sua organização para restaurar seu brilho celular."
          }
        ]
      },
      {
        id: "stud_b_10",
        name: "MATHEUS PEREIRA CRUZ",
        points: 210,
        avatarSeed: "matheuspereira",
        history: [
          {
            id: "rec_b_10_1",
            date: "2026-05-26",
            description: "Pesquisa minuciosa de bibliografia relevante para dar suporte técnico às decisões de arquitetura PAMI.",
            points: 210,
            justification: "Empenho positivo na condução de estudos autônomos para sustentar a equipe.",
            feedback: "Fabulosa demonstração de dedicação acadêmica profunda! O Galo Celestial canta as glórias das mentes focadas."
          }
        ]
      },
      {
        id: "stud_b_11",
        name: "MIGUEL ARCANJO RIBEIRO",
        points: 2700,
        avatarSeed: "miguelarcanjo",
        history: [
          {
            id: "rec_b_11_1",
            date: "2026-05-15",
            description: "Desenvolveu um mecanismo autônomo e altamente otimizado de cache móvel que virou referência na sala.",
            points: 1200,
            justification: "Inovação tecnológica digna de destaque profissional extraordinário na engenharia escolar.",
            feedback: "Fenomenal! Sua performance e maestria tecnológica despertaram a energia exuberante do Macaco Celestial místico!"
          },
          {
            id: "rec_b_11_2",
            date: "2026-05-22",
            description: "Criou e conduziu um plantão de dúvidas voluntário de programação Java/Kotlin em três fins de semana.",
            points: 1500,
            justification: "Impacto solidário gigantesco e fomento magnífico ao progresso prático da comunidade escolar.",
            feedback: "Incrível demonstração de altruísmo e generosidade sublime! Você brilha como sol sagrado nos céus do Farmômetro!"
          }
        ]
      },
      {
        id: "stud_b_12",
        name: "MIGUEL DE ABREU FERREIRA PEREIRA",
        points: -80,
        avatarSeed: "miguelabreu",
        history: [
          {
            id: "rec_b_12_1",
            date: "2026-05-27",
            description: "Esqueceu as chaves do laboratório de estudos e atrasou temporariamente a dinâmica de grupo.",
            points: -80,
            justification: "Descuido simples de organização pessoal comprometendo fluxos operacionais letivos.",
            feedback: "Atente-se aos cuidados do ambiente que compartilhamos. Pequenas posturas preventivas previnem desarmonias sombrias."
          }
        ]
      },
      {
        id: "stud_b_13",
        name: "NICOLAS RODRIGUES FERNANDES",
        points: 950,
        avatarSeed: "nicolas",
        history: [
          {
            id: "rec_b_13_1",
            date: "2026-05-24",
            description: "Criou um repositório comunitário de templates front-end fantásticos para acelerar o deploy da turma.",
            points: 950,
            justification: "Inovação social e técnica coletiva de altíssima relevância altruísta.",
            feedback: "Formidável idealização técnica! Compartilhar suas ferramentas acelera o caminho para o místico do Porco Celestial."
          }
        ]
      },
      {
        id: "stud_b_14",
        name: "RAFAEL VICTOR FELICIANO FERREIRA",
        points: 30,
        avatarSeed: "rafaelvictor",
        history: [
          {
            id: "rec_b_14_1",
            date: "2026-05-27",
            description: "Participação ativa e comentários enriquecedores e respeitosos no debate sobre éticas em TI.",
            points: 30,
            justification: "Contribuição produtiva simples estimulando o diálogo respeitoso na sala.",
            feedback: "Sua palavra sincera e pacífica ajuda a construir nossa ponte cósmica do conhecimento. Muito bem!"
          }
        ]
      },
      {
        id: "stud_b_15",
        name: "RAFAELA DIAS RUFINO",
        points: -400,
        avatarSeed: "rafaeladias",
        history: [
          {
            id: "rec_b_15_1",
            date: "2026-05-24",
            description: "Reclamações públicas persistentes em volumes estidentes que desvalorizavam o esforço legítimo da classe.",
            points: -250,
            justification: "Fomentou um ambiente negativo que minou o entusiasmo e o foco de cocriação do grupo.",
            feedback: "Em vez de cultivar a insatisfação, tente verbalizar propostas construtivas de evolução. Purifique sua Aura interna."
          },
          {
            id: "rec_b_15_2",
            date: "2026-05-26",
            description: "Atrasos na volta do almoço e recusa em assumir metas simples da entrega final de PAMI.",
            points: -150,
            justification: "Atrasos recorrentes com recusas comportamentais desnecessárias às obrigações do colégio.",
            feedback: "O dever ampara o progresso cósmico da nossa equipe. Assuma suas metas com fé e restaure a luz de seu alinhamento."
          }
        ]
      },
      {
        id: "stud_b_16",
        name: "SAMUEL MONTEZ OLIVEIRA",
        points: 650,
        avatarSeed: "samuelmontez",
        history: [
          {
            id: "rec_b_16_1",
            date: "2026-05-24",
            description: "Produziu uma excelente apresentação multimídia explicando arquitetura cliente-servidor para leigos.",
            points: 650,
            justification: "Habilidade didática e comunicativa de alto nível para fins pedagógicos letivos.",
            feedback: "Que clareza exemplar de pensamento! Explicar o complexo com candura irradia a beleza pura da Cabra Celestial."
          }
        ]
      },
      {
        id: "stud_b_17",
        name: "THAYNÁ FERREIRA CARDOSO",
        points: 20,
        avatarSeed: "thayna",
        history: [
          {
            id: "rec_b_17_1",
            date: "2026-05-27",
            description: "Acolheu colega recém-integrado ao grupo repassando os combinados e o andamento do projeto.",
            points: 20,
            justification: "Inclusão social carinhosa e hospitaleira facilitando a integração saudável do colega.",
            feedback: "Sua hospitalidade alegra os corações escolares. Gestos puros sempre sintonizam sua Aura com a calmaria."
          }
        ]
      },
      {
        id: "stud_b_18",
        name: "VICTOR HUGO DOS SANTOS DE JESUS",
        points: -180,
        avatarSeed: "victorhugo",
        history: [
          {
            id: "rec_b_18_1",
            date: "2026-05-26",
            description: "Deixou de entregar os escopos funcionais do código na dinâmica avaliativa.",
            points: -180,
            justification: "Falta de responsabilidade com prazos e entregas letivas essenciais programadas.",
            feedback: "O cumprimento das metas é a base da sua construção de conhecimento. Organize suas ferramentas para retornar à luz cósmica."
          }
        ]
      },
      {
        id: "stud_b_19",
        name: "VINICIUS EDUARDO ALVES DE OLIVEIRA",
        points: 1200,
        avatarSeed: "viniciuseduardo",
        history: [
          {
            id: "rec_b_19_1",
            date: "2026-05-21",
            description: "Arquitetou uma API impecável integrando o projeto móvel do grupo a serviços de mapa.",
            points: 800,
            justification: "Contribuição tecnológica refinada e avançada para o escopo mobile da classe de PAMI.",
            feedback: "Sua dedicação desbravando sistemas de mapas irradia a destreza fantástica do Cavalo Celestial! Esforço estupendo."
          },
          {
            id: "rec_b_19_2",
            date: "2026-05-25",
            description: "Ajudou pacientemente a sanar impedimentos de código Kotlin de cinco colegas da sala.",
            points: 400,
            justification: "Solidariedade técnica inspiradora fortalecendo o conhecimento pedagógico geral.",
            feedback: "Compartilhar sabedoria técnica é o maior multiplicador de harmonia em nossa escola. Sua brilhante Aura orgulha a todos!"
          }
        ]
      },
      {
        id: "stud_b_20",
        name: "YURI FÁVARO DA SILVA",
        points: -50,
        avatarSeed: "yuri",
        history: [
          {
            id: "rec_b_20_1",
            date: "2026-05-26",
            description: "Esqueceu as anotações do projeto de PAMI, necessitando refazer parte do planejamento.",
            points: -50,
            justification: "Esquecimento simples que afetou de leve o cronograma de desenvolvimento individual.",
            feedback: "Atenção mística à sua trilha! Organize seus papéis e cadernos para evitar perdas de progresso na sua jornada cósmica."
          }
        ]
      }
    ]
  }
];
