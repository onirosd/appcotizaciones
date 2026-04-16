# Radiografia Tecnica del Proyecto `appcotizaciones`

Fecha de analisis: 2026-04-15

## 1) Resumen Ejecutivo

`appcotizaciones` es una app Flutter multiplataforma orientada a trabajo comercial con operacion **offline-first** y sincronizacion con backend PHP.

La app:
- usa SQLite local precargada desde asset (`data/dbventas4.0.db`),
- permite crear/editar cotizaciones, recibos, clientes y galerias multimedia,
- sincroniza por reglas descargadas desde backend (`Conf_General`),
- mantiene estado de conectividad y sesion con `provider` + `shared_preferences`.

## 2) Estructura y Arquitectura

### Arranque y estado global
- Entry point: `lib/main.dart`
- Rutas: `lib/src/routes/routes.dart`
- Providers globales principales:
  - `AuthenticationProvider`
  - `LogoProvider`
  - `CustomerProvider`

### Capas del sistema
- **UI/Navegacion**: `lib/src/providers/*.dart` y `lib/src/screens/*.dart`
- **Estado**: `provider` (`ChangeNotifier`)
- **Datos locales**: `lib/src/modelscrud/*.dart` + `sqflite`
- **API remota**: `lib/src/api/*.dart`
- **Reglas de sincronizacion**: `lib/src/modelscrud/api.configGeneral_crt.dart`

## 3) Flujo Funcional Principal

### Login
Archivo clave: `lib/src/screens/login_screen.dart`

Durante login:
1. sincroniza empresas/usuarios (si hay internet),
2. valida credenciales contra DB local,
3. descarga/aplica reglas de configuracion por usuario,
4. decide si limpia/carga tablas principales,
5. sincroniza datos base (complementos, clientes/galeria, quo/bill),
6. guarda sesion en `SharedPreferences`.

### Home y sincronizacion
Archivo clave: `lib/src/providers/provider.home.dart`

Desde Home se ejecuta `SyncService.syncAll()` (`lib/src/services/sync_service.dart`), que agrupa subprocesos en paralelo:
- Subidas: clientes, recibos, cotizaciones, galerias.
- Luego: stock + sincronizacion de quo/bill.
- Finalmente: log de sync.

## 4) Modelo Offline/Sync (Estados)

El sistema usa banderas para saber que subir, que mostrar y que bloquear:

- `Customer.asyncFlag`
- `Quotation.updateflg` + `Quotation.state`
- `Billing.flgSync` + `Billing.flgState`
- `Gallery.flatEstado`

Estos flags gobiernan:
- pendientes de sincronizacion,
- filtro de listados,
- habilitacion de acciones UI,
- limpieza selectiva local previa a recarga.

## 5) Base de Datos Local

DB real verificada: `data/dbventas4.0.db`

Tablas relevantes detectadas:
- `Autentication`, `Company`, `Customer`
- `Quotation`, `QuotationProducts`
- `Billing`
- `Gallery`, `GalleryDetail`, `GalleryDetailSubtipos`
- `Conf_General`, `Sync_Log`
- tablas complementarias (`Bank`, `Currency`, `Delivery*`, etc.)

Observacion:
- El archivo `assets/db/dbventas.sql` no refleja completamente el esquema real actual; la fuente de verdad operativa es `data/dbventas4.0.db`.

## 6) Integraciones y Configuracion de Backend

Archivo: `lib/src/config/variables.dart`

Endpoints base:
- `DIR_PROD = http://suminox-001-site22.atempurl.com/`
- `DIR_DESA = http://suminox-001-site19.atempurl.com/`
- selector actual: `change = 'desa'`

Servicios consumidos (PHP):
- `listarAutentication.php`
- `listarCompany.php`
- `listarConfiguracion.php`
- `listarCustomer.php` / `insertarCustomer.php`
- `listarQuotation.php` / `insertarQuotation.php`
- `listarBilling.php` / `insertarBilling.php`
- `SyncBillQuotation.php`
- `uploadImagenes.php`

## 7) Hallazgos Tecnicos Relevantes

### A. Seguridad y red
- Comunicacion en **HTTP sin TLS** (sin HTTPS) en toda la capa API.

### B. Generacion de IDs
- IDs de documentos nuevos construidos con timestamp corto (`yyMMddkkmm`) + cliente.
- Riesgo de colision si hay operaciones cercanas en tiempo.

### C. SQL y mantenimiento
- Varias consultas SQL usan interpolacion directa de strings.
- Riesgo de errores y superficie de inyeccion (aunque entorno controlado local).

### D. Complejidad UI
- Providers/pantallas extremadamente grandes (varios >1000 lineas).
- Alta duplicacion de flujo entre archivos de cotizacion/recibo/galeria.

### E. Codigo legado/duplicado
Se detectaron archivos de soporte no productivos:
- `provider.customer.Quotation.copy-1`
- `provider.customer.Billing.confirm copy.dart`
- `provider.customer.gallery*.txt`
- `api.complementscustogalle-deprecate-1.txt`
- `api.upload_images - poc.txt`

## 8) Estado de Calidad (Verificacion Ejecutada)

Comandos ejecutados:
- `flutter analyze`
- `flutter test`

Resultados:
- `flutter analyze`: **2930 issues** (deuda tecnica alta; mayormente lints, estilo, imports sin uso, prints, nombres, widgets no const, etc.).
- `flutter test`: falla el test plantilla (`test/widget_test.dart`) porque no corresponde al flujo real de la app (test de contador default).

## 9) Riesgos Operativos

1. Dependencia fuerte de backend legacy HTTP.
2. Flujo de login y sync muy acoplado; dificil de aislar en pruebas.
3. Falta de pruebas automatizadas funcionales del dominio.
4. Alto costo de cambio por archivos gigantes con responsabilidades mezcladas.

## 10) Recomendaciones Priorizadas

### Prioridad alta
1. Migrar endpoints a HTTPS.
2. Reemplazar IDs temporales por UUID robusto.
3. Corregir test base y crear smoke tests reales de login/home/sync.
4. Extraer capa de servicios para reducir logica dentro de widgets/providers.

### Prioridad media
1. Parametrizar queries SQL y unificar acceso a DB.
2. Limpiar archivos legacy/duplicados para reducir ambiguedad.
3. Estandarizar manejo de errores/red (timeouts, retries, mensajes unificados).

### Prioridad baja
1. Reducir lints progresivamente por modulos criticos.
2. Mejorar convenciones de nombres y estructura de carpetas.

## 11) Archivos Clave para Futuras Consultas

- `lib/main.dart`
- `lib/src/screens/login_screen.dart`
- `lib/src/providers/provider.home.dart`
- `lib/src/services/sync_service.dart`
- `lib/src/modelscrud/api.configGeneral_crt.dart`
- `lib/src/helpers/database_helper.dart`
- `lib/src/modelscrud/configGeneral_crt.dart`
- `lib/src/config/variables.dart`

