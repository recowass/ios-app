# Versión v6 probada en iOS 9.3.5

La instalación y el funcionamiento en el iPad del propietario están confirmados con jailbreak y AppSync Unified. [Resultado, descarga y SHA-256](TESTED-v6.md).

# Los Olmos: visor web para iOS 9

Esta variante independiente conserva las fuentes originales de HA Dashboard,
pero compila solamente `OlmosKiosk/main.m`. No ejecuta el cliente nativo de Home
Assistant, no registra dispositivos y no incluye cámaras, micrófono ni tokens.
Abre el panel existente con WKWebView. La URL se introduce en el primer arranque
y se guarda en el dispositivo; no se publica en este repositorio.

## Compatibilidad real

- iOS mínimo 9.0 tanto en Info.plist como en cada ejecutable Mach-O.
- armv7 para dispositivos de 32 bits y arm64 para los de 64 bits.
- Sólo APIs disponibles en iOS 9; el compilador rechaza disponibilidad sin proteger.
- Se compila con las cabeceras del SDK actual y se enlaza con los stubs legacy
  Xcode 13.2.1 publicados por el proyecto original, comprobando su SHA-256.
- WKWebView usa el WebKit instalado: no convierte JavaScript o CSS modernos en
  compatibles. Una compilación correcta no prueba funcionamiento en iOS 9.3.5.
- No se promete compatibilidad con el frontend moderno completo de Home Assistant.
  El contenido del panel local debe admitir el WebKit antiguo.
- La verificación automática comprueba ZIP, arquitecturas, mínimo de cada slice
  y punto de entrada armv7. La prueba física de instalación y apertura del panel en iOS 9.3.5 fue
  confirmada por el propietario para la v6 (véase TESTED-v6.md).

## Generar la IPA desde Windows

1. Abre Actions en este fork y selecciona **Los Olmos iOS 9 IPA**.
2. En la rama `olmos-kiosk`, los cambios de código generan una compilación.
   También se puede usar **Run workflow**, eligiendo esa rama.
3. Espera a que el trabajo termine correctamente y descarga **Los-Olmos-iOS9-IPA**.
4. Extrae `Los-Olmos-iOS9-unsigned.ipa` del ZIP. Es una IPA sin firma: todavía no
   puede instalarse directamente ni equivale a una distribución Ad Hoc firmada.
5. Usa [Sideloadly oficial](https://sideloadly.io/) en Windows para firmar e
   instalar con tu Apple ID. Conecta el iPad por USB y acepta Confiar en el ordenador.
   Si no se detecta, sigue los requisitos de iTunes/iCloud indicados por Sideloadly.
6. Arrastra la IPA a Sideloadly, elige el dispositivo, introduce tu Apple ID e
   inicia la instalación. Introduce credenciales sólo en la aplicación oficial;
   este repositorio y GitHub Actions no las necesitan.
7. En iOS: Ajustes > General > Perfiles / Gestión de dispositivos, confía en tu
   perfil. Abre Los Olmos y pega la URL del panel. Usa la misma red local.
8. Prueba casa, garaje, orientación y los controles del panel. No actives
   dispositivos para verificar sólo la visualización.

Una cuenta gratuita requiere renovar la firma cada siete días, según la
[documentación de Sideloadly](https://sideloadly.io/faq). Mantén el mismo Apple ID
y bundle ID al renovar para conservar los datos locales.

## Alcance

El código sólo carga la página configurada. Los controles de esa página conservan
su comportamiento original y pueden enviar órdenes a Home Assistant cuando el
usuario los pulsa. No hay cambios en el servidor ni en sus archivos.

Fuentes: [proyecto original](https://github.com/ha-dashboard/ios-app),
[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview),
[WebKit](https://webkit.org/debugging-webkit/).

## Corrección del paquete para firmadores de Windows

La revisión inicial no incluía `LC_CODE_SIGNATURE` en ninguno de los dos slices.
Sideloadly rechazó el ejecutable durante la firma (error -18). Se añade una firma
ad-hoc con hashes SHA-1 y SHA-256 antes de empaquetar, se verifica con codesign
para todas las arquitecturas y se exige la estructura de firma en el verificador
Mach-O. Esta firma de preparación NO es una firma de desarrollo ni un perfil
válido de Apple. Sideloadly debe sustituirla usando el Apple ID del usuario.
La instalación real de la v6 está confirmada en el iPad del propietario con iOS 9.3.5, jailbreak y AppSync Unified; consulta TESTED-v6.md.
