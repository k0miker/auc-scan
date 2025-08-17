# Auction House Value Highlighter Classic

Ein World of Warcraft Classic Addon für Version 1.12, das Items im Auktionshaus hervorhebt, die unter dem Vendor-Verkaufspreis liegen.

## Features

- **Automatische Erkennung**: Erkennt automatisch Items, die unter dem Vendor-Verkaufspreis angeboten werden
- **Visuelle Hervorhebung**: Hebt profitable Items mit einer roten Transparenz hervor
- **Detaillierte Tooltips**: Zeigt potentiellen Gewinn und Gewinnprozentsatz an
- **Ton-Benachrichtigungen**: Spielt einen Sound ab, wenn profitable Items gefunden werden
- **Anpassbare Einstellungen**: Konfigurierbare Mindestgewinn-Prozentsätze und absolute Beträge

## Installation

1. Kopiere den Ordner in dein WoW Classic AddOns Verzeichnis:
   `World of Warcraft\_classic_\Interface\AddOns\`

2. Starte WoW Classic und aktiviere das Addon im AddOn-Menü

## Verwendung

Das Addon funktioniert automatisch, sobald du das Auktionshaus öffnest und nach Items suchst.

### Slash-Befehle

- `/ahvh` oder `/auctionhighlight` - Zeigt die Hilfe an
- `/ahvh toggle` - Aktiviert/deaktiviert das Highlighting
- `/ahvh sound` - Schaltet Ton-Benachrichtigungen ein/aus
- `/ahvh tooltip` - Schaltet Tooltip-Informationen ein/aus
- `/ahvh profit <zahl>` - Setzt den Mindestgewinn-Prozentsatz (Standard: 10%)
- `/ahvh minprofit <geld>` - Setzt den Mindestgewinn als absolute Summe (z.B. "10s", "1g50s")
- `/ahvh status` - Zeigt aktuelle Einstellungen an
- `/ahvh help` - Zeigt die Hilfe an

### Beispiele

```bash
/ahvh profit 20           # Nur Items mit mindestens 20% Gewinn hervorheben
/ahvh minprofit 10s       # Nur Items mit mindestens 10 Silber Gewinn
/ahvh minprofit 1g50s     # Nur Items mit mindestens 1 Gold 50 Silber Gewinn
/ahvh toggle              # Addon ein-/ausschalten
/ahvh status              # Aktuelle Einstellungen anzeigen
```

## Wie es funktioniert

1. Das Addon überwacht die Auktionshaus-Suchergebnisse
2. Für jedes Item wird der Vendor-Verkaufspreis ermittelt
3. Items, die unter diesem Preis angeboten werden, werden hervorgehoben
4. Der potentielle Gewinn wird in den Tooltips angezeigt

## Einstellungen

Das Addon speichert deine Einstellungen automatisch. Folgende Optionen sind verfügbar:

- **enabled**: Addon aktiviert/deaktiviert
- **highlightColor**: Farbe der Hervorhebung
- **minProfitPercent**: Mindestgewinn-Prozentsatz (Standard: 10%)
- **minProfitCopper**: Mindestgewinn als absolute Summe in Kupfer (Standard: 1000 = 10 Silber)
- **enableSound**: Ton-Benachrichtigungen
- **enableTooltip**: Tooltip-Informationen

### Gewinn-Filter

Das Addon berücksichtigt **beide** Kriterien gleichzeitig:

1. **Prozentuale Mindestrendite** (Standard: 10%)
2. **Absolute Mindestgewinnsumme** (Standard: 10 Silber)

Ein Item wird nur hervorgehoben, wenn **beide** Bedingungen erfüllt sind.

## Kompatibilität

- **Entwickelt für WoW Classic 1.12** (Vanilla)
- **Interface Version: 11200**
- **Funktioniert mit Privatservern** die Classic 1.12 API verwenden
- **Getestet mit dem klassischen Auktionshaus-System**

## Classic-spezifische Features

- Verwendet die Classic Auction House API (`GetAuctionItemInfo`, `GetAuctionItemLink`)
- Kompatibel mit dem traditionellen Browse-System
- Funktioniert mit `NUM_BROWSE_TO_DISPLAY` Items pro Seite
- Verwendet Classic Event-Handling (`this`, `arg1`, etc.)

## Tipps für Classic

1. **Stapelgrößen beachten**: Das Addon berücksichtigt automatisch Stapelgrößen
2. **Markt-Timing**: Beste Ergebnisse meist zu Stoßzeiten und Raid-Tagen
3. **Server-Economy**: Classic-Server haben oft unterschiedliche Wirtschaften
4. **Vendor-Runs**: Besonders profitabel für Vendor-Runs und Disenchanting
5. **Limited Supply**: Classic Items sind oft rarer, höhere Gewinne möglich

## Classic-spezifische Befehle

Alle Befehle funktionieren wie in Retail, aber mit Classic-spezifischen Ausgaben:

```bash
/ahvh minprofit 5s        # Für Classic oft niedrigere Beträge sinnvoll
/ahvh profit 25           # Höhere Prozentsätze wegen volatiler Preise
/ahvh status              # Zeigt Classic-optimierte Einstellungen
```

## Fehlerbehebung

Falls das Addon nicht funktioniert:

1. Überprüfe, ob es im AddOn-Menü aktiviert ist
2. Stelle sicher, dass du im Auktionshaus bist
3. Verwende `/ahvh toggle` um es zu aktivieren
4. Überprüfe die Interface-Version in der .toc Datei

## Haftungsausschluss

Dieses Addon dient nur zur Information. Marktpreise können stark schwanken, und es gibt keine Garantie für Gewinne.

## Support

Bei Problemen oder Verbesserungsvorschlägen, erstelle ein Issue oder kontaktiere den Entwickler.

---

**Viel Erfolg beim Goldmaking!** 💰
