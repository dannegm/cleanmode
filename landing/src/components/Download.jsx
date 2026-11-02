import { useState } from 'react';
import { Download as DownloadIcon } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { RELEASES_URL, REPO_URL } from '../config.js';
import { GithubIcon, Section } from './ui.jsx';

const QUARANTINE_COMMAND = 'xattr -dr com.apple.quarantine /Applications/CleanMode.app';

function CopyCode({ text }) {
    const { t } = useI18n();
    const [copied, setCopied] = useState(false);

    const copy = async () => {
        try {
            await navigator.clipboard.writeText(text);
            setCopied(true);
            setTimeout(() => setCopied(false), 1800);
        } catch {
            // sin acceso al portapapeles: el texto sigue siendo seleccionable
        }
    };

    return (
        <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-black/60 p-3">
            <code className="min-w-0 flex-1 overflow-x-auto font-mono text-xs whitespace-nowrap text-white/80">
                {text}
            </code>
            <button
                type="button"
                onClick={copy}
                className="shrink-0 rounded-lg border border-white/15 px-2.5 py-1 text-xs text-white/80 transition-colors hover:bg-white/10"
            >
                {copied ? t.common.copied : t.common.copy}
            </button>
        </div>
    );
}

export default function Download() {
    const { t } = useI18n();
    const d = t.download;

    return (
        <Section id="download">
            <div className="grid items-start gap-10 rounded-3xl border border-white/10 bg-gradient-to-b from-[#2748b8]/25 to-white/[0.02] p-8 md:p-12 lg:grid-cols-2">
                <div>
                    <h2 className="text-3xl font-semibold tracking-tight md:text-4xl">{d.title}</h2>
                    <p className="mt-3 text-lg text-white/65">{d.text}</p>

                    <div className="mt-8 flex flex-wrap gap-3">
                        <a
                            href={RELEASES_URL}
                            className="inline-flex items-center gap-2 rounded-xl bg-white px-5 py-3 font-medium text-black transition-colors hover:bg-white/85"
                        >
                            <DownloadIcon className="size-5" />
                            {d.button}
                        </a>
                        <a
                            href={REPO_URL}
                            className="inline-flex items-center gap-2 rounded-xl border border-white/20 px-5 py-3 font-medium transition-colors hover:bg-white/10"
                        >
                            <GithubIcon />
                            {d.source}
                        </a>
                    </div>
                    <p className="mt-5 text-sm text-white/45">{d.requirements}</p>
                    <p className="mt-2 text-sm text-white/45">{d.checksum}</p>
                </div>

                <div className="rounded-2xl border border-white/10 bg-black/40 p-6">
                    <h3 className="font-semibold">{d.gatekeeperTitle}</h3>
                    <p className="mt-2 text-sm text-white/60">{d.gatekeeperText}</p>
                    <ol className="mt-4 list-decimal space-y-1.5 pl-5 text-sm text-white/85">
                        {d.steps.map(step => (
                            <li key={step}>{step}</li>
                        ))}
                    </ol>
                    <p className="mt-5 mb-2 text-sm text-white/60">{d.orTerminal}</p>
                    <CopyCode text={QUARANTINE_COMMAND} />
                    <p className="mt-5 text-xs text-white/45">{d.updates}</p>
                </div>
            </div>
        </Section>
    );
}
