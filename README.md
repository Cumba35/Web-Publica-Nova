# Web Pública Nova

Portal público de distribución del ecosistema NOVA.

- **Repositorio:** https://github.com/Cumba35/Web-Publica-Nova
- **Rama:** `main`
- **URL prevista de GitHub Pages:** https://cumba35.github.io/Web-Publica-Nova/
- **Páginas:** nueve micrositios bajo `/<proyecto>/`.
- **Fuentes:** los repositorios de los proyectos permanecen privados.

## Estructura

- `index.html`: portal principal.
- `assets/css/site.css`: estilos compartidos, adaptables a móvil y escritorio.
- `nova-apps/`, `nova-ecommerce/`, `nova-bank/`, `nova-novels/`, `nova-nexus/`, `noticias-nova/`, `nova-chat/`, `multimedia-nova/`, `nova-ia/`: páginas públicas de cada proyecto.
- `.github/workflows/pages.yml`: publicación de GitHub Pages mediante Actions.

## Publicación

GitHub Pages ya recibió una ejecución de despliegue correcta mediante el workflow `Deploy Web Publica Nova` (run 42980537466; build y deploy SUCCESS). URL prevista: https://cumba35.github.io/Web-Publica-Nova/. La respuesta HTTP de cada ruta debe revisarse desde un navegador; la verificación externa automática aún no se ha podido completar.

## Alcance y seguridad

Estas páginas son micrositios informativos y no sustituyen las aplicaciones autenticadas. No copiar repositorios fuente completos, archivos `.env`, claves, tokens, datos de usuarios, bases de datos, paneles administrativos ni documentación interna. No habilitar operaciones sensibles desde páginas estáticas.

Los estados se describen con honestidad: Nova Chat aún no tiene cliente/backend implementados; Multimedia Nova tiene API privada pero no frontend público propio; Nova IA no tiene backend FastAPI desplegado; Nova Bank mantiene los datos financieros protegidos; Nova Nexus solo publica una presentación, no su panel privado. Nova E-commerce no procesa pagos reales.

## Actualización

Actualizar cada página después de auditar el frontend de su repositorio fuente. Mantener rutas relativas compatibles con el prefijo `/Web-Publica-Nova/`. Verificar enlaces, recursos, accesibilidad y estado del despliegue antes de marcar una página como operativa.
