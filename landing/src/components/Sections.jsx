import { Command, Hand, Keyboard, Languages, Monitor, MousePointer2, ShieldCheck, Sun, Timer } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { asset } from '../config.js';
import { Kbd, Section } from './ui.jsx';

const featureIcons = {
    keyboard: Keyboard,
    shortcuts: Command,
    screen: Monitor,
    cursor: MousePointer2,
    awake: Sun,
    languages: Languages,
};

export function Problem() {
    const { t } = useI18n();
    return (
        <Section title={t.problem.title}>
            <div className="mx-auto max-w-3xl">
                <p className="text-center text-lg text-white/65">{t.problem.intro}</p>
                <ul className="mt-8 grid gap-3 sm:grid-cols-2">
                    {t.problem.items.map(item => (
                        <li
                            key={item}
                            className="flex items-start gap-3 rounded-2xl border border-white/10 bg-white/[0.03] p-4"
                        >
                            <span aria-hidden="true" className="mt-2 size-1.5 shrink-0 rounded-full bg-[#ff6b6b]" />
                            <span className="text-white/85">{item}</span>
                        </li>
                    ))}
                </ul>
                <p className="mt-8 text-center text-lg text-balance text-white/65">{t.problem.outro}</p>
            </div>
        </Section>
    );
}

export function Features() {
    const { t } = useI18n();
    return (
        <Section id="features" title={t.features.title}>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {t.features.items.map(({ icon, title, text }) => {
                    const Icon = featureIcons[icon];
                    return (
                        <article key={icon} className="rounded-2xl border border-white/10 bg-white/[0.03] p-6">
                            <span className="inline-flex rounded-xl bg-white/10 p-2.5 text-white">
                                <Icon className="size-5" />
                            </span>
                            <h3 className="mt-5 text-lg font-semibold">{title}</h3>
                            <p className="mt-2 text-white/60">{text}</p>
                        </article>
                    );
                })}
            </div>
        </Section>
    );
}

export function HowItWorks() {
    const { lang, t } = useI18n();
    return (
        <Section id="how" title={t.how.title}>
            <div className="grid items-center gap-12 lg:grid-cols-2">
                <ol className="space-y-8">
                    {t.how.steps.map((step, i) => (
                        <li key={step.title} className="flex gap-5">
                            <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-white text-sm font-semibold text-black">
                                {i + 1}
                            </span>
                            <div>
                                <h3 className="text-xl font-semibold">{step.title}</h3>
                                <p className="mt-1.5 text-white/60">{step.text}</p>
                            </div>
                        </li>
                    ))}
                </ol>
                <img
                    src={asset(`screenshots/${lang}/onboarding-dark.png`)}
                    alt={t.how.shotAlt}
                    className="mx-auto w-full max-w-sm"
                />
            </div>
        </Section>
    );
}

/** Demo animada del botón de mantener presionado (relleno blanco; el texto pasa a negro). */
function HoldDemo({ label }) {
    return (
        <div className="relative h-12 w-full overflow-hidden rounded-[10px] border border-white/40 bg-white/10 text-sm font-medium">
            <div className="hold-fill absolute inset-y-0 left-0 bg-white" />
            <span className="absolute inset-0 flex items-center justify-center text-white">{label}</span>
            <span className="hold-text absolute inset-0 flex items-center justify-center text-black">{label}</span>
        </div>
    );
}

export function Exits() {
    const { t } = useI18n();
    const cards = [
        { key: 'hold', icon: Hand, visual: <HoldDemo label={t.exits.holdLabel} /> },
        {
            key: 'keys',
            icon: Command,
            visual: (
                <div className="flex items-center gap-2.5">
                    <Kbd big>⌘</Kbd>
                    <Kbd big>Q</Kbd>
                    <span className="text-2xl font-medium text-white/60">×3</span>
                </div>
            ),
        },
        { key: 'timer', icon: Timer, visual: <div className="font-mono text-4xl tabular-nums">15:00</div> },
    ];

    return (
        <Section title={t.exits.title} subtitle={t.exits.subtitle}>
            <div className="grid gap-4 md:grid-cols-3">
                {cards.map(({ key, icon: Icon, visual }) => (
                    <article key={key} className="flex flex-col rounded-2xl border border-white/10 bg-white/[0.03] p-6">
                        <div className="flex h-24 items-center justify-center">{visual}</div>
                        <div className="mt-6 flex items-center gap-2.5">
                            <Icon className="size-4 text-white/60" />
                            <h3 className="font-semibold">{t.exits[key].title}</h3>
                        </div>
                        <p className="mt-1.5 text-sm text-white/60">{t.exits[key].text}</p>
                    </article>
                ))}
            </div>
        </Section>
    );
}

export function Privacy() {
    const { t } = useI18n();
    return (
        <Section>
            <div className="mx-auto max-w-3xl rounded-3xl border border-white/10 bg-gradient-to-b from-white/[0.06] to-white/[0.02] p-8 md:p-12">
                <span className="inline-flex rounded-xl bg-white/10 p-2.5">
                    <ShieldCheck className="size-6" />
                </span>
                <h2 className="mt-5 text-3xl font-semibold tracking-tight">{t.privacy.title}</h2>
                <p className="mt-3 text-lg text-white/65">{t.privacy.text}</p>
                <ul className="mt-6 space-y-3">
                    {t.privacy.items.map(item => (
                        <li key={item} className="flex items-start gap-3 text-white/85">
                            <span aria-hidden="true" className="mt-2 size-1.5 shrink-0 rounded-full bg-[#5b8def]" />
                            {item}
                        </li>
                    ))}
                </ul>
            </div>
        </Section>
    );
}
