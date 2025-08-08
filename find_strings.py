import sys
import re
from collections import Counter

def lese_prg_strings(dateiname):
    with open(dateiname, "rb") as f:
        daten = f.read()

    # Die ersten 2 Bytes sind die Ladeadresse (z.B. $0801)
    programm_daten = daten[2:]

    # Bytes zu PETSCII/ASCII konvertieren (hier einfache 1:1-Umwandlung für sichtbare Zeichen)
    text = ''.join(chr(b) if 32 <= b <= 126 else '\n' for b in programm_daten)

    # Mit Regex alle Strings zwischen Anführungszeichen finden
    strings = re.findall(r'"([^"]*)"', text)

    return strings

def main():
    if len(sys.argv) < 2:
        print("Benutzung: python find_strings.py <programm.prg>")
        sys.exit(1)

    dateiname = sys.argv[1]
    strings = lese_prg_strings(dateiname)

    if not strings:
        print("Keine Strings gefunden.")
        return

    # Zähle, wie oft jeder String vorkommt
    zaehler = Counter(strings)

    # Sortiere nach Häufigkeit (absteigend)
    for s, anzahl in zaehler.most_common():
        print(f"{anzahl}x  \"{s}\"")

if __name__ == "__main__":
    main()
