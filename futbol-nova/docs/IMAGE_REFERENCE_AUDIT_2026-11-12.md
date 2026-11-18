# Auditoría de imágenes — Fútbol Nova
Fecha: 2026-11-12

La auditoría del árbol Git completo confirmó 5 archivos binarios en assets/references. Cuatro referencias están archivadas correctamente (pausa, selector de camisetas, Modo Leyenda, ajustes del menú principal). La captura de Pantalla 1 existe solo como miniatura.

Pendientes confirmados:
- Reemplazar miniatura de Pantalla 1 por original 1536×769 (163528 bytes; SHA-1 local 05f4374f19097699d536178c5074828c0691c0b4).
- Subir referencia del Modo Manager (480×270; 18422 bytes; SHA-1 local c5ce2f0408cb386a5a56241cefe6340a651d996d).
- Subir ajustes de partido (1536×863; 104212 bytes; SHA-1 local 18c2c76c8f592cb29a277628f95869b085b081b7).
- Subir ajustes de mando (1536×863; 126253 bytes; SHA-1 local c24a974d91f2f660ddcca3e75f95ab1a77939314).
- Recuperar el archivo binario exacto de la referencia azul HOME / PLAY / CLUB asignada a Pantalla 3; no está en el árbol Git ni en los archivos locales disponibles.

Limitación: el conector GitHub disponible permite crear blobs si se le proporciona el contenido base64, pero en esta ejecución no expone una transferencia directa de los archivos locales binarios. No se han creado archivos vacíos ni se han marcado pendientes como completados.

Inventario actualizado: assets/references/README.md
