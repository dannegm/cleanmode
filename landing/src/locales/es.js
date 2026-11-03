export default {
    meta: {
        title: 'Clean Mode — Bloquea el teclado y la pantalla de tu Mac mientras la limpias',
        description:
            'App gratuita y de código abierto para macOS que bloquea el teclado, los atajos y los gestos y pone la pantalla en negro, para limpiar tu Mac sin apagarla (cualquier tecla o movimiento del mouse la despertaría) y sin tocar nada por accidente.',
    },
    common: { copy: 'Copiar', copied: 'Copiado' },
    nav: { features: 'Funciones', how: 'Cómo funciona', faq: 'Preguntas', download: 'Descargar', donate: 'Donar' },
    hero: {
        title1: 'Limpia tu Mac.',
        title2: 'Sin tocar nada por accidente.',
        subtitle:
            'Clean Mode bloquea el teclado, los atajos y los gestos y pone la pantalla en negro, para que limpies todo sin apagar el Mac (cualquier tecla o movimiento del mouse lo despertaría de inmediato) y sin abrir apps ni cambiar ajustes.',
        download: 'Descargar para macOS',
        github: 'Ver en GitHub',
        meta: 'Gratis y de código abierto · macOS 13+ · Apple Silicon e Intel',
        shotAlt: 'Pantalla de bloqueo de Clean Mode: pantalla negra con una escoba y un botón para mantener presionado',
    },
    problem: {
        title: 'Limpiar un Mac es más riesgoso de lo que parece',
        intro: 'Al limpiar el teclado se presionan todas las teclas. Al limpiar el trackpad se disparan gestos. En unos segundos puedes:',
        items: [
            'Escribir tonterías en la app que esté en primer plano',
            'Activar atajos: salir, cerrar, borrar, Mission Control…',
            'Cambiar el volumen, el brillo o un ajuste',
            'Suspender el Mac o cerrar la sesión',
        ],
        noOff: {
            title: 'Y tampoco puedes simplemente apagarla',
            text: 'Suspender el Mac o apagar la pantalla no sirve: al presionar cualquier tecla o mover el mouse, se vuelve a encender. Apagarlo del todo es lento y te deja limpiando una pantalla oscura donde casi no se ve el polvo.',
        },
        outro: 'Clean Mode deja la pantalla encendida y en negro, para que veas exactamente dónde ya limpiaste.',
    },
    features: {
        title: 'Todo bloqueado. Nada de qué preocuparte.',
        items: [
            {
                icon: 'keyboard',
                title: 'Teclado bloqueado',
                text: 'Se ignora cada tecla, incluidas las de multimedia, volumen y brillo.',
            },
            {
                icon: 'shortcuts',
                title: 'Atajos y gestos',
                text: '⌘Tab, ⌘Q, forzar salida, el Dock y la barra de menú se desactivan, además de casi todos los gestos del trackpad.',
            },
            {
                icon: 'screen',
                title: 'Pantalla negra en cada monitor',
                text: 'Una capa negra en todas tus pantallas hace que las manchas y el polvo se vean fácil.',
            },
            {
                icon: 'cursor',
                title: 'Un cursor que puedes seguir',
                text: 'El cursor real se oculta y lo reemplaza un círculo con una estela suave.',
            },
            {
                icon: 'awake',
                title: 'La pantalla no se apaga',
                text: 'La pantalla se queda encendida y en negro, así nada la despierta ni la suspende mientras limpias.',
            },
            {
                icon: 'languages',
                title: '13 idiomas',
                text: 'English, Español, 中文, हिन्दी, العربية, Français, Português, Русский, বাংলা, 日本語, Deutsch, Italiano y 한국어, según tu sistema.',
            },
        ],
    },
    how: {
        title: 'Tres pasos',
        steps: [
            {
                title: 'Ábrela',
                text: 'Todo se bloquea al instante. La primera vez, una breve guía te pide el permiso de Accesibilidad que exige macOS.',
            },
            {
                title: 'Limpia',
                text: 'Pasa el paño por el teclado, el trackpad y la pantalla. Nada de lo que toques hará algo.',
            },
            {
                title: 'Sal cuando termines',
                text: 'Mantén presionado el botón, presiona ⌘Q tres veces o deja que el temporizador la cierre.',
            },
        ],
        shotAlt: 'Ventana de bienvenida de Clean Mode que explica el permiso de Accesibilidad',
    },
    exits: {
        title: 'No puedes quedarte atrapado',
        subtitle: 'Tres salidas independientes. Si la app se cierra por un error, el bloqueo desaparece con ella.',
        holdLabel: 'Mantén presionado para salir',
        hold: { title: 'Mantén el botón', text: 'Mantenlo presionado 3 segundos.' },
        keys: { title: 'Presiona ⌘Q tres veces', text: 'El conteo se reinicia si haces una pausa.' },
        timer: { title: 'Espera al temporizador', text: 'Se cierra sola a los 15 minutos (configurable).' },
    },
    privacy: {
        title: 'Privada por diseño',
        text: 'Clean Mode necesita el permiso de Accesibilidad solo para poder descartar tus teclas.',
        items: [
            'Nunca registra, guarda ni envía lo que escribes',
            'La única tecla que vigila es ⌘Q, para contar la salida de emergencia',
            'Sin peticiones de red ni analíticas',
            'Código abierto con licencia MIT: puedes leerlo',
            'Quita el permiso cuando quieras en Ajustes del Sistema',
        ],
    },
    download: {
        title: 'Descarga Clean Mode',
        text: 'Gratis y de código abierto. Sin cuenta, sin rastreo.',
        button: 'Descargar para macOS',
        source: 'Compilar desde el código',
        requirements: 'macOS 13 o posterior · Universal (Apple Silicon e Intel)',
        gatekeeperTitle: 'La primera vez que la abras',
        gatekeeperText:
            'Las versiones no están notarizadas (eso requiere una cuenta de pago de Apple Developer), así que macOS muestra un aviso una vez:',
        steps: [
            'Abre Ajustes del Sistema → Privacidad y seguridad.',
            'Baja hasta el mensaje sobre Clean Mode y pulsa Abrir igualmente.',
        ],
        orTerminal: 'O ejecuta esto en la Terminal:',
        updates: 'Al actualizar, vuelve a pedir el permiso de Accesibilidad.',
        checksum: 'Verifica tu descarga con el archivo .sha256 que acompaña a cada versión.',
    },
    support: {
        title: 'Apoya Clean Mode',
        text: 'Es gratis y de código abierto. Si te evitó alguna tecla accidental, una pequeña donación ayuda a mantenerlo.',
        button: 'Donar con PayPal',
        note: 'Totalmente opcional, ¡y gracias! La app muestra un recordatorio pequeño y descartable cada 10 limpiezas; puedes apagarlo para siempre.',
    },
    faq: {
        title: 'Preguntas',
        items: [
            {
                q: '¿Por qué no simplemente apagar el Mac o suspenderlo?',
                a: 'Porque se vuelve a encender: cualquier tecla o movimiento del mouse o del trackpad despierta la pantalla, y apagarlo del todo es lento y te deja limpiando una pantalla oscura donde casi no se ve el polvo. Clean Mode mantiene todo bloqueado y la pantalla encendida.',
            },
            {
                q: '¿Por qué necesita el permiso de Accesibilidad?',
                a: 'macOS solo deja que una app intercepte el teclado si le das ese permiso. Clean Mode lo usa para descartar cada tecla mientras limpias. No lee ni guarda lo que escribes.',
            },
            {
                q: '¿Por qué macOS me avisa al abrirla?',
                a: 'La app es gratuita y está firmada ad hoc, no notarizada por Apple (eso requiere una cuenta de desarrollador de pago). Usa Abrir igualmente en Ajustes del Sistema → Privacidad y seguridad, o el comando de la Terminal de arriba.',
            },
            {
                q: '¿Volverá a pedir el permiso después de actualizar?',
                a: 'Sí. Como la firma es ad hoc, macOS ve cada versión como una app distinta. Quita la entrada anterior en Accesibilidad con el botón − y activa la nueva.',
            },
            {
                q: '¿Hay algo que no pueda bloquear?',
                a: 'El botón de encendido / tecla Touch ID (una pulsación larga sigue apagando el Mac) y cerrar la tapa. Además, algunos gestos del sistema en el trackpad pueden colarse en ciertas versiones de macOS.',
            },
            {
                q: '¿Funciona en Macs con Intel?',
                a: 'Sí. La compilación es universal: Apple Silicon e Intel, macOS 13 o posterior.',
            },
            {
                q: '¿Registra lo que escribo?',
                a: 'No. Cada tecla se descarta. La app no hace peticiones de red ni tiene analíticas.',
            },
        ],
    },
    footer: {
        license: 'Licencia MIT',
        report: 'Reportar un problema',
        donate: 'Donar',
        notAffiliated: 'Sin afiliación con Apple. Mac y macOS son marcas de Apple Inc.',
    },
};
