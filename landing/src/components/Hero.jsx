import { Download } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { RELEASES_URL, REPO_URL, asset } from '../config.js';
import { GithubIcon } from './ui.jsx';

export default function Hero() {
    const { lang, t } = useI18n();

    return (
        <section id="top" className="relative overflow-hidden">
            <div
                aria-hidden="true"
                className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[680px] bg-[radial-gradient(60%_60%_at_50%_0%,rgba(76,120,255,0.32),transparent_70%)]"
            />

            <div className="mx-auto max-w-6xl px-5 pt-10 pb-16 sm:pt-16 sm:pb-20 md:pt-24">
                <div className="fade-up mx-auto max-w-3xl text-center">
                    <img
                        src={asset('icon.png')}
                        alt="Clean Mode"
                        className="mx-auto size-24 drop-shadow-[0_20px_40px_rgba(76,120,255,0.35)]"
                    />
                    <h1 className="mt-8 text-4xl font-semibold tracking-tight text-balance md:text-6xl">
                        {t.hero.title1}
                        <br />
                        <span className="bg-gradient-to-b from-white to-white/55 bg-clip-text text-transparent">
                            {t.hero.title2}
                        </span>
                    </h1>
                    <p className="mx-auto mt-6 max-w-2xl text-lg text-balance text-white/65 md:text-xl">
                        {t.hero.subtitle}
                    </p>

                    <div className="mt-9 flex flex-wrap items-center justify-center gap-3">
                        <a
                            href={RELEASES_URL}
                            className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-white px-5 py-3 font-medium text-black transition-colors hover:bg-white/85 sm:w-auto"
                        >
                            <Download className="size-5" />
                            {t.hero.download}
                        </a>
                        <a
                            href={REPO_URL}
                            className="inline-flex w-full items-center justify-center gap-2 rounded-xl border border-white/20 px-5 py-3 font-medium transition-colors hover:bg-white/10 sm:w-auto"
                        >
                            <GithubIcon />
                            {t.hero.github}
                        </a>
                    </div>
                    <p className="mt-5 text-sm text-white/45">{t.hero.meta}</p>
                </div>

                <div className="fade-up mx-auto mt-10 max-w-5xl sm:mt-14 [animation-delay:150ms]">
                    <div className="overflow-hidden rounded-2xl border border-white/10 bg-black shadow-[0_30px_120px_-30px_rgba(76,120,255,0.5)]">
                        <div className="flex items-center gap-1.5 border-b border-white/10 px-4 py-3">
                            <span className="size-2.5 rounded-full bg-[#ff5f57]" />
                            <span className="size-2.5 rounded-full bg-[#febc2e]" />
                            <span className="size-2.5 rounded-full bg-[#28c840]" />
                        </div>
                        <img
                            src={asset(`screenshots/${lang}/lock.png`)}
                            alt={t.hero.shotAlt}
                            className="block w-full"
                        />
                    </div>
                </div>
            </div>
        </section>
    );
}
