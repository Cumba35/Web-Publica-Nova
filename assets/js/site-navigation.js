(() => {
  const header = document.querySelector('header');
  const nav = header?.querySelector('.nav');
  const main = document.querySelector('main');
  if (!header || !nav || !main) return;
  nav.id ||= 'nova-project-menu';
  nav.setAttribute('aria-label', 'Navegación principal del ecosistema NOVA');
  const home = document.createElement('a');
  home.href = '/Web-Publica-Nova/';
  home.textContent = 'Inicio';
  home.dataset.homeLink = 'true';
  nav.prepend(home);
  const path = location.pathname.replace(/index\.html$/, '').replace(/\/$/, '');
  const current = [...nav.querySelectorAll('a')].find(a => !a.dataset.homeLink && new URL(a.href, location.href).pathname.replace(/\/$/, '') === path);
  if (current) current.setAttribute('aria-current', 'page');
  else if (path === '/Web-Publica-Nova' || path === '') home.setAttribute('aria-current', 'page');
  const toggle = document.createElement('button');
  toggle.className = 'menu-toggle';
  toggle.type = 'button';
  toggle.textContent = '☰ Menú';
  toggle.setAttribute('aria-controls', nav.id);
  toggle.setAttribute('aria-expanded', 'false');
  toggle.setAttribute('aria-label', 'Abrir menú principal');
  nav.parentElement.insertBefore(toggle, nav);
  const closeMenu = () => {
    nav.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'Abrir menú principal');
    toggle.textContent = '☰ Menú';
  };
  toggle.addEventListener('click', () => {
    const open = toggle.getAttribute('aria-expanded') !== 'true';
    nav.classList.toggle('is-open', open);
    toggle.setAttribute('aria-expanded', String(open));
    toggle.setAttribute('aria-label', open ? 'Cerrar menú principal' : 'Abrir menú principal');
    toggle.textContent = open ? '✕ Cerrar' : '☰ Menú';
  });
  nav.addEventListener('click', event => { if (event.target.closest('a')) closeMenu(); });
  document.addEventListener('keydown', event => { if (event.key === 'Escape') closeMenu(); });
  const candidates = [...main.querySelectorAll(':scope > section, :scope > .cols > section, :scope > .cols > aside')].filter(section => section.querySelector('h2'));
  const used = new Set();
  const entries = candidates.map(section => {
    const heading = section.querySelector('h2');
    let id = section.id || heading.textContent.trim().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'seccion';
    const base = id; let n = 2;
    while (used.has(id) || (document.getElementById(id) && document.getElementById(id) !== section)) id = base + '-' + n++;
    used.add(id); section.id = id; section.classList.add('page-section');
    return { id, label: heading.textContent.trim() };
  });
  if (entries.length) {
    const sectionNav = document.createElement('nav');
    sectionNav.className = 'section-nav';
    sectionNav.setAttribute('aria-label', 'Secciones de esta página');
    const title = document.createElement('span');
    title.className = 'section-nav-title'; title.textContent = 'En esta página';
    sectionNav.append(title);
    const list = document.createElement('div'); list.className = 'section-nav-links';
    const start = document.createElement('a'); start.href = '#contenido'; start.textContent = 'Inicio'; list.append(start);
    entries.forEach(entry => { const link = document.createElement('a'); link.href = '#' + entry.id; link.textContent = entry.label; list.append(link); });
    sectionNav.append(list);
    const lead = main.querySelector('.lead');
    if (lead) lead.insertAdjacentElement('afterend', sectionNav); else main.insertBefore(sectionNav, main.firstChild);
  }
  const top = document.createElement('a');
  top.className = 'back-to-top'; top.href = '#contenido'; top.textContent = '↑';
  top.setAttribute('aria-label', 'Volver al inicio de la página'); document.body.append(top);
})();