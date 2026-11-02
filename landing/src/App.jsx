import { I18nProvider } from './i18n.jsx';
import Nav from './components/Nav.jsx';
import Hero from './components/Hero.jsx';
import { Problem, Features, HowItWorks, Exits, Privacy } from './components/Sections.jsx';
import Download from './components/Download.jsx';
import Support from './components/Support.jsx';
import Faq from './components/Faq.jsx';
import Footer from './components/Footer.jsx';

export default function App() {
    return (
        <I18nProvider>
            <Nav />
            <main>
                <Hero />
                <Problem />
                <Features />
                <HowItWorks />
                <Exits />
                <Privacy />
                <Download />
                <Support />
                <Faq />
            </main>
            <Footer />
        </I18nProvider>
    );
}
