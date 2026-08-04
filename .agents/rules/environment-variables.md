---
description: Al agregar, renombrar o eliminar una variable de entorno leída por Environment, obliga a sincronizar .env.example, el README y la configuración de CI (codemagic.yaml) en el MISMO cambio. Aplica cada vez que un feature/fix toque la configuración por entorno (URLs de backend, claves, flags).
---

# Variables de Entorno

Las variables de entorno son la configuración del proyecto fuera del código. La app las carga con **`flutter_dotenv`** desde un archivo `.env` en la raíz y las expone a través de `Environment` (`lib/config/enviroment/enviroment.dart`), que es el **único** punto del código que lee `dotenv.env[...]`.

La plantilla pública `/.env.example` es la **única fuente de onboarding**: un dev nuevo debe poder levantar el proyecto copiándola. Si queda desincronizada, el onboarding se rompe silenciosamente — y en una app móvil el fallo no aparece al compilar, sino en tiempo de ejecución, cuando `dotenv.env['LO_QUE_FALTA']` devuelve `null` y la app pide datos a una URL vacía.

## Variables actuales

| Variable | Qué es |
|---|---|
| `CURRENCY_BACK` | URL base del backend de tasas, **sin** barra final. Los paths son absolutos (`/api/v1/...`), así que una barra final construiría `//api/v1/...` y el backend respondería un 308 en vez de servir el recurso. `Environment.normalizeBaseUrl` la recorta, pero la plantilla debe documentar el formato correcto. |

## Cuándo aplica

Cada vez que un cambio **agregue, renombre o elimine** una variable de entorno leída por `Environment` (URL de un backend nuevo, credenciales de un servicio, flags por entorno).

## Checklist obligatorio (en el MISMO PR)

Al tocar una variable de entorno, **todos** estos artefactos deben quedar consistentes:

1. **`Environment`** (`lib/config/enviroment/enviroment.dart`): declara el getter que la lee. Ningún otro archivo llama a `dotenv.env[...]` directamente — si un widget o un datasource lee el `.env` por su cuenta, el contrato deja de estar en un solo sitio.
2. **`.env.example`**: agrega/renombra/elimina la clave. Sus claves deben **coincidir exactamente** con las que lee `Environment` (ni de más ni de menos). **Nunca subas URLs reales, IPs de despliegue ni secretos**: usa siempre un placeholder genérico (ej. `https://tu-backend.example.com`). Los valores reales viven solo en `.env` (gitignored) y en las variables de entorno del CI.
3. **README** (sección "Configuración de Variables de Entorno"): documenta la variable —qué es y qué formato espera—, con el mismo placeholder que en `.env.example`.
4. **`codemagic.yaml`**: el paso `Crear .env` escribe el archivo en el runner a partir de variables del grupo de Codemagic:
   ```yaml
   - name: Crear .env
     script: echo "CURRENCY_BACK=$CURRENCY_BACK" > .env
   ```
   Una variable nueva debe añadirse **a ese script en todos los workflows** (Android, iOS y el combinado) **y** al grupo de variables en la consola de Codemagic. Si falta, el build compila pero la app se distribuye sin configuración. Menciónalo en la descripción del PR.
5. **Validación al arrancar**: si la variable es indispensable para que la app funcione, valídala al inicio y falla de forma explícita (o degrada con un mensaje claro), en vez de dejar que la pantalla quede vacía sin explicación.

> Los valores de tipo "constante de código" (no secretos, iguales en todos los entornos) **no** van en env vars: van en `Constants` — ver `constants-centralization.md`.

## Verificación rápida

`.env.example` no debe quedar ignorado por `.gitignore` (los patrones `.env` y `*.env` **no** lo cubren, pero conviene comprobarlo). Verifica que sea rastreable y que sus claves cuadren con `Environment`:

```bash
git check-ignore -v .env.example || echo ".env.example es rastreable ✅"
grep -o "dotenv.env\['[A-Z_]*'\]" lib/config/enviroment/enviroment.dart
grep -oE '^[A-Z_]+' .env.example
```

Ambas listas deben coincidir.

## Nunca

- Commitear `.env` (está en `.gitignore`).
- Poner una URL real de backend o una IP de despliegue en `.env.example`, en el README o en un comentario del código.
- Hardcodear la URL del backend como fallback en el código "para que funcione en local": deja la app publicando una dirección privada en el binario.
