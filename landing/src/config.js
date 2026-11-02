// Repositorio de GitHub (usuario/repo). Todos los enlaces del sitio salen de aquí.
export const REPO = 'dannegm/cleanmode';

export const REPO_URL = `https://github.com/${REPO}`;
// `releases/latest` siempre apunta a la versión más reciente: no hay que actualizar el enlace.
export const RELEASES_URL = `${REPO_URL}/releases/latest`;
export const ISSUES_URL = `${REPO_URL}/issues`;
export const DONATE_URL = 'https://www.paypal.me/dannegm';
export const AUTHOR = 'Daniel Garcia';

/** Ruta de un archivo de /public respetando la base (GitHub Pages sirve bajo /REPO/). */
export const asset = path => `${import.meta.env.BASE_URL}${path}`;
