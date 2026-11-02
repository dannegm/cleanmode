export default {
    meta: {
        title: "Clean Mode — Lock your Mac's keyboard and screen while you clean it",
        description:
            'Free, open source macOS app that locks your keyboard, shortcuts and gestures and turns the screen black so you can clean your Mac without touching a thing by accident.',
    },
    common: { copy: 'Copy', copied: 'Copied' },
    nav: { features: 'Features', how: 'How it works', faq: 'FAQ', download: 'Download', donate: 'Donate' },
    hero: {
        title1: 'Clean your Mac.',
        title2: 'Touch nothing by accident.',
        subtitle:
            'Clean Mode locks your keyboard, shortcuts and gestures and turns the screen black, so you can wipe everything down without opening apps, changing settings or putting your Mac to sleep.',
        download: 'Download for macOS',
        github: 'View on GitHub',
        meta: 'Free & open source · macOS 13+ · Apple Silicon and Intel',
        shotAlt: 'Clean Mode lock screen: black screen with a broom icon and a hold-to-exit button',
    },
    problem: {
        title: 'Cleaning a Mac is riskier than it looks',
        intro: 'Wiping a keyboard presses every key. Wiping a trackpad fires gestures. In a few seconds you can:',
        items: [
            'Type nonsense into whatever app is focused',
            'Trigger shortcuts: quit, close, delete, Mission Control…',
            'Change the volume, the brightness or a setting',
            'Put your Mac to sleep or log out',
        ],
        outro: "The usual workaround is shutting down first. That's slow, and a dark screen hides the dust you're trying to wipe. Clean Mode keeps the screen on and black, so you see exactly where you've cleaned.",
    },
    features: {
        title: 'Everything locked. Nothing to worry about.',
        items: [
            {
                icon: 'keyboard',
                title: 'Keyboard locked',
                text: 'Every key is ignored, including media, volume and brightness keys.',
            },
            {
                icon: 'shortcuts',
                title: 'Shortcuts and gestures',
                text: '⌘Tab, ⌘Q, force quit, the Dock and the menu bar are disabled, plus most trackpad gestures.',
            },
            {
                icon: 'screen',
                title: 'Black screen, every display',
                text: 'A pure black overlay on all your screens makes smudges and dust easy to spot.',
            },
            {
                icon: 'cursor',
                title: 'A cursor you can follow',
                text: 'The real cursor is hidden and replaced by a circle with a smooth trail.',
            },
            {
                icon: 'awake',
                title: 'Display stays awake',
                text: "Your screen won't dim or go to sleep while you're cleaning.",
            },
            {
                icon: 'languages',
                title: '13 languages',
                text: 'English, Español, 中文, हिन्दी, العربية, Français, Português, Русский, বাংলা, 日本語, Deutsch, Italiano and 한국어, picked from your system.',
            },
        ],
    },
    how: {
        title: 'Three steps',
        steps: [
            {
                title: 'Open it',
                text: 'Everything locks instantly. The first time, a short onboarding asks for the Accessibility permission macOS requires.',
            },
            {
                title: 'Clean',
                text: 'Wipe the keyboard, the trackpad and the screen. Nothing you touch will do anything.',
            },
            {
                title: "Leave when you're done",
                text: 'Hold the button, press ⌘Q three times, or let the timer close it.',
            },
        ],
        shotAlt: 'Clean Mode onboarding window explaining the Accessibility permission',
    },
    exits: {
        title: "You can't get stuck",
        subtitle: 'Three independent ways out. If the app ever crashes, the lock disappears with it.',
        holdLabel: 'Hold to exit',
        hold: { title: 'Hold the button', text: 'Keep it pressed for 3 seconds.' },
        keys: { title: 'Press ⌘Q three times', text: 'The count resets if you pause.' },
        timer: { title: 'Wait for the timer', text: 'It closes by itself after 15 minutes (configurable).' },
    },
    privacy: {
        title: 'Private by design',
        text: 'Clean Mode needs the Accessibility permission only to be able to throw your keystrokes away.',
        items: [
            'It never logs, stores or sends what you type',
            'The only key it looks for is ⌘Q, to count the emergency exit',
            'No network requests, no analytics',
            'Open source under the MIT license: read the code',
            'Revoke the permission any time in System Settings',
        ],
    },
    download: {
        title: 'Download Clean Mode',
        text: 'Free and open source. No account, no tracking.',
        button: 'Download for macOS',
        source: 'Build from source',
        requirements: 'macOS 13 or later · Universal (Apple Silicon and Intel)',
        gatekeeperTitle: 'The first time you open it',
        gatekeeperText:
            "Releases aren't notarized (that needs a paid Apple Developer account), so macOS shows a warning once:",
        steps: [
            'Open System Settings → Privacy & Security.',
            'Scroll to the message about Clean Mode and click Open Anyway.',
        ],
        orTerminal: 'Or run this in Terminal:',
        updates: 'Updates ask for the Accessibility permission again.',
        checksum: 'Verify your download with the .sha256 file attached to every release.',
    },
    support: {
        title: 'Support Clean Mode',
        text: "It's free and open source. If it saved you from a stray keystroke, a small donation helps keep it going.",
        button: 'Donate with PayPal',
        note: 'Totally optional, and thank you! The app shows a small, dismissible reminder every 10 cleanings; you can turn it off for good.',
    },
    faq: {
        title: 'Questions',
        items: [
            {
                q: 'Why does it need the Accessibility permission?',
                a: "macOS only lets an app intercept the keyboard if you grant it. Clean Mode uses it to discard every key while you clean. It doesn't read or keep what you type.",
            },
            {
                q: 'Why does macOS warn me when I open it?',
                a: 'The app is free and signed ad hoc, not notarized by Apple (that requires a paid developer account). Use Open Anyway in System Settings → Privacy & Security, or the Terminal command above.',
            },
            {
                q: 'Will it ask for the permission again after an update?',
                a: 'Yes. Since the signature is ad hoc, macOS sees every version as a different app. Remove the old entry in Accessibility with the − button and turn on the new one.',
            },
            {
                q: "Is there anything it can't block?",
                a: 'The power button / Touch ID key (a long press still powers the Mac off) and closing the lid. A few system-level trackpad gestures may also get through on some macOS versions.',
            },
            {
                q: 'Does it work on Intel Macs?',
                a: 'Yes. The build is universal: Apple Silicon and Intel, macOS 13 or later.',
            },
            {
                q: 'Does it record what I type?',
                a: 'No. Every key is discarded. The app makes no network requests and has no analytics.',
            },
        ],
    },
    footer: {
        license: 'MIT License',
        report: 'Report an issue',
        donate: 'Donate',
        notAffiliated: 'Not affiliated with Apple. Mac and macOS are trademarks of Apple Inc.',
    },
};
