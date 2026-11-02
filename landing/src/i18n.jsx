import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import en from './locales/en.js';
import es from './locales/es.js';

// Para agregar un idioma: crea src/locales/xx.js (copia en.js) y regístralo aquí.
const messages = { en, es };
export const languages = { en: 'English', es: 'Español' };

const STORAGE_KEY = 'cleanmode-lang';

/** Idioma guardado; si no hay, el del navegador; si no está soportado, inglés. */
function detectLanguage() {
    try {
        const saved = localStorage.getItem(STORAGE_KEY);
        if (saved && messages[saved]) return saved;
    } catch {
        // sin localStorage (modo privado, etc.)
    }
    const code = (navigator.language || 'en').split('-')[0].toLowerCase();
    return messages[code] ? code : 'en';
}

const I18nContext = createContext(null);

export function I18nProvider({ children }) {
    const [lang, setLang] = useState(detectLanguage);
    const t = messages[lang];

    useEffect(() => {
        document.documentElement.lang = lang;
        document.title = t.meta.title;
        document.querySelector('meta[name="description"]')?.setAttribute('content', t.meta.description);
        try {
            localStorage.setItem(STORAGE_KEY, lang);
        } catch {
            // ignorar
        }
    }, [lang, t]);

    const value = useMemo(() => ({ lang, setLang, t }), [lang, t]);
    return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export const useI18n = () => useContext(I18nContext);
