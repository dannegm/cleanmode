import { Download, Heart } from 'lucide-react';
import { useI18n, languages } from '../i18n.jsx';
import { DONATE_URL, RELEASES_URL, REPO_URL, asset } from '../config.js';
import { GithubIcon } from './ui.jsx';

function LanguageSwitch() {
    const { lang, setLang } = useI18n();
    return (
        <div role="group" aria-label="Language" className="flex rounded-full border border-white/15 p-0.5 text-xs">
            {Object.entries(languages).map(([code, name]) => (
                <button
                    key={code}
                    type="button"
                    onClick={() => setLang(code)}
                    aria-pressed={lang === code}
                    title={name}
                    className={`rounded-full px-2.5 py-1 font-medium uppercase transition-colors ${
                        lang === code ? 'bg-white text-black' : 'text-white/60 hover:text-white'
                    }`}
                >
                    {code}
                </button>
            ))}
        </div>
    );
}

export default function Nav() {
    const { t } = useI18n();
    const links = [
        ['#features', t.nav.features],
        ['#how', t.nav.how],
        ['#faq', t.nav.faq],
    ];

    return (
        <header className="sticky top-0 z-50 border-b border-white/10 bg-black/60 backdrop-blur-xl">
            <nav className="mx-auto flex h-14 max-w-6xl items-center gap-6 px-5">
                <a href="#top" className="flex items-center gap-2.5 font-semibold">
                    <img src={asset('icon.png')} alt="" className="size-7" />
                    Clean Mode
                </a>

                <div className="ml-4 hidden items-center gap-6 text-sm text-white/60 md:flex">
                    {links.map(([href, label]) => (
                        <a key={href} href={href} className="transition-colors hover:text-white">
                            {label}
                        </a>
                    ))}
                </div>

                <div className="ml-auto flex items-center gap-3">
                    <LanguageSwitch />
                    <a
                        href={DONATE_URL}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label={t.nav.donate}
                        title={t.nav.donate}
                        className="hidden text-white/60 transition-colors hover:text-[#ff6b81] sm:block"
                    >
                        <Heart className="size-5" />
                    </a>
                    <a
                        href={REPO_URL}
                        aria-label="GitHub"
                        className="hidden text-white/60 transition-colors hover:text-white sm:block"
                    >
                        <GithubIcon />
                    </a>
                    <a
                        href={RELEASES_URL}
                        className="inline-flex items-center gap-1.5 rounded-full bg-white px-3.5 py-1.5 text-sm font-medium text-black transition-colors hover:bg-white/85"
                    >
                        <Download className="size-4" />
                        <span className="hidden sm:inline">{t.nav.download}</span>
                    </a>
                </div>
            </nav>
        </header>
    );
}
