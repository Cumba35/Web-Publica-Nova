# Web Pública Nova

Portal público de distribución del ecosistema NOVA.

- **Repositorio:** https://github.com/Cumba35/Web-Publica-Nova
- **Rama:** `main`
- **URL pública:** https://cumba35.github.io/Web-Publica-Nova/
- **Sitios:** portada + nueve micrositios.
- **Repositorios fuente:** permanecen privados.

## Sitios publicados

1. [Nova Apps](https://cumba35.github.io/Web-Publica-Nova/nova-apps/)
2. [Nova E-commerce](https://cumba35.github.io/Web-Publica-Nova/nova-ecommerce/)
3. [Nova Bank](https://cumba35.github.io/Web-Publica-Nova/nova-bank/)
4. [Nova Novels](https://cumba35.github.io/Web-Publica-Nova/nova-novels/)
5. [Nova Nexus](https://cumba35.github.io/Web-Publica-Nova/nova-nexus/)
6. [Noticias Nova](https://cumba35.github.io/Web-Publica-Nova/noticias-nova/)
7. [Nova Chat](https://cumba35.github.io/Web-Publica-Nova/nova-chat/)
8. [Multimedia Nova](https://cumba35.github.io/Web-Publica-Nova/multimedia-nova/)
9. [NOVA IA](https://cumba35.github.io/Web-Publica-Nova/nova-ia/)

Nova Workspace queda excluido del portal público.

## Estructura y diseño

- `index.html`: portada con nueve tarjetas y monogramas SVG propios.
- `assets/css/site.css`: estilos compartidos, responsive, acentos cromáticos por proyecto, foco de teclado y soporte para movimiento reducido.
- `assets/icons/`: favicon SVG independiente para cada proyecto.
- `assets/nova-mark.svg`: favicon general del portal.
- Cada micrositio conserva su propia ficha, enlaces de acceso y aviso de estado funcional.

## Donaciones

Todas las páginas públicas incluyen un acceso común a la sección de donaciones. La sección informa que las aportaciones serán voluntarias, sin beneficios para el donante, y que se podrá elegir anonimato ante NOVA o reconocimiento público opcional mediante nombre/seudónimo. **No hay checkout activo ni se solicitan datos de pago** hasta confirmar un proveedor legalmente compatible con la residencia del propietario en Cuba. El validador exige que las diez páginas mantengan el enlace global.

## Validación y despliegue

El workflow `.github/workflows/pages.yml`:
1. Ejecuta `python3 scripts/validate_site.py` para revisar las diez páginas, enlaces y recursos locales, anclas, metadatos básicos y controles de accesibilidad.
2. Busca patrones de secretos en los archivos públicos.
3. Publica el artefacto en GitHub Pages.
4. Comprueba por HTTPS la portada y las nueve rutas, exigiendo una respuesta correcta y un documento con `<title>`.

**Última versión comprobada:** commit `7bfbdf929bd388fbf3dc1502bfa1b85d1c7bb676`. El workflow [Deploy Web Publica Nova — run 43323743895](https://github.com/Cumba35/Web-Publica-Nova/actions/runs/43323743895) terminó con build, deploy y verificación HTTPS de las diez rutas correctos.

## Estado funcional y límites

Estas páginas son superficies públicas informativas y enlaces de acceso; no sustituyen los frontends autenticados ni crean servicios de backend por sí solas.

- Nova Apps enlaza al catálogo y a los apartados públicos de proyectos y recursos de usuarios.
- Nova E-commerce enlaza a la PWA existente. No se habilitan cobros ni pagos reales.
- Nova Bank enlaza a su frontend autenticado; no es un banco físico ni expone saldos u operaciones.
- Nova Novels mantiene WordPress como biblioteca pública activa. No se republican obras ni portadas hasta revisar derechos y atribución.
- Nova Nexus presenta el proyecto sin publicar paneles ni documentación interna.
- Noticias Nova no muestra titulares ficticios ni activa un feed hasta disponer de un flujo editorial verificado.
- Nova Chat permanece en desarrollo; no se presenta como mensajería operativa.
- Multimedia Nova enlaza al panel autenticado de Nova Apps; quedan pendientes pruebas reales de carga/descarga y configuración OAuth de proveedores.
- NOVA IA es informativa; el backend administrativo no está aprobado para exposición pública hasta completar autenticación multiusuario y controles de seguridad.

No publicar repositorios fuente completos, archivos `.env`, claves, tokens, datos de usuarios, bases de datos, paneles administrativos ni documentación interna.
