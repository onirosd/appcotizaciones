# AppCotizaciones

Aplicacion movil Flutter para gestion de cotizaciones, recibos y sincronizacion de datos comerciales.

## Descripcion General

Este proyecto permite:
- Gestionar cotizaciones y recibos desde movil.
- Trabajar con estados de pre-proceso, pendiente de sincronizacion y sincronizado.
- Sincronizar datos maestros y transaccionales con servicios remotos.

> Base del README antiguo: este proyecto nace como "A new Flutter project" y mantiene recursos oficiales de Flutter para onboarding.

## Recursos Iniciales (Flutter)

Si es tu primer proyecto Flutter, estos recursos siguen siendo utiles:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

## Apartado Tecnico

### Stack Principal
- Framework: Flutter
- Lenguaje: Dart
- Estado de null safety: proyecto legado con dependencias mixtas
- Persistencia local: `sqflite`
- Estado global/DI simple: `provider`
- HTTP: `http`

### Versiones Reales del Proyecto (actual)

Versiones tomadas de la configuracion del repositorio y SDK local del proyecto:

- Flutter SDK: `3.10.5`
- Dart SDK: `3.0.5`
- DevTools: `2.23.1`
- Restriccion de SDK en `pubspec.yaml`: `>=3.0.5 <4.0.0`
- Android Gradle Plugin (AGP): `7.3.0` (`android/build.gradle`)
- Kotlin Gradle Plugin: `1.8.0` (`android/build.gradle`)
- Gradle Wrapper: `7.5` (`android/gradle/wrapper/gradle-wrapper.properties`)
- Java target/source en app: `11` (`android/app/build.gradle`)
- Android `compileSdkVersion`: definido por Flutter (`flutter.compileSdkVersion`)
- Android `minSdkVersion`: definido por Flutter (`flutter.minSdkVersion`)
- Android `targetSdkVersion`: definido por Flutter (`flutter.targetSdkVersion`)

### Nota de compatibilidad importante

Para evitar conflictos por instalaciones globales de Flutter, este proyecto debe ejecutarse con el SDK local:
- `D:\apps\v2\appcotizaciones\.fvm\flutter_sdk`

Si se ejecuta con otro Flutter global (mas nuevo), pueden aparecer errores de Gradle/Kotlin no relacionados al codigo funcional de la app.

## Reglas Funcionales de Estados

### Estados generales (`state`)
- `0`: Pre Procesado
- `1`: Procesado pendiente de sincronizar
- `2`: Procesado sincronizado
- `5`: Actualizacion del supervisor. Si `updateflg == 1`, esos registros actualizan en movil con estado `2`.

### Customer (`flg_sinc`)
- `0`: Pendiente de sincronizar en movil
- `2`: Sincronizado con exito en nube y movil

Precaucion:
- Evitar enviar customers con `codigo = 0` desde base de datos, porque puede generar duplicados en movil cuando se recarga informacion al iniciar sesion.

### Cotizaciones y Recibos
- Registros con `updateflg != -1` y/o `flgSync != -1` se consideran pendientes de sincronizacion.

## Comandos para Levantar el Proyecto

## 1) Validar version correcta (recomendado)

```powershell
.\.fvm\flutter_sdk\bin\flutter.bat --version
```

Debe mostrar Flutter `3.10.5` y Dart `3.0.5`.

## 2) Instalar dependencias

```powershell
.\.fvm\flutter_sdk\bin\flutter.bat pub get
```

## 3) Ejecutar en modo debug

```powershell
.\.fvm\flutter_sdk\bin\flutter.bat run --enable-software-rendering
```

Alternativa con script helper:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_flutter_3105.ps1
```

## 4) Generar APK

APK debug:
```powershell
.\.fvm\flutter_sdk\bin\flutter.bat build apk --debug --no-sound-null-safety
```

APK release:
```powershell
.\.fvm\flutter_sdk\bin\flutter.bat build apk
```

Salida esperada del APK:
- `build\app\outputs\flutter-apk\app-debug.apk`
- `build\app\outputs\flutter-apk\app-release.apk`

## Configuracion Android (referencia rapida)

- Archivo AGP/Kotlin: `android/build.gradle`
- Archivo modulo app Android: `android/app/build.gradle`
- Wrapper Gradle: `android/gradle/wrapper/gradle-wrapper.properties`
- SDK Flutter usado por Android: `android/local.properties` (`flutter.sdk=...`)

## Troubleshooting rapido

- Si `flutter run` falla con plugin loader/Gradle:
  - Verificar que se usa `.\.fvm\flutter_sdk\bin\flutter.bat` y no `flutter` global.
- Si aparecen mensajes de Kotlin incompatibles pero el APK se genera:
  - Revisar primero version de Flutter activa.
  - Limpiar y reconstruir con SDK local del proyecto.
