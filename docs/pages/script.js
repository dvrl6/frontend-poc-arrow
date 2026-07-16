(function () {
  "use strict";

  /* ------------------------------------------------------------------ *
   * Translations (English + Spanish). No external libraries.           *
   * Keys map to [data-i18n] (innerHTML) and [data-i18n-aria] (aria).   *
   * ------------------------------------------------------------------ */
  var translations = {
    en: {
      "hero.eyebrow": "Software Development Project",
      "hero.tagline": "A graph-based puzzle game where every arrow is rigid, every exit is deliberate.",
      "nav.overview": "Overview",
      "nav.workflow": "AI Workflow",
      "nav.highlights": "Technical Highlights",
      "nav.implementation": "Implementation",
      "nav.closing": "Closing",
      "lang.aria": "Switch language to Spanish",

      "s1.title": "Project Overview",
      "s1.lead": "Each level is a graph of nodes and edges covered by rigid arrows. Tapping an arrow attempts one atomic exit in its head direction: it either escapes the board entirely, or the move is rolled back. There is no partial movement, so every level is a question of <em>order</em> — which arrow can leave now so that the others eventually can too.",
      "o1.h": "Graph-Based Mechanics",
      "o1.p": "The board is a graph, not a grid of tiles: nodes joined by edges, with rigid multi-node arrows laid over them. Movement is a coordinate sweep from the arrow's head — clear path, the whole arrow slides off; blocked, the attempt is undone atomically.",
      "o2.h": "2D &amp; 3D Modes",
      "o2.p": "Flat 2D boards and multi-layer 3D boards viewed through an orbitable perspective camera. Both run on the same resolver — the extra dimension is a direction abstraction, not special-cased physics.",
      "o3.h": "Challenge System",
      "o3.p": "Three challenge types reuse campaign levels under new pressure: Time Attack, Move Limit, and Perfect Run. Their results live in separate storage and never touch campaign completion, progress sync, or the leaderboard.",
      "o4.h": "Progressive Difficulty",
      "o4.p": "30 levels: 15 generated rectangular boards, 5 figure silhouettes (heart, diamond, club, spade, crown), and 10 multi-layer 3D figures. Difficulty is <em>computed</em> from each level's structure — arrow count, blocked starts, bends, density, layers — and the level list is ordered by that score.",
      "o5.h": "Audio System",
      "o5.p": "An app-lifetime audio manager keeps one set of players alive across screens instead of rebuilding them per level. Music and effects negotiate focus so they duck rather than cut each other, and pause and resume with the app.",
      "o6.h": "Progress &amp; Leaderboards",
      "o6.p": "Progress is local-first: unlocks and best scores live on the device, so the game is fully playable offline. An optional account adds cloud sync that never discards a better local result, plus per-level leaderboards when signed in.",

      "s2.title": "AI Workflow Evolution",
      "s2.lead": "Nodus was built with an AI coding assistant, and the way the team worked <em>with</em> it changed as much as the game did. Every request fills a fixed-size <strong>context window</strong> — the text the model reads before it answers. The three stages below are about spending less of that window re-explaining the project, and more of it producing correct work.",
      "problem.label": "Why the project moved on",
      "win.label": "Why it stuck",
      "stage1.tag": "Stage 1",
      "stage1.h": "Prompt Engineering",
      "stage1.p": "Carefully worded one-off prompts. Each session re-explained the architecture, the constraints, and the history from scratch, inside the prompt itself.",
      "stage1.problem": "Context was rebuilt in full every time. Prompts grew unwieldy, facts drifted between sessions, and much of the window went to restating what the project already knew before any real work began.",
      "stage2.tag": "Stage 2",
      "stage2.h": "Spec-Driven Development",
      "stage2.p": "Work moved to written specifications: structured phase documents stating exactly what to build, which files were in scope, and which rules applied.",
      "stage2.problem": "Ambiguity and rework dropped, but each phase still carried a bespoke document duplicating the same baseline facts by hand. The shared knowledge lived nowhere permanent.",
      "stage3.tag": "Stage 3 · current",
      "stage3.h": "Harness Engineering",
      "stage3.p": "The project keeps a standing <code>harness/</code> directory: baseline context, active rules, pre- and post-implementation checklists, phase templates, and metrics. A new phase references that shared state instead of restating it — only the <em>delta</em> enters the window. The cost is upkeep: a changed decision must be edited there once, or future phases read a stale fact.",
      "stage3.win": "The baseline is written once and reused everywhere. Facts stay consistent, mistakes are logged rather than repeated, and the window is freed for implementation and review. This is the workflow the project runs on today.",

      "cw.kicker": "Diagram",
      "cw.title": "Anatomy of a Context Window",
      "cw.desc": "Each request draws on a limited budget of tokens, split between <strong>input</strong> (what the model must read first) and <strong>output</strong> (what it produces). The proportions below are illustrative, not measured — they show which parts are fixed cost, which the harness was built to shrink, and which are the payoff.",
      "cw.aria": "Diagram of a context window divided into input tokens and output tokens.",
      "cw.input_header": "Input tokens",
      "cw.input_sub": "What the model reads before answering",
      "cw.sys": "System instructions",
      "cw.sys.why": "Fixed cost on every request — the same rules apply regardless of task.",
      "cw.ctx": "Project context &amp; constraints",
      "cw.ctx.why": "Grows every time facts must be restated — the share the standing <code>harness/</code> directory exists to shrink.",
      "cw.spec": "Phase specification",
      "cw.spec.why": "The task-specific ask — the only input that should scale with the work, not with how many sessions came before.",
      "cw.output_header": "Output tokens",
      "cw.output_sub": "What the model generates in response",
      "cw.code": "Generated code",
      "cw.code.why": "The direct deliverable — the reason the request was made.",
      "cw.audit": "Audit reports &amp; tests",
      "cw.audit.why": "Verification evidence — the harness's post-implementation checklist requires it every phase.",
      "cw.note": "The window is finite: input and output compete for the same space. Reducing repeated input is what leaves more room for output.",

      "chart.kicker": "Chart",
      "chart.title": "Comparing the Three Techniques",
      "chart.illustrative": "illustrative",
      "chart.caption": "Each technique on three axes: how much of the window it spends on repeated setup, its token cost per phase, and the quality of its results. These scores are illustrative — they show the shape of the improvement, not measured token counts.",
      "chart.aria": "Illustrative grouped bar chart comparing prompt engineering, spec-driven development, and harness engineering across three axes: context-window impact, token usage, and quality of results.",
      "legend.context": "Context-window impact",
      "legend.tokens": "Token usage per phase",
      "legend.quality": "Quality of results",
      "chart.s1": "Prompt\nEngineering",
      "chart.s2": "Spec-Driven\nDevelopment",
      "chart.s3": "Harness\nEngineering",

      "s3.title": "Technical Highlights",
      "s3.lead": "Not just what the stack is, but why each piece earns its place.",
      "t1.h": "AWS EC2 Hosting",
      "t1.p": "The backend runs on an EC2 instance — a real, always-on server with full control over runtime and network, and a chance to operate cloud infrastructure directly rather than through a managed sandbox.",
      "t2.h": "Docker-Based Deployment",
      "t2.p": "A <code>Dockerfile</code> and <code>docker-compose.yml</code> start the API and its database with one command. The same image runs on a laptop and on EC2, removing \"works on my machine\" drift.",
      "t3.h": "Local / Cloud Flexibility",
      "t3.p": "The app is fully playable offline against local level data. Auth, cloud sync, and leaderboards are strictly additive — a network outage never blocks play.",
      "t4.h": "Flutter + Clean Architecture",
      "t4.p": "One Flutter codebase across platforms, organised Domain → Application → Infrastructure → Presentation per feature. A pure domain (no Flutter, HTTP, or storage imports) lets the game rules be unit-tested in isolation and reused unchanged across 2D and 3D.",
      "t5.h": "Node.js + NestJS + Prisma",
      "t5.p": "A NestJS API whose modular, dependency-injected structure mirrors the frontend's layering, with Prisma as the type-safe ORM and migration layer — a strongly-typed path from HTTP request to database and back.",
      "t6.h": "Graph-Based Game Engine",
      "t6.p": "No matrix, grid-cell, or tile model exists in the runtime. Levels are graphs; movement is a coordinate sweep resolved entirely in the domain layer. That one abstraction drives flat boards, figure silhouettes, and stacked 3D levels alike.",
      "t7.h": "30 Levels, Tool-Validated",
      "t7.p": "15 generated rectangular boards, 5 figure silhouettes, and 10 multi-layer 3D figures. A Node generator/validator checks every level for solvability, connectivity, and shape rules before it ships.",
      "t8.h": "Challenge Modes",
      "t8.p": "Time Attack, Move Limit, and Perfect Run layer over campaign levels via a scoring strategy pattern, with fully separate save state. A new challenge type means one new strategy — the core loop stays untouched.",
      "t9.h": "Backend-Driven Dynamic Levels",
      "t9.p": "The client can fetch extra playable levels from the backend (reserved numbers 1000+) and merge them in at runtime, so new content ships by seeding the database instead of rebuilding the app. The path is implemented end-to-end but still gated behind the <code>ENABLE_REMOTE_LEVELS</code> build flag, off by default. When on, the merge is offline-first: the 30 local levels stay authoritative and win any number conflict, and an absent backend falls back to the last cached remote batch.",

      "s_impl.title": "Technical Implementation",
      "s_impl.lead": "What each side of the stack owns, how the two relate, and the cross-cutting concerns applied to the backend.",
      "impl1.h": "Frontend Responsibility",
      "impl1.p": "The Flutter client owns all gameplay: the graph domain, movement resolution, rendering, audio, and local persistence. The domain layer stays pure Dart, so the rules deciding whether an arrow escapes or collides are unit-tested with no UI and no network.",
      "impl2.h": "Backend Responsibility",
      "impl2.p": "The NestJS API owns accounts, the level catalog, progress sync, and leaderboards — organised as <code>src/{domain, application, infrastructure, interfaces}</code>, with Prisma and Swagger docs at <code>/api/docs</code>. It never runs gameplay logic; that stays on the client.",
      "impl3.h": "How Frontend and Backend Relate",
      "impl3.p": "Strictly additive. Local levels are the offline source of truth; the client maps them to backend ids via <code>GET /levels</code>. Progress sync never discards a better local result, and leaderboard submission — authenticated only — is best-effort and non-blocking, so an absent backend never blocks local play.",
      "impl4.h": "Architecture Impact",
      "impl4.p": "Both repositories use Clean/hexagonal architecture. Business rules isolated from frameworks can be tested without booting a UI or database; adapters (Prisma repository, HTTP client, SharedPreferences) swap behind a port without touching a use case; and an adapter failure can't leak into the rules that decide correctness.",
      "impl5.h": "AOP — Three Cross-Cutting Concerns",
      "impl5.p": "NestJS interceptors, filters, and guards keep cross-cutting concerns out of business logic. Two are <strong>global</strong>: a logging &amp; performance interceptor wraps every handler, recording method/path/status/time with zero controller changes; an exception filter normalises any thrown error into one JSON shape. Security is <strong>per-route</strong>: a JWT guard protects progress, leaderboard submission, and admin endpoints, and a roles guard with <code>@Roles(ADMIN)</code> further restricts the admin-only level endpoints.",

      "flow.kicker": "Walkthrough",
      "flow.title": "Request Lifecycle: From Tap to Response",
      "flow.caption": "Submitting a leaderboard score — every layer the request crosses on both sides, and where each AOP aspect (cross-cutting concern) attaches along the way.",
      "flow.aop_label": "cross-cutting concern",
      "flow.frontend": "Frontend",
      "flow.backend": "Backend",
      "flow.s1.h": "Player action &rarr; domain use case",
      "flow.s1.p": "Completing a level runs <code>MoveArrowUseCase</code>/<code>GameSessionService</code> entirely on-device. The result goes to <code>SyncProgressUseCase</code>, which depends only on the <code>RemoteProgressRepository</code> port — not on HTTP.",
      "flow.s2.h": "Outbound adapter wraps the call",
      "flow.s2.p": "<code>HttpApiClient</code> — the port's implementation — builds the HTTP request.",
      "flow.s2.aop": "Frontend AOP: a <code>TokenProvider</code> callback attaches <code>Authorization: Bearer &lt;token&gt;</code>, so the use case never touches auth headers, and the single <code>_send</code> method wraps every failure into one <code>ApiException</code> shape.",
      "flow.s3.h": "Request reaches the backend gateway",
      "flow.s3.p": "<code>POST /leaderboard</code> arrives at <code>leaderboard.controller.ts</code> — the driving adapter, the only entry point the outside world may call.",
      "flow.s3.aop": "Backend AOP: <code>JwtAuthGuard</code> validates the bearer token per-route before the handler runs; <code>LoggingPerformanceInterceptor</code> starts timing globally.",
      "flow.s4.h": "Controller &rarr; use case &rarr; port",
      "flow.s4.p": "The controller validates the DTO and calls the use case, which depends only on the <code>LeaderboardRepository</code> port and <code>LeaderboardScorePolicy</code> — it has no idea Prisma, Postgres, or HTTP exist.",
      "flow.s5.h": "Driven adapter touches the database",
      "flow.s5.p": "<code>PrismaLeaderboardRepository</code> implements the port and is the only code that talks to Postgres. Swapping it for an in-memory fake in tests changes nothing above this layer.",
      "flow.s6.h": "Response leaves through the same gateway",
      "flow.s6.p": "The result bubbles back to the controller, which returns it as JSON.",
      "flow.s6.aop": "Backend AOP: the global <code>HttpExceptionFilter</code> catches anything thrown and normalises it, so no controller formats its own errors; <code>LoggingPerformanceInterceptor</code> logs <code>METHOD /path STATUS TIMEms</code> on the way out.",
      "flow.s7.h": "Frontend receives the result",
      "flow.s7.p": "<code>HttpApiClient</code> deserialises the response (or maps a failure to <code>ApiException</code>) and <code>SyncProgressUseCase</code> merges it into local state. Submission is best-effort — a failed backend never blocks local progress.",
      "flow.note": "Every use case in this chain calls only an interface/port — never a concrete adapter, never an AOP aspect. The aspects sit entirely at the two gateways (<code>interfaces/</code> on the backend, <code>HttpApiClient</code> on the frontend), which is exactly why they can be added or changed without touching a use case.",

      "s4.title": "Closing",
      "s4.lead": "Nodus began as a small graph-based puzzle prototype and grew into a full 2D and 3D game with an optional online backend — alongside a development workflow that matured beside it, from prompt engineering, to specs, to a harness. The game and the way it was made reflect the same idea: write the rules down once, keep them clean, reuse them everywhere. Thank you to <strong>Professor Carlos Alonso</strong> for the guidance throughout the course.",
      "link.backend": "Backend Repository",
      "link.frontend": "Frontend Repository",
      "link.lucid": "Lucidchart Diagram",
      "footer.text": "Nodus — Software Development Course Project",
      "footer.top": "Back to top ↑"
    },

    es: {
      "hero.eyebrow": "Proyecto de Desarrollo de Software",
      "hero.tagline": "Un juego de rompecabezas basado en grafos donde cada flecha es rígida y cada salida es deliberada.",
      "nav.overview": "Resumen",
      "nav.workflow": "Flujo de IA",
      "nav.highlights": "Aspectos Técnicos",
      "nav.implementation": "Implementación",
      "nav.closing": "Cierre",
      "lang.aria": "Cambiar idioma a inglés",

      "s1.title": "Resumen del Proyecto",
      "s1.lead": "Cada nivel es un grafo de nodos y aristas cubierto por flechas rígidas. Al tocar una flecha se intenta una salida atómica en la dirección de su punta: o escapa por completo del tablero, o el movimiento se revierte. No hay movimiento parcial, así que cada nivel es una cuestión de <em>orden</em>: qué flecha puede salir ahora para que las demás también puedan hacerlo después.",
      "o1.h": "Mecánica Basada en Grafos",
      "o1.p": "El tablero es un grafo, no una cuadrícula de casillas: nodos unidos por aristas, con flechas rígidas de varios nodos superpuestas. El movimiento es un barrido por coordenadas desde la punta de la flecha — con el camino libre, toda la flecha se desliza fuera; si está bloqueado, el intento se deshace de forma atómica.",
      "o2.h": "Modos 2D y 3D",
      "o2.p": "Tableros 2D planos y tableros 3D de varias capas vistos con una cámara en perspectiva orbitable. Ambos corren sobre el mismo resolutor — la dimensión adicional es una abstracción de dirección, no física de casos especiales.",
      "o3.h": "Sistema de Retos",
      "o3.p": "Tres tipos de reto reutilizan los niveles de campaña con nueva presión: Contrarreloj, Límite de Movimientos y Ronda Perfecta. Sus resultados viven en un almacenamiento aparte y nunca afectan la finalización de la campaña, la sincronización de progreso ni la tabla de clasificación.",
      "o4.h": "Dificultad Progresiva",
      "o4.p": "30 niveles: 15 tableros rectangulares generados, 5 siluetas de figuras (corazón, diamante, trébol, pica, corona) y 10 figuras 3D de varias capas. La dificultad se <em>calcula</em> a partir de la estructura de cada nivel — número de flechas, cuántas empiezan bloqueadas, curvas, densidad, capas — y la lista de niveles se ordena por esa puntuación.",
      "o5.h": "Sistema de Audio",
      "o5.p": "Un administrador de audio de por vida mantiene un único conjunto de reproductores activo entre pantallas en lugar de reconstruirlos en cada nivel. La música y los efectos negocian el foco para atenuarse en vez de cortarse entre sí, y se pausan y reanudan con la app.",
      "o6.h": "Progreso y Clasificaciones",
      "o6.p": "El progreso es local primero: los desbloqueos y las mejores puntuaciones viven en el dispositivo, así que el juego es totalmente jugable sin conexión. Una cuenta opcional añade sincronización en la nube que nunca descarta un mejor resultado local, además de clasificaciones por nivel al iniciar sesión.",

      "s2.title": "Evolución del Flujo de IA",
      "s2.lead": "Nodus se construyó con un asistente de programación de IA, y la forma en que el equipo trabajó <em>con</em> él cambió tanto como el propio juego. Cada solicitud llena una <strong>ventana de contexto</strong> de tamaño fijo — el texto que el modelo lee antes de responder. Las tres etapas siguientes tratan de gastar menos de esa ventana en volver a explicar el proyecto, y más en producir trabajo correcto.",
      "problem.label": "Por qué el proyecto avanzó",
      "win.label": "Por qué perduró",
      "stage1.tag": "Etapa 1",
      "stage1.h": "Ingeniería de Prompts",
      "stage1.p": "Prompts únicos redactados con cuidado. Cada sesión volvía a explicar desde cero la arquitectura, las restricciones y el historial, dentro del propio prompt.",
      "stage1.problem": "El contexto se reconstruía por completo cada vez. Los prompts se volvían inmanejables, los datos variaban entre sesiones y buena parte de la ventana se gastaba en repetir lo que el proyecto ya conocía antes de empezar el trabajo real.",
      "stage2.tag": "Etapa 2",
      "stage2.h": "Desarrollo Guiado por Especificaciones",
      "stage2.p": "El trabajo pasó a especificaciones escritas: documentos de fase estructurados que indicaban exactamente qué construir, qué archivos estaban en alcance y qué reglas aplicaban.",
      "stage2.problem": "La ambigüedad y el retrabajo bajaron, pero cada fase seguía llevando un documento a medida que duplicaba a mano los mismos datos de base. El conocimiento compartido no vivía en ningún lugar permanente.",
      "stage3.tag": "Etapa 3 · actual",
      "stage3.h": "Ingeniería de Harness",
      "stage3.p": "El proyecto mantiene un directorio <code>harness/</code> permanente: contexto de base, reglas activas, listas de verificación previas y posteriores a la implementación, plantillas de fase y métricas. Una fase nueva referencia ese estado compartido en vez de repetirlo — solo el <em>delta</em> entra en la ventana. El costo es el mantenimiento: una decisión que cambia debe editarse allí una vez, o las fases futuras leerán un dato desactualizado.",
      "stage3.win": "La base se escribe una vez y se reutiliza en todas partes. Los datos se mantienen consistentes, los errores se registran en vez de repetirse, y la ventana queda libre para la implementación y la revisión. Este es el flujo de trabajo con el que funciona el proyecto hoy.",

      "cw.kicker": "Diagrama",
      "cw.title": "Anatomía de una Ventana de Contexto",
      "cw.desc": "Cada solicitud parte de un presupuesto limitado de tokens, repartido entre <strong>entrada</strong> (lo que el modelo debe leer primero) y <strong>salida</strong> (lo que produce). Las proporciones son ilustrativas, no medidas — muestran qué partes son costo fijo, cuáles nació el harness para reducir y cuáles son la recompensa.",
      "cw.aria": "Diagrama de una ventana de contexto dividida en tokens de entrada y tokens de salida.",
      "cw.input_header": "Tokens de entrada",
      "cw.input_sub": "Lo que el modelo lee antes de responder",
      "cw.sys": "Instrucciones del sistema",
      "cw.sys.why": "Costo fijo en cada solicitud — las mismas reglas aplican sin importar la tarea.",
      "cw.ctx": "Contexto y restricciones del proyecto",
      "cw.ctx.why": "Crece cada vez que hay que repetir datos — la parte que el directorio <code>harness/</code> permanente existe para reducir.",
      "cw.spec": "Especificación de la fase",
      "cw.spec.why": "El encargo específico de la tarea — la única entrada que debería escalar con el trabajo, no con cuántas sesiones hubo antes.",
      "cw.output_header": "Tokens de salida",
      "cw.output_sub": "Lo que el modelo genera en respuesta",
      "cw.code": "Código generado",
      "cw.code.why": "El entregable directo — la razón por la que se hizo la solicitud.",
      "cw.audit": "Informes de auditoría y pruebas",
      "cw.audit.why": "Evidencia de verificación — la lista de verificación posterior a la implementación del harness la exige en cada fase.",
      "cw.note": "La ventana es finita: la entrada y la salida compiten por el mismo espacio. Reducir la entrada repetida es lo que deja más lugar para la salida.",

      "chart.kicker": "Gráfico",
      "chart.title": "Comparación entre las Tres Técnicas",
      "chart.illustrative": "ilustrativo",
      "chart.caption": "Cada técnica en tres ejes: cuánto de la ventana gasta en preparación repetida, su costo en tokens por fase y la calidad de sus resultados. Estas puntuaciones son ilustrativas — muestran la forma de la mejora, no recuentos de tokens medidos.",
      "chart.aria": "Gráfico ilustrativo de barras agrupadas que compara la ingeniería de prompts, el desarrollo guiado por especificaciones y la ingeniería de harness en tres ejes: impacto en la ventana de contexto, uso de tokens y calidad de los resultados.",
      "legend.context": "Impacto en la ventana de contexto",
      "legend.tokens": "Uso de tokens por fase",
      "legend.quality": "Calidad de los resultados",
      "chart.s1": "Ingeniería\nde Prompts",
      "chart.s2": "Guiado por\nEspecificaciones",
      "chart.s3": "Ingeniería\nde Harness",

      "s3.title": "Aspectos Técnicos",
      "s3.lead": "No solo qué es el stack, sino por qué cada pieza se gana su lugar.",
      "t1.h": "Alojamiento en AWS EC2",
      "t1.p": "El backend se ejecuta en una instancia EC2 — un servidor real y siempre activo con control total sobre el entorno de ejecución y la red, y la oportunidad de operar infraestructura en la nube directamente en vez de a través de un entorno gestionado.",
      "t2.h": "Despliegue con Docker",
      "t2.p": "Un <code>Dockerfile</code> y un <code>docker-compose.yml</code> arrancan la API y su base de datos con un solo comando. La misma imagen corre en una laptop y en EC2, eliminando la deriva de \"funciona en mi máquina\".",
      "t3.h": "Flexibilidad Local / Nube",
      "t3.p": "La app es totalmente jugable sin conexión con datos de niveles locales. La autenticación, la sincronización en la nube y las clasificaciones son estrictamente adicionales — una caída de red nunca bloquea el juego.",
      "t4.h": "Flutter + Arquitectura Limpia",
      "t4.p": "Una sola base de código Flutter para varias plataformas, organizada como Dominio → Aplicación → Infraestructura → Presentación por funcionalidad. Un dominio puro (sin imports de Flutter, HTTP ni almacenamiento) permite probar las reglas del juego de forma aislada y reutilizarlas sin cambios entre 2D y 3D.",
      "t5.h": "Node.js + NestJS + Prisma",
      "t5.p": "Una API NestJS cuya estructura modular con inyección de dependencias refleja las capas del frontend, con Prisma como ORM y capa de migraciones con tipado seguro — un camino fuertemente tipado desde la petición HTTP hasta la base de datos y de vuelta.",
      "t6.h": "Motor de Juego Basado en Grafos",
      "t6.p": "No existe ningún modelo de matriz, celda de cuadrícula ni casilla en el runtime. Los niveles son grafos; el movimiento es un barrido por coordenadas resuelto por completo en la capa de dominio. Esa única abstracción impulsa por igual tableros planos, siluetas de figuras y niveles 3D apilados.",
      "t7.h": "30 Niveles, Validados por Herramienta",
      "t7.p": "15 tableros rectangulares generados, 5 siluetas de figuras y 10 figuras 3D de varias capas. Un generador/validador en Node revisa cada nivel en cuanto a resolubilidad, conectividad y reglas de forma antes de publicarlo.",
      "t8.h": "Modos de Reto",
      "t8.p": "Contrarreloj, Límite de Movimientos y Ronda Perfecta se superponen a los niveles de campaña mediante un patrón de estrategia para la puntuación, con estado de guardado totalmente separado. Un nuevo tipo de reto significa una nueva estrategia — el bucle principal queda intacto.",
      "t9.h": "Niveles Dinámicos desde el Backend",
      "t9.p": "El cliente puede descargar niveles jugables adicionales desde el backend (números reservados 1000+) y fusionarlos en tiempo de ejecución, de modo que el contenido nuevo se publica sembrando la base de datos en lugar de recompilando la app. El camino está implementado de extremo a extremo, pero aún depende del flag de compilación <code>ENABLE_REMOTE_LEVELS</code>, desactivado por defecto. Al activarlo, la fusión es offline-first: los 30 niveles locales siguen siendo la autoridad y ganan cualquier conflicto de número, y un backend ausente recurre al último lote remoto en caché.",

      "s_impl.title": "Implementación Técnica",
      "s_impl.lead": "De qué es responsable cada lado del stack, cómo se relacionan y qué concerns transversales se aplican en el backend.",
      "impl1.h": "Responsabilidad del Frontend",
      "impl1.p": "El cliente Flutter posee todo el juego: el dominio del grafo, la resolución de movimiento, el renderizado, el audio y la persistencia local. La capa de dominio se mantiene en Dart puro, de modo que las reglas que deciden si una flecha escapa o choca se prueban sin interfaz ni red.",
      "impl2.h": "Responsabilidad del Backend",
      "impl2.p": "La API NestJS posee las cuentas, el catálogo de niveles, la sincronización del progreso y las clasificaciones — organizada como <code>src/{domain, application, infrastructure, interfaces}</code>, con Prisma y documentación Swagger en <code>/api/docs</code>. Nunca ejecuta lógica de juego; eso queda del lado del cliente.",
      "impl3.h": "Cómo se Relacionan Frontend y Backend",
      "impl3.p": "Estrictamente aditiva. Los niveles locales son la fuente de verdad sin conexión; el cliente los mapea a los ids del backend mediante <code>GET /levels</code>. La sincronización de progreso nunca descarta un mejor resultado local, y el envío a la tabla de clasificación — solo autenticado — es best-effort y no bloqueante, así que un backend ausente nunca bloquea el juego local.",
      "impl4.h": "Impacto de la Arquitectura",
      "impl4.p": "Ambos repositorios usan arquitectura limpia/hexagonal. Las reglas de negocio aisladas de los frameworks pueden probarse sin levantar una interfaz o una base de datos; los adaptadores (repositorio Prisma, cliente HTTP, SharedPreferences) se sustituyen detrás de un puerto sin tocar un caso de uso; y un fallo de adaptador no puede filtrarse a las reglas que deciden la corrección.",
      "impl5.h": "AOP — Tres Concerns Transversales",
      "impl5.p": "Los interceptores, filtros y guards de NestJS mantienen los concerns transversales fuera de la lógica de negocio. Dos son <strong>globales</strong>: un interceptor de registro y rendimiento envuelve cada manejador, registrando método/ruta/estado/tiempo sin cambios en los controladores; un filtro de excepciones normaliza cualquier error lanzado en una única forma JSON. La seguridad es <strong>por ruta</strong>: un guard JWT protege el progreso, el envío a la tabla de clasificación y los endpoints de administrador, y un guard de roles con <code>@Roles(ADMIN)</code> restringe además los endpoints de nivel exclusivos para administradores.",

      "flow.kicker": "Recorrido",
      "flow.title": "Ciclo de Vida de una Petición: del Toque a la Respuesta",
      "flow.caption": "Enviar un puntaje a la tabla de clasificación — cada capa que atraviesa la petición en ambos lados, y dónde se engancha cada aspecto AOP (concern transversal) en el camino.",
      "flow.aop_label": "concern transversal",
      "flow.frontend": "Frontend",
      "flow.backend": "Backend",
      "flow.s1.h": "Acción del jugador &rarr; caso de uso de dominio",
      "flow.s1.p": "Completar un nivel ejecuta <code>MoveArrowUseCase</code>/<code>GameSessionService</code> enteramente en el dispositivo. El resultado pasa a <code>SyncProgressUseCase</code>, que depende únicamente del puerto <code>RemoteProgressRepository</code>, no de HTTP.",
      "flow.s2.h": "El adaptador de salida envuelve la llamada",
      "flow.s2.p": "<code>HttpApiClient</code> — la implementación del puerto — construye la petición HTTP.",
      "flow.s2.aop": "AOP en el frontend: un callback <code>TokenProvider</code> adjunta <code>Authorization: Bearer &lt;token&gt;</code>, así el caso de uso nunca toca los encabezados de autenticación, y el único método <code>_send</code> envuelve cada fallo en una sola forma de <code>ApiException</code>.",
      "flow.s3.h": "La petición llega al gateway del backend",
      "flow.s3.p": "<code>POST /leaderboard</code> llega a <code>leaderboard.controller.ts</code> — el adaptador conductor, el único punto de entrada que el mundo exterior puede invocar.",
      "flow.s3.aop": "AOP en el backend: <code>JwtAuthGuard</code> valida el token portador por ruta antes de que se ejecute el manejador; <code>LoggingPerformanceInterceptor</code> comienza a cronometrar de forma global.",
      "flow.s4.h": "Controlador &rarr; caso de uso &rarr; puerto",
      "flow.s4.p": "El controlador valida el DTO y llama al caso de uso, que depende únicamente del puerto <code>LeaderboardRepository</code> y de <code>LeaderboardScorePolicy</code> — no tiene idea de que existen Prisma, Postgres o HTTP.",
      "flow.s5.h": "El adaptador conducido toca la base de datos",
      "flow.s5.p": "<code>PrismaLeaderboardRepository</code> implementa el puerto y es el único código que habla con Postgres. Sustituirlo por un falso en memoria en las pruebas no cambia nada por encima de esta capa.",
      "flow.s6.h": "La respuesta sale por el mismo gateway",
      "flow.s6.p": "El resultado sube de vuelta hasta el controlador, que lo devuelve como JSON.",
      "flow.s6.aop": "AOP en el backend: el filtro global <code>HttpExceptionFilter</code> captura cualquier error lanzado y lo normaliza, así ningún controlador escribe su propio formato de error; <code>LoggingPerformanceInterceptor</code> registra <code>METHOD /path STATUS TIMEms</code> al salir.",
      "flow.s7.h": "El frontend recibe el resultado",
      "flow.s7.p": "<code>HttpApiClient</code> deserializa la respuesta (o mapea un fallo a <code>ApiException</code>) y <code>SyncProgressUseCase</code> lo fusiona con el estado local. El envío es best-effort — un backend caído nunca bloquea el progreso local.",
      "flow.note": "Cada caso de uso de esta cadena solo llama a una interfaz/puerto — nunca a un adaptador concreto, nunca a un aspecto AOP. Los aspectos viven enteramente en los dos gateways (<code>interfaces/</code> en el backend, <code>HttpApiClient</code> en el frontend), que es exactamente por qué pueden agregarse o cambiarse sin tocar un caso de uso.",

      "s4.title": "Cierre",
      "s4.lead": "Nodus empezó como un pequeño prototipo de rompecabezas basado en grafos y creció hasta convertirse en un juego completo 2D y 3D con un backend en línea opcional — junto a un flujo de desarrollo que maduró a su lado, desde la ingeniería de prompts, a las especificaciones, hasta un harness. El juego y la forma en que se hizo reflejan la misma idea: escribe las reglas una vez, mantenlas limpias y reutilízalas en todas partes. Gracias al <strong>Profesor Carlos Alonso</strong> por la guía a lo largo del curso.",
      "link.backend": "Repositorio del Backend",
      "link.frontend": "Repositorio del Frontend",
      "link.lucid": "Diagrama de Lucidchart",
      "footer.text": "Nodus — Proyecto del Curso de Desarrollo de Software",
      "footer.top": "Volver arriba ↑"
    }
  };

  var STORAGE_KEY = "nodus-lang";
  var currentLang = "en";

  function safeGet(key) {
    try {
      return window.localStorage.getItem(key);
    } catch (e) {
      return null;
    }
  }

  function safeSet(key, value) {
    try {
      window.localStorage.setItem(key, value);
    } catch (e) {
      /* localStorage unavailable (private mode / file restrictions) — ignore */
    }
  }

  function applyLanguage(lang) {
    var dict = translations[lang] || translations.en;
    currentLang = lang;
    document.documentElement.lang = lang;

    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      var key = el.getAttribute("data-i18n");
      if (dict[key] !== undefined) {
        el.innerHTML = dict[key];
      }
    });

    document.querySelectorAll("[data-i18n-aria]").forEach(function (el) {
      var key = el.getAttribute("data-i18n-aria");
      if (dict[key] !== undefined) {
        el.setAttribute("aria-label", dict[key]);
      }
    });

    var toggleLabel = document.getElementById("langToggleLabel");
    if (toggleLabel) {
      // Show the language you can switch TO.
      toggleLabel.textContent = lang === "en" ? "ES" : "EN";
    }

    safeSet(STORAGE_KEY, lang);
    drawChart();
  }

  // --- Language toggle wiring ---
  var langToggle = document.getElementById("langToggle");
  if (langToggle) {
    langToggle.addEventListener("click", function () {
      applyLanguage(currentLang === "en" ? "es" : "en");
    });
  }

  // --- Smooth scroll for in-page nav links ---
  document.querySelectorAll('a[href^="#"]').forEach(function (link) {
    link.addEventListener("click", function (e) {
      var targetId = link.getAttribute("href").slice(1);
      var target = document.getElementById(targetId);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: "smooth", block: "start" });
      }
    });
  });

  // --- Section reveal on scroll ---
  var revealTargets = document.querySelectorAll(
    ".overview-card, .stage-card, .tech-card, .link-card, .visual-block"
  );
  revealTargets.forEach(function (el) {
    el.classList.add("reveal");
  });

  if ("IntersectionObserver" in window) {
    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15 }
    );
    revealTargets.forEach(function (el) {
      observer.observe(el);
    });
  } else {
    revealTargets.forEach(function (el) {
      el.classList.add("is-visible");
    });
  }

  /* ------------------------------------------------------------------ *
   * Technique comparison chart (Canvas). Illustrative scores per stage *
   * across three axes: context-window impact, token usage, and        *
   * quality of results. Separate from the context-window anatomy      *
   * diagram above — this chart compares the three techniques, not the *
   * composition of a single request.                                  *
   * ------------------------------------------------------------------ */
  var canvas = document.getElementById("workflowCanvas");
  var ctx = canvas && canvas.getContext ? canvas.getContext("2d") : null;

  // Illustrative only — not measured token counts. Higher = more impact/
  // cost for context/tokens; higher = better for quality.
  var stages = [
    { key: "chart.s1", context: 85, tokens: 80, quality: 55 },
    { key: "chart.s2", context: 60, tokens: 65, quality: 75 },
    { key: "chart.s3", context: 25, tokens: 35, quality: 92 }
  ];

  function cssVar(name, fallback) {
    var v = getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    return v || fallback;
  }

  function drawChart() {
    if (!ctx) {
      return;
    }
    var dict = translations[currentLang] || translations.en;

    var dpr = window.devicePixelRatio || 1;
    var cssWidth = canvas.clientWidth || 900;
    var cssHeight = 420;
    canvas.width = cssWidth * dpr;
    canvas.height = cssHeight * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, cssWidth, cssHeight);

    var textColor = cssVar("--text", "#eef0f6");
    var mutedColor = cssVar("--text-muted", "#a6acc2");
    var contextColor = cssVar("--accent", "#6d8dff");
    var tokensColor = cssVar("--accent-warm", "#ffb26b");
    var qualityColor = cssVar("--accent-2", "#7ee8c8");
    var metrics = [
      { key: "context", color: contextColor },
      { key: "tokens", color: tokensColor },
      { key: "quality", color: qualityColor }
    ];

    var padL = 52;
    var padR = 32;
    var padT = 28;
    var padB = 78;
    var chartW = cssWidth - padL - padR;
    var chartH = cssHeight - padT - padB;
    var baseY = padT + chartH;
    var groupW = chartW / stages.length;
    var barGap = 6;
    var barW = Math.min(64, (groupW * 0.7 - barGap * (metrics.length - 1)) / metrics.length);

    // Gridlines + percentage axis
    ctx.font = "11px -apple-system, Segoe UI, Roboto, sans-serif";
    ctx.textAlign = "right";
    [0, 25, 50, 75, 100].forEach(function (pct) {
      var y = baseY - (pct / 100) * chartH;
      ctx.globalAlpha = 0.14;
      ctx.strokeStyle = mutedColor;
      ctx.beginPath();
      ctx.moveTo(padL, y);
      ctx.lineTo(padL + chartW, y);
      ctx.stroke();
      ctx.globalAlpha = 1;
      ctx.fillStyle = mutedColor;
      ctx.fillText(pct, padL - 8, y + 4);
    });

    stages.forEach(function (stage, i) {
      var groupX = padL + i * groupW + groupW / 2;
      var groupWidth = metrics.length * barW + (metrics.length - 1) * barGap;
      var startX = groupX - groupWidth / 2;

      metrics.forEach(function (metric, mi) {
        var value = stage[metric.key];
        var barH = (value / 100) * chartH;
        var barX = startX + mi * (barW + barGap);
        var barY = baseY - barH;

        ctx.fillStyle = metric.color;
        ctx.fillRect(barX, barY, barW, barH);

        ctx.textAlign = "center";
        ctx.fillStyle = textColor;
        ctx.font = "bold 11px -apple-system, Segoe UI, Roboto, sans-serif";
        ctx.fillText(value, barX + barW / 2, barY - 6);
      });

      // Stage name (supports \n)
      ctx.fillStyle = textColor;
      ctx.font = "13px -apple-system, Segoe UI, Roboto, sans-serif";
      var label = (dict[stage.key] || "").split("\n");
      label.forEach(function (line, li) {
        ctx.fillText(line, groupX, baseY + 22 + li * 15);
      });
    });

    ctx.textAlign = "left";
  }

  // --- Initial language + first draw ---
  var stored = safeGet(STORAGE_KEY);
  applyLanguage(stored === "es" || stored === "en" ? stored : "en");

  // --- Redraw chart on resize / theme change ---
  var resizeTimer;
  window.addEventListener("resize", function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(drawChart, 120);
  });

  if (window.matchMedia) {
    var scheme = window.matchMedia("(prefers-color-scheme: dark)");
    if (scheme.addEventListener) {
      scheme.addEventListener("change", drawChart);
    }
  }
})();
