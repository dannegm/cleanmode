import { Heart } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { DONATE_URL } from '../config.js';

export default function Support() {
    const { t } = useI18n();
    const s = t.support;

    return (
        <section id="support" className="mx-auto max-w-6xl scroll-mt-20 px-5 py-10 md:py-14">
            <div className="flex flex-col gap-8 rounded-3xl border border-white/10 bg-gradient-to-br from-[#ff6b81]/15 via-white/[0.03] to-white/[0.02] p-8 md:flex-row md:items-center md:justify-between md:p-12">
                <div className="max-w-xl">
                    <span className="inline-flex rounded-xl bg-white/10 p-2.5">
                        <Heart className="size-6 text-[#ff6b81]" fill="currentColor" />
                    </span>
                    <h2 className="mt-5 text-3xl font-semibold tracking-tight">{s.title}</h2>
                    <p className="mt-3 text-lg text-white/65">{s.text}</p>
                    <p className="mt-3 text-sm text-white/45">{s.note}</p>
                </div>

                <a
                    href={DONATE_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-white px-6 py-3.5 text-lg font-medium text-black transition-colors hover:bg-white/85"
                >
                    <Heart className="size-5 text-[#ff4d6d]" fill="currentColor" />
                    {s.button}
                </a>
            </div>
        </section>
    );
}
