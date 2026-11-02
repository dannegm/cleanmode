import Foundation

/// Localización de la app. Mismos 13 idiomas que el proyecto `tabs`; inglés por defecto.
///
/// El idioma se infiere del sistema: se recorre la lista de idiomas preferidos y se usa el primero
/// que tengamos, comparando solo el código principal (`pt-BR` → `pt`, `zh-Hans-CN` → `zh`).
/// Si ninguno está soportado, se usa inglés. Para probar: `--lang=ja` o `CLEANMODE_LANG=ja`.
enum L10n {
    static let supported = ["en", "es", "zh", "hi", "ar", "fr", "pt", "ru", "bn", "ja", "de", "it", "ko"]
    static let rightToLeft: Set<String> = ["ar"]

    static let current: String = {
        var override: String?
        for arg in CommandLine.arguments where arg.hasPrefix("--lang=") {
            override = String(arg.dropFirst("--lang=".count))
        }
        if override == nil { override = ProcessInfo.processInfo.environment["CLEANMODE_LANG"] }
        if let override, supported.contains(override.lowercased()) { return override.lowercased() }
        return resolve(Locale.preferredLanguages)
    }()

    static var isRTL: Bool { rightToLeft.contains(current) }

    static func resolve(_ preferred: [String]) -> String {
        for tag in preferred {
            let code = (tag.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map(String.init) ?? "").lowercased()
            if supported.contains(code) { return code }
        }
        return "en"
    }

    static func t(_ key: String) -> String {
        tables[current]?[key] ?? tables["en"]?[key] ?? key
    }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }

    /// Plural sencillo: `<base>.one` (1), `<base>.two` (2, si el idioma lo define) y `<base>.other` (%d).
    static func plural(_ base: String, _ n: Int) -> String {
        if n == 1 { return t("\(base).one") }
        if n == 2, let two = tables[current]?["\(base).two"] { return two }
        return t("\(base).other", n)
    }

    private static let tables: [String: [String: String]] = [
        "en": en, "es": es, "zh": zh, "hi": hi, "ar": ar, "fr": fr, "pt": pt,
        "ru": ru, "bn": bn, "ja": ja, "de": de, "it": it, "ko": ko,
    ]

    // `{keys}` se reemplaza por las teclas ⌘ y Q (estilo kbd) en la posición que cada idioma necesite.

    private static let en: [String: String] = [
        "lock.title": "Cleaning mode",
        "lock.blocked": "Keyboard, shortcuts and gestures are locked: nothing will trigger while you clean.",
        "lock.tips": "Use a soft, dry microfiber cloth. Don't press hard or apply liquid directly.",
        "lock.hold": "Hold to exit",
        "lock.autoClose": "Auto-closes in %@",
        "lock.footer": "{keys} ×%d to exit with the keyboard",
        "lock.subtitle.one": "Press {keys} 1 more time to exit",
        "lock.subtitle.other": "Press {keys} %d more times to exit",
        "onb.title": "Before you start",
        "onb.subtitle": "Clean Mode needs Accessibility permission to lock your keyboard while you clean. It never reads or stores what you type.",
        "onb.step1": "Click the button below.",
        "onb.step2": "Turn on Clean Mode in Accessibility:",
        "onb.waiting": "Waiting for permission…",
        "onb.stale": "macOS still doesn't allow locking. Turn Clean Mode off and on again.",
        "onb.button": "Open System Settings",
        "onb.hint": "Already on? Remove it with − and add it again with +.",
        "onb.ready": "All set",
        "onb.starting": "Starting cleaning mode…",
    ]

    private static let es: [String: String] = [
        "lock.title": "Modo limpieza",
        "lock.blocked": "Teclado, atajos y gestos bloqueados: nada se activará mientras limpias.",
        "lock.tips": "Usa un paño de microfibra suave y seco. No presiones ni apliques líquido directo.",
        "lock.hold": "Mantén presionado para salir",
        "lock.autoClose": "Cierre automático en %@",
        "lock.footer": "{keys} ×%d para salir con el teclado",
        "lock.subtitle.one": "Presiona {keys} 1 vez más para salir",
        "lock.subtitle.other": "Presiona {keys} %d veces más para salir",
        "onb.title": "Antes de empezar",
        "onb.subtitle": "Clean Mode necesita el permiso de Accesibilidad para bloquear tu teclado mientras limpias. No lee ni guarda lo que escribes.",
        "onb.step1": "Presiona el botón de abajo.",
        "onb.step2": "Activa Clean Mode en Accesibilidad:",
        "onb.waiting": "Esperando el permiso…",
        "onb.stale": "macOS aún no permite el bloqueo. Desactiva y vuelve a activar Clean Mode.",
        "onb.button": "Abrir Ajustes del Sistema",
        "onb.hint": "¿Ya aparece activado? Quítalo con − y vuelve a agregarlo con +.",
        "onb.ready": "Todo listo",
        "onb.starting": "Iniciando el modo limpieza…",
    ]

    private static let zh: [String: String] = [
        "lock.title": "清洁模式",
        "lock.blocked": "键盘、快捷键和手势已锁定：清洁时不会触发任何操作。",
        "lock.tips": "请使用柔软干燥的超细纤维布。不要用力按压，也不要直接涂抹液体。",
        "lock.hold": "长按退出",
        "lock.autoClose": "%@后自动关闭",
        "lock.footer": "{keys} ×%d 用键盘退出",
        "lock.subtitle.one": "再按 1 次 {keys} 即可退出",
        "lock.subtitle.other": "再按 %d 次 {keys} 即可退出",
        "onb.title": "开始之前",
        "onb.subtitle": "Clean Mode 需要“辅助功能”权限，才能在清洁时锁定键盘。它不会读取或保存你输入的内容。",
        "onb.step1": "点按下方的按钮。",
        "onb.step2": "在“辅助功能”中打开 Clean Mode：",
        "onb.waiting": "正在等待授权…",
        "onb.stale": "macOS 仍不允许锁定。请先关闭再重新打开 Clean Mode。",
        "onb.button": "打开系统设置",
        "onb.hint": "已经打开了？请用 − 移除，再用 + 重新添加。",
        "onb.ready": "一切就绪",
        "onb.starting": "正在启动清洁模式…",
    ]

    private static let hi: [String: String] = [
        "lock.title": "सफ़ाई मोड",
        "lock.blocked": "कीबोर्ड, शॉर्टकट और जेस्चर लॉक हैं: सफ़ाई के दौरान कुछ भी ट्रिगर नहीं होगा।",
        "lock.tips": "मुलायम, सूखे माइक्रोफ़ाइबर कपड़े का इस्तेमाल करें। ज़ोर से न दबाएँ और सीधे तरल न लगाएँ।",
        "lock.hold": "बाहर निकलने के लिए दबाए रखें",
        "lock.autoClose": "%@ में अपने आप बंद होगा",
        "lock.footer": "{keys} ×%d से कीबोर्ड द्वारा बाहर निकलें",
        "lock.subtitle.one": "बाहर निकलने के लिए {keys} एक बार और दबाएँ",
        "lock.subtitle.other": "बाहर निकलने के लिए {keys} %d बार और दबाएँ",
        "onb.title": "शुरू करने से पहले",
        "onb.subtitle": "सफ़ाई के दौरान आपका कीबोर्ड लॉक करने के लिए Clean Mode को एक्सेसिबिलिटी की अनुमति चाहिए। यह आप जो टाइप करते हैं उसे न पढ़ता है, न सहेजता है।",
        "onb.step1": "नीचे दिए गए बटन पर क्लिक करें।",
        "onb.step2": "एक्सेसिबिलिटी में Clean Mode चालू करें:",
        "onb.waiting": "अनुमति की प्रतीक्षा है…",
        "onb.stale": "macOS अभी भी लॉक करने की अनुमति नहीं दे रहा। Clean Mode को बंद करके फिर से चालू करें।",
        "onb.button": "सिस्टम सेटिंग्स खोलें",
        "onb.hint": "पहले से चालू है? − से हटाएँ और + से दोबारा जोड़ें।",
        "onb.ready": "सब तैयार है",
        "onb.starting": "सफ़ाई मोड शुरू हो रहा है…",
    ]

    private static let ar: [String: String] = [
        "lock.title": "وضع التنظيف",
        "lock.blocked": "لوحة المفاتيح والاختصارات والإيماءات مقفلة: لن يُنفَّذ أي شيء أثناء التنظيف.",
        "lock.tips": "استخدم قطعة قماش ناعمة وجافة من الألياف الدقيقة. لا تضغط بقوة ولا تضع سائلًا مباشرةً.",
        "lock.hold": "اضغط مطولًا للخروج",
        "lock.autoClose": "الإغلاق التلقائي بعد %@",
        "lock.footer": "{keys} ×%d للخروج بلوحة المفاتيح",
        "lock.subtitle.one": "اضغط {keys} مرة أخرى للخروج",
        "lock.subtitle.two": "اضغط {keys} مرتين أخريين للخروج",
        "lock.subtitle.other": "اضغط {keys} %d مرات أخرى للخروج",
        "onb.title": "قبل أن تبدأ",
        "onb.subtitle": "يحتاج Clean Mode إلى إذن «تسهيلات الاستخدام» لقفل لوحة المفاتيح أثناء التنظيف. لا يقرأ ما تكتبه ولا يحفظه.",
        "onb.step1": "انقر على الزر أدناه.",
        "onb.step2": "فعّل Clean Mode في «تسهيلات الاستخدام»:",
        "onb.waiting": "في انتظار الإذن…",
        "onb.stale": "ما زال macOS لا يسمح بالقفل. أوقف Clean Mode ثم شغّله مرة أخرى.",
        "onb.button": "فتح إعدادات النظام",
        "onb.hint": "مفعّل بالفعل؟ أزله بالزر − ثم أضفه مجددًا بالزر +.",
        "onb.ready": "كل شيء جاهز",
        "onb.starting": "جارٍ بدء وضع التنظيف…",
    ]

    private static let fr: [String: String] = [
        "lock.title": "Mode nettoyage",
        "lock.blocked": "Clavier, raccourcis et gestes verrouillés : rien ne se déclenchera pendant le nettoyage.",
        "lock.tips": "Utilisez un chiffon en microfibre doux et sec. N'appuyez pas fort et n'appliquez pas de liquide directement.",
        "lock.hold": "Maintenir pour quitter",
        "lock.autoClose": "Fermeture automatique dans %@",
        "lock.footer": "{keys} ×%d pour quitter avec le clavier",
        "lock.subtitle.one": "Appuyez sur {keys} encore 1 fois pour quitter",
        "lock.subtitle.other": "Appuyez sur {keys} encore %d fois pour quitter",
        "onb.title": "Avant de commencer",
        "onb.subtitle": "Clean Mode a besoin de l'autorisation Accessibilité pour verrouiller votre clavier pendant le nettoyage. Il ne lit ni n'enregistre ce que vous tapez.",
        "onb.step1": "Cliquez sur le bouton ci-dessous.",
        "onb.step2": "Activez Clean Mode dans Accessibilité :",
        "onb.waiting": "En attente de l'autorisation…",
        "onb.stale": "macOS n'autorise toujours pas le verrouillage. Désactivez puis réactivez Clean Mode.",
        "onb.button": "Ouvrir Réglages Système",
        "onb.hint": "Déjà activé ? Retirez-le avec − et ajoutez-le de nouveau avec +.",
        "onb.ready": "Tout est prêt",
        "onb.starting": "Démarrage du mode nettoyage…",
    ]

    private static let pt: [String: String] = [
        "lock.title": "Modo de limpeza",
        "lock.blocked": "Teclado, atalhos e gestos bloqueados: nada será acionado enquanto você limpa.",
        "lock.tips": "Use um pano de microfibra macio e seco. Não pressione com força nem aplique líquido diretamente.",
        "lock.hold": "Segure para sair",
        "lock.autoClose": "Fechamento automático em %@",
        "lock.footer": "{keys} ×%d para sair pelo teclado",
        "lock.subtitle.one": "Pressione {keys} mais 1 vez para sair",
        "lock.subtitle.other": "Pressione {keys} mais %d vezes para sair",
        "onb.title": "Antes de começar",
        "onb.subtitle": "O Clean Mode precisa da permissão de Acessibilidade para bloquear o teclado enquanto você limpa. Ele não lê nem guarda o que você digita.",
        "onb.step1": "Clique no botão abaixo.",
        "onb.step2": "Ative o Clean Mode em Acessibilidade:",
        "onb.waiting": "Aguardando a permissão…",
        "onb.stale": "O macOS ainda não permite o bloqueio. Desative e ative o Clean Mode novamente.",
        "onb.button": "Abrir Ajustes do Sistema",
        "onb.hint": "Já está ativado? Remova com − e adicione novamente com +.",
        "onb.ready": "Tudo pronto",
        "onb.starting": "Iniciando o modo de limpeza…",
    ]

    private static let ru: [String: String] = [
        "lock.title": "Режим очистки",
        "lock.blocked": "Клавиатура, сочетания клавиш и жесты заблокированы: во время уборки ничего не сработает.",
        "lock.tips": "Используйте мягкую сухую салфетку из микрофибры. Не нажимайте сильно и не наносите жидкость напрямую.",
        "lock.hold": "Удерживайте, чтобы выйти",
        "lock.autoClose": "Автоматическое закрытие через %@",
        "lock.footer": "{keys} ×%d, чтобы выйти с клавиатуры",
        "lock.subtitle.one": "Нажмите {keys} ещё 1 раз, чтобы выйти",
        "lock.subtitle.other": "Нажмите {keys} ещё %d раза, чтобы выйти",
        "onb.title": "Прежде чем начать",
        "onb.subtitle": "Clean Mode нужно разрешение «Универсальный доступ», чтобы блокировать клавиатуру во время уборки. Приложение не читает и не сохраняет то, что вы вводите.",
        "onb.step1": "Нажмите кнопку ниже.",
        "onb.step2": "Включите Clean Mode в разделе «Универсальный доступ»:",
        "onb.waiting": "Ожидание разрешения…",
        "onb.stale": "macOS всё ещё не разрешает блокировку. Выключите и снова включите Clean Mode.",
        "onb.button": "Открыть Системные настройки",
        "onb.hint": "Уже включено? Удалите кнопкой − и добавьте снова кнопкой +.",
        "onb.ready": "Всё готово",
        "onb.starting": "Запуск режима очистки…",
    ]

    private static let bn: [String: String] = [
        "lock.title": "পরিষ্কার মোড",
        "lock.blocked": "কীবোর্ড, শর্টকাট ও জেসচার লক করা আছে: পরিষ্কার করার সময় কিছুই চালু হবে না।",
        "lock.tips": "নরম, শুকনো মাইক্রোফাইবার কাপড় ব্যবহার করুন। জোরে চাপ দেবেন না এবং সরাসরি তরল লাগাবেন না।",
        "lock.hold": "বের হতে চেপে ধরে রাখুন",
        "lock.autoClose": "%@ পরে নিজে থেকে বন্ধ হবে",
        "lock.footer": "{keys} ×%d দিয়ে কীবোর্ড থেকে বের হন",
        "lock.subtitle.one": "বের হতে {keys} আরও ১ বার চাপুন",
        "lock.subtitle.other": "বের হতে {keys} আরও %d বার চাপুন",
        "onb.title": "শুরু করার আগে",
        "onb.subtitle": "পরিষ্কার করার সময় আপনার কীবোর্ড লক করতে Clean Mode-এর অ্যাক্সেসিবিলিটি অনুমতি দরকার। আপনি যা টাইপ করেন তা এটি পড়ে না বা সংরক্ষণ করে না।",
        "onb.step1": "নিচের বোতামে ক্লিক করুন।",
        "onb.step2": "অ্যাক্সেসিবিলিটিতে Clean Mode চালু করুন:",
        "onb.waiting": "অনুমতির জন্য অপেক্ষা করা হচ্ছে…",
        "onb.stale": "macOS এখনও লক করার অনুমতি দিচ্ছে না। Clean Mode বন্ধ করে আবার চালু করুন।",
        "onb.button": "সিস্টেম সেটিংস খুলুন",
        "onb.hint": "আগে থেকেই চালু? − দিয়ে সরিয়ে + দিয়ে আবার যোগ করুন।",
        "onb.ready": "সব প্রস্তুত",
        "onb.starting": "পরিষ্কার মোড শুরু হচ্ছে…",
    ]

    private static let ja: [String: String] = [
        "lock.title": "クリーニングモード",
        "lock.blocked": "キーボード、ショートカット、ジェスチャをロックしています。掃除中に誤作動することはありません。",
        "lock.tips": "柔らかく乾いたマイクロファイバークロスを使ってください。強く押したり、液体を直接かけたりしないでください。",
        "lock.hold": "長押しして終了",
        "lock.autoClose": "%@後に自動終了",
        "lock.footer": "{keys} ×%d でキーボードから終了",
        "lock.subtitle.one": "{keys} をあと1回押すと終了します",
        "lock.subtitle.other": "{keys} をあと%d回押すと終了します",
        "onb.title": "はじめに",
        "onb.subtitle": "Clean Mode が掃除中にキーボードをロックするには、アクセシビリティの許可が必要です。入力内容を読み取ったり保存したりすることはありません。",
        "onb.step1": "下のボタンをクリックします。",
        "onb.step2": "アクセシビリティで Clean Mode をオンにします:",
        "onb.waiting": "許可を待っています…",
        "onb.stale": "macOS がまだロックを許可していません。Clean Mode を一度オフにしてからオンにしてください。",
        "onb.button": "システム設定を開く",
        "onb.hint": "すでにオンですか？ − で削除し、+ でもう一度追加してください。",
        "onb.ready": "準備完了",
        "onb.starting": "クリーニングモードを開始しています…",
    ]

    private static let de: [String: String] = [
        "lock.title": "Reinigungsmodus",
        "lock.blocked": "Tastatur, Kurzbefehle und Gesten sind gesperrt: Während der Reinigung wird nichts ausgelöst.",
        "lock.tips": "Verwende ein weiches, trockenes Mikrofasertuch. Nicht fest drücken und keine Flüssigkeit direkt auftragen.",
        "lock.hold": "Zum Beenden gedrückt halten",
        "lock.autoClose": "Automatisches Beenden in %@",
        "lock.footer": "{keys} ×%d, um mit der Tastatur zu beenden",
        "lock.subtitle.one": "Drücke {keys} noch 1 Mal, um zu beenden",
        "lock.subtitle.other": "Drücke {keys} noch %d Mal, um zu beenden",
        "onb.title": "Bevor es losgeht",
        "onb.subtitle": "Clean Mode benötigt die Berechtigung „Bedienungshilfen“, um deine Tastatur während der Reinigung zu sperren. Es liest oder speichert nie, was du tippst.",
        "onb.step1": "Klicke auf die Schaltfläche unten.",
        "onb.step2": "Aktiviere Clean Mode unter „Bedienungshilfen“:",
        "onb.waiting": "Warte auf Berechtigung …",
        "onb.stale": "macOS erlaubt das Sperren noch nicht. Schalte Clean Mode aus und wieder ein.",
        "onb.button": "Systemeinstellungen öffnen",
        "onb.hint": "Schon aktiviert? Entferne es mit − und füge es mit + erneut hinzu.",
        "onb.ready": "Alles bereit",
        "onb.starting": "Reinigungsmodus wird gestartet …",
    ]

    private static let it: [String: String] = [
        "lock.title": "Modalità pulizia",
        "lock.blocked": "Tastiera, scorciatoie e gesti bloccati: nulla si attiverà mentre pulisci.",
        "lock.tips": "Usa un panno in microfibra morbido e asciutto. Non premere con forza e non applicare liquidi direttamente.",
        "lock.hold": "Tieni premuto per uscire",
        "lock.autoClose": "Chiusura automatica tra %@",
        "lock.footer": "{keys} ×%d per uscire con la tastiera",
        "lock.subtitle.one": "Premi {keys} ancora 1 volta per uscire",
        "lock.subtitle.other": "Premi {keys} ancora %d volte per uscire",
        "onb.title": "Prima di iniziare",
        "onb.subtitle": "Clean Mode richiede l'autorizzazione Accessibilità per bloccare la tastiera mentre pulisci. Non legge né memorizza ciò che digiti.",
        "onb.step1": "Fai clic sul pulsante qui sotto.",
        "onb.step2": "Attiva Clean Mode in Accessibilità:",
        "onb.waiting": "In attesa dell'autorizzazione…",
        "onb.stale": "macOS non consente ancora il blocco. Disattiva e riattiva Clean Mode.",
        "onb.button": "Apri Impostazioni di Sistema",
        "onb.hint": "Già attivo? Rimuovilo con − e aggiungilo di nuovo con +.",
        "onb.ready": "Tutto pronto",
        "onb.starting": "Avvio della modalità pulizia…",
    ]

    private static let ko: [String: String] = [
        "lock.title": "청소 모드",
        "lock.blocked": "키보드, 단축키, 제스처가 잠겨 있어요. 청소하는 동안 아무것도 실행되지 않아요.",
        "lock.tips": "부드럽고 마른 마이크로파이버 천을 사용하세요. 세게 누르거나 액체를 직접 뿌리지 마세요.",
        "lock.hold": "길게 눌러 종료",
        "lock.autoClose": "%@ 후 자동 종료",
        "lock.footer": "{keys} ×%d 로 키보드에서 종료",
        "lock.subtitle.one": "{keys} 를 1번 더 누르면 종료돼요",
        "lock.subtitle.other": "{keys} 를 %d번 더 누르면 종료돼요",
        "onb.title": "시작하기 전에",
        "onb.subtitle": "Clean Mode가 청소하는 동안 키보드를 잠그려면 손쉬운 사용 권한이 필요해요. 입력하는 내용을 읽거나 저장하지 않아요.",
        "onb.step1": "아래 버튼을 클릭하세요.",
        "onb.step2": "손쉬운 사용에서 Clean Mode를 켜세요:",
        "onb.waiting": "권한을 기다리는 중…",
        "onb.stale": "macOS에서 아직 잠금을 허용하지 않아요. Clean Mode를 껐다가 다시 켜세요.",
        "onb.button": "시스템 설정 열기",
        "onb.hint": "이미 켜져 있나요? −로 제거한 뒤 +로 다시 추가하세요.",
        "onb.ready": "준비 완료",
        "onb.starting": "청소 모드를 시작하는 중…",
    ]
}
