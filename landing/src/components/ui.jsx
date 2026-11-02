export function Section({ id, title, subtitle, children, className = '' }) {
    return (
        <section id={id} className={`mx-auto max-w-6xl scroll-mt-20 px-5 py-20 md:py-28 ${className}`}>
            {(title || subtitle) && (
                <header className="mx-auto mb-12 max-w-2xl text-center">
                    {title && <h2 className="text-3xl font-semibold tracking-tight md:text-4xl">{title}</h2>}
                    {subtitle && <p className="mt-4 text-lg text-white/60">{subtitle}</p>}
                </header>
            )}
            {children}
        </section>
    );
}

/** Tecla estilo <kbd>, como en la pantalla de la app. */
export function Kbd({ children, big = false }) {
    return (
        <kbd
            className={`inline-flex items-center justify-center rounded-md border border-white/40 bg-white/10 font-medium text-white shadow-[0_1px_0_rgba(255,255,255,0.35)] ${
                big ? 'min-w-11 px-3 py-1.5 text-2xl' : 'min-w-6 px-1.5 py-0.5 text-[0.8em]'
            }`}
        >
            {children}
        </kbd>
    );
}

export function GithubIcon({ className = 'size-5' }) {
    return (
        <svg viewBox="0 0 16 16" aria-hidden="true" className={className} fill="currentColor">
            <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
        </svg>
    );
}
