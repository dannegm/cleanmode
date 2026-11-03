import { ChevronDown } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { Section } from './ui.jsx';

export default function Faq() {
    const { t } = useI18n();
    return (
        <Section id="faq" title={t.faq.title}>
            <div className="mx-auto max-w-3xl divide-y divide-white/10 rounded-2xl border border-white/10 bg-white/[0.03]">
                {t.faq.items.map(({ q, a }) => (
                    <details key={q} className="group px-5 py-4 sm:px-6 sm:py-5">
                        <summary className="flex cursor-pointer list-none items-center justify-between gap-4 font-medium [&::-webkit-details-marker]:hidden">
                            {q}
                            <ChevronDown className="size-5 shrink-0 text-white/50 transition-transform group-open:rotate-180" />
                        </summary>
                        <p className="mt-3 text-white/65">{a}</p>
                    </details>
                ))}
            </div>
        </Section>
    );
}
