# Los Olmos v6 — probada en iPad con iOS 9.3.5

Estado: **funcionamiento confirmado por el propietario en su iPad físico el 16 de octubre de 2026**.

## Resultado confirmado

- Instalación de la app y apertura del panel local en iOS 9.3.5.
- Instalación mediante Sideloadly en modo **Ad-hoc sign**, con jailbreak y AppSync Unified activos.
- Versión v6 con iconos a escala 1.587 respecto al panel original y los estados verdes mostrados en amarillo.
- Tras probar esta IPA, el propietario confirmó: «funciona perfecta».
- Home Assistant y el panel alojado en el servidor no se modificaron; los ajustes visuales sólo los aplica la app.

La confirmación corresponde a este dispositivo y este panel. No supone una prueba exhaustiva de todos los controles, de otros modelos o de estabilidad prolongada.

## Descargar e instalar

[Descargar la IPA v6](releases/v6/Los-Olmos-iOS9-v6-iconos.ipa?raw=true).

Instalar mediante Sideloadly con **Ad-hoc sign** si el dispositivo ya tiene jailbreak y AppSync Unified. Mantener el mismo identificador de aplicación al actualizar para conservar los datos locales. El jailbreak debe estar activo; según el jailbreak, puede ser necesario reactivarlo tras reiniciar. Esta instalación con AppSync no depende del perfil gratuito de siete días de Apple.

En dispositivos sin jailbreak, esta prueba no valida una instalación permanente. La firma con Apple ID requiere su propio perfil y está sujeta a su caducidad.

## Identidad exacta del artefacto probado

- Archivo: `Los-Olmos-iOS9-v6-iconos.ipa`.
- Tamaño: 29.665 bytes.
- SHA-256: `a398877471d4e9f4d0dc79566a2b048d28e80fd0914388fa7d008fa50d4c9a7f`.
- Código compilado: `a78fe3f8b745ced13b669047681d1ed37686a2b0`.
- [Compilación verificada en GitHub Actions](https://github.com/recowass/ios-app/actions/runs/38970865540).
- Incluye armv7 y arm64; ambos ejecutables y el Info.plist tienen mínimo iOS 9.0.
- Firma ad-hoc comprobada en ambas arquitecturas; integridad y SHA-256 verificados también en Windows.

Se publica exactamente la IPA probada, sin recompilarla para esta publicación. No contiene URL privada, credenciales de Home Assistant ni credenciales de Apple.
