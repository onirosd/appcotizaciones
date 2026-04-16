# Resumen de Historial de PowerShell

Fecha: 2026-04-16  
Ruta de trabajo: `d:\apps\v2\appcotizaciones`

## 1) Fuente de historial detectada

- Archivo persistente de PSReadLine:
  - `C:\Users\User\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`
- Total de lineas en historial persistente: **8339**

## 2) Historial de sesion actual

- `Get-History` en la sesion actual no devolvio entradas visibles al momento de ejecutar la consulta.
- Esto es normal cuando el historial relevante viene de sesiones anteriores y se guarda en `ConsoleHost_history.txt`.

## 3) Top comandos mas repetidos (historial persistente)

1. `clear` -> 1477
2. `npm run dev` -> 510
3. `git add .` -> 359
4. `git status` -> 342
5. `./gradlew clean` -> 336
6. `php artisan serve` -> 322
7. `./gradlew build` -> 311
8. `git push origin main` -> 224
9. `cd vue` -> 172
10. `npm run build` -> 159
11. `fvm flutter run` -> 142
12. `flutter pub get` -> 139
13. `git push` -> 137
14. `flutter clean` -> 133
15. `npm install` -> 104

## 4) Comandos recientes relevantes (muestra)

Se detectaron en historial persistente (muestra parcial):

- `flutter analyze --suggestions`
- `flutter analyze`
- `cd D:\apps\appcotizaciones`
- `dart analyze lib/features/meetings/presentation/screens/ ...`
- `flutter analyze --no-fatal-infos 2>&1 | Select-String ...`
- `flutter analyze lib/features/meetings/presentation/screens/option9/ ...`

## 5) Comandos usados para generar este resumen

```powershell
Get-History | Select-Object Id, StartExecutionTime, EndExecutionTime, CommandLine
(Get-PSReadLineOption).HistorySavePath
$p=(Get-PSReadLineOption).HistorySavePath; Get-Content $p | Measure-Object -Line
$p=(Get-PSReadLineOption).HistorySavePath; Get-Content $p -Tail 200
$p=(Get-PSReadLineOption).HistorySavePath; Get-Content $p | Group-Object | Sort-Object Count -Descending | Select-Object -First 40 Count,Name
$p=(Get-PSReadLineOption).HistorySavePath; Get-Content $p | Select-String -Pattern 'appcotizaciones|SyncBillQuotation|flutter analyze|dart analyze|rg --files|Get-History|ConsoleHost_history' | Select-Object -Last 80
```

## 6) Nota operativa

Si quieres capturar tambien salida completa y errores (no solo comandos), usa transcripcion:

```powershell
Start-Transcript -Path "$env:USERPROFILE\Desktop\ps_log.txt" -Append
# ...trabajo normal...
Stop-Transcript
```

