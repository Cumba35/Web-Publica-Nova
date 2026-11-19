# Acceso compartido a NOVA IA

Fecha: 2026-11-19

Este sitio incorpora el lanzador común de NOVA IA servido desde Nova Apps:
- CSS: https://cumba35.github.io/Nova-APPS/js/nova/assistant-launcher.css
- JavaScript: https://cumba35.github.io/Nova-APPS/js/nova/assistant-launcher.js
- Conversación central: https://cumba35.github.io/Nova-APPS/#nova-ia

El lanzador se añade a las páginas HTML de este repositorio y dirige a la conversación central de Nova Apps. No duplica el modelo, no almacena conversaciones ni credenciales y no crea una sesión independiente. La autenticación, el historial y la memoria siguen sujetos a los controles de Nova Apps y a los servicios existentes.

La integración depende de que GitHub Pages de Nova Apps publique y sirva esos dos recursos. La presencia de los enlaces en GitHub no confirma que el despliegue público haya terminado. Debe comprobarse desde móvil y escritorio después de la publicación.

No se modificaron funciones backend, tablas, políticas RLS ni secretos de este repositorio.
