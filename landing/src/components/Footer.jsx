import { Heart } from 'lucide-react';
import { useI18n } from '../i18n.jsx';
import { AUTHOR, DONATE_URL, ISSUES_URL, REPO_URL, asset } from '../config.js';

export default function Footer() {
    const { t } = useI18n();
    const link = 'transition-colors hover:text-white';

    return (
        <footer className="border-t border-white/10">
            <div className="mx-auto flex max-w-6xl flex-col gap-6 px-5 py-10 text-sm text-white/50 md:flex-row md:items-center md:justify-between">
                <div className="flex items-center gap-3">
                    <img src={asset('icon.png')} alt="" className="size-6" />
                    <span>
                        © {new Date().getFullYear()} {AUTHOR}
                    </span>
                </div>

                <div className="flex flex-wrap items-center gap-x-6 gap-y-2">
                    <a href={`${REPO_URL}/blob/main/LICENSE`} className={link}>
                        {t.footer.license}
                    </a>
                    <a href={REPO_URL} className={link}>
                        GitHub
                    </a>
                    <a href={ISSUES_URL} className={link}>
                        {t.footer.report}
                    </a>
                    <a href={DONATE_URL} className={`inline-flex items-center gap-1.5 ${link}`}>
                        <Heart className="size-4 text-[#ff6b81]" />
                        {t.footer.donate}
                    </a>
                </div>
            </div>
            <p className="mx-auto max-w-6xl px-5 pb-10 text-xs text-white/30">{t.footer.notAffiliated}</p>
        </footer>
    );
}
