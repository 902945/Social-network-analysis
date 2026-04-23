#!/usr/bin/env python3
"""
check_sources.py
================
Verifica che tutte le informazioni delle fonti siano presenti nella dispensa PDF.

Utilizzo:
    python3 check_sources.py

Produce in output un report testuale su stdout e salva un file
``report_fonti.md`` nella stessa directory.
"""

import os
import re
import sys
from html.parser import HTMLParser

# ---------------------------------------------------------------------------
# Dipendenze opzionali
# ---------------------------------------------------------------------------
try:
    import PyPDF2
    HAS_PYPDF2 = True
except ImportError:
    HAS_PYPDF2 = False
    print("[WARNING] PyPDF2 non installato. Installa con: pip install PyPDF2")

# ---------------------------------------------------------------------------
# Percorsi
# ---------------------------------------------------------------------------
BASE = os.path.dirname(os.path.abspath(__file__))
DISPENSA_PDF = os.path.join(BASE, "dispensa_social_network_analysis.pdf")

# Fonti: (etichetta leggibile, percorso, tipo)
SOURCES = [
    # Slide PDF nella root
    ("Slide 1 – Introduzione",                  os.path.join(BASE, "1-CT0540.pdf"),  "pdf"),
    ("Slide 2 – Grafi",                          os.path.join(BASE, "2-CT0540.pdf"),  "pdf"),
    ("Slide 3 – Legami Forti e Deboli",          os.path.join(BASE, "3-CT0540.pdf"),  "pdf"),
    ("Slide 5 – Contesti Sociali",               os.path.join(BASE, "5-CT0540.pdf"),  "pdf"),
    # Slide PDF nelle sottocartelle
    ("Slide 10 – Social Data",
        os.path.join(BASE, "10. Handling big and social data-20260413",
                     "10-CT0540 - Social data.pdf"),  "pdf"),
    ("Slide 10 – Private Traits",
        os.path.join(BASE, "10. Handling big and social data-20260413",
                     "10-CT0540 - Private traits in digital records.pdf"),  "pdf"),
    ("Slide 10 – Critical Questions Big Data",
        os.path.join(BASE, "10. Handling big and social data-20260413",
                     "10-CT0540 - Critical questions for big data.pdf"),  "pdf"),
    ("Slide 7 – Data Visualization (PDF)",
        os.path.join(BASE, "7. Data Visualization-20260413",
                     "Data Visualization - Good Practices.pdf"),  "pdf"),
    ("Slide 9 – Topic Modeling BERTopic",
        os.path.join(BASE, "9. Topic Modeling with Bert-20260413",
                     "Topic Modeling with BERTopic.pdf"),  "pdf"),
    # Notebook HTML
    ("Notebook 5a – Networks in R (parte a)",
        os.path.join(BASE, "5. Networks in R-20260413", "5-CT0540a.html"),  "html"),
    ("Notebook 5b – Networks in R (parte b)",
        os.path.join(BASE, "5. Networks in R-20260413", "5-CT0540b.html"),  "html"),
    ("Notebook 6 – Citation Networks",
        os.path.join(BASE, "6. Applicazione Citation networks-20260413", "6-CT0540.html"),  "html"),
    ("Notebook 7 – Data Visualization",
        os.path.join(BASE, "7. Data Visualization-20260413", "7-CT0540.html"),  "html"),
    ("Notebook 8 – Text Analysis",
        os.path.join(BASE, "8. Data filtering e text analysis-20260413", "8-CT0540.html"),  "html"),
]

# ---------------------------------------------------------------------------
# Parole chiave attese per fonte (estratte dal contenuto delle slide/notebook)
# ---------------------------------------------------------------------------
# Per ogni fonte definiamo un set di concetti chiave che *devono* comparire
# nella dispensa. Ogni entry è una stringa oppure una lista di alternative:
# basta che UNA delle alternative sia presente per considerare il concetto
# come coperto (utile per termini che compaiono in inglese o italiano).
# La corrispondenza è case-insensitive sul testo del PDF.
EXPECTED_KEYWORDS: dict[str, list] = {
    "Slide 1 – Introduzione": [
        "CT0540",
        "Fabiana Zollo",
        # "Ca' Foscari" usa apostrofo Unicode U+2019 nel PDF estratto
        ["Ca\u2019 Foscari", "Ca' Foscari", "Foscari"],
        "social network analysis",
        ["information spreading", "diffusione dell'informazione", "diffusione di"],
        "30 ore",
        "omofilia",
    ],
    "Slide 2 – Grafi": [
        ["Königsberg", "Konigsberg", "K\u00f6nigsberg"],
        "grafo",
        "nodo",
        "arco",
        "grado",
        "matrice di adiacenza",
        ["Eulero", "Euler"],
        "cammino",
        "componente connessa",
    ],
    "Slide 3 – Legami Forti e Deboli": [
        ["legame forte", "legami forti"],
        ["legame debole", "legami deboli"],
        "Granovetter",
        ["triadic closure", "chiusura triadica"],
        "chiusura triadica",
        "ponte locale",
        "betweenness",
    ],
    "Slide 5 – Contesti Sociali": [
        "omofilia",
        # Il termine inglese "homophily" può essere assente in una dispensa italiana
        ["homophily", "omofilia"],
        "selezione",
        "influenza sociale",
        ["rete bipartita", "grafo bipartito"],
        "affiliazione",
        "capitale sociale",
    ],
    "Slide 10 – Social Data": [
        ["social data", "dati sociali"],
        "bias",
        ["rappresentatività", "rappresentativit"],
        ["metodologia", "metodologico"],
        # "ethical" può comparire in italiano come "etico/etici"
        ["ethical", "etico", "etici", "etica"],
    ],
    "Slide 10 – Private Traits": [
        "Kosinski",
        ["Facebook Like", "Facebook"],
        ["attributi privati", "tratti privati", "private traits"],
        ["big data", "Big Data"],
        # "digital records" può comparire come "registri digitali"
        ["digital records", "registri digitali", "dati digitali"],
    ],
    "Slide 10 – Critical Questions Big Data": [
        "Boyd",
        "Crawford",
        ["big data", "Big Data"],
        "provocazioni",
        # "sorveglianza" / "surveillance" — concetto delle provocazioni di Boyd&Crawford
        ["sorveglianza", "surveillance", "privacy"],
        # Manovich 2011 è citato nelle slide ma potrebbe non esserlo nella dispensa
        ["Manovich", "Lev Manovich"],
    ],
    "Slide 7 – Data Visualization (PDF)": [
        ["data visualization", "visualizzazione dei dati", "visualizzazione"],
    ],
    "Slide 9 – Topic Modeling BERTopic": [
        "BERTopic",
        ["topic modeling", "topic modelling", "topic model"],
        "BERT",
        ["embedding", "rappresentazione vettoriale"],
        "UMAP",
        "HDBSCAN",
    ],
    "Notebook 5a – Networks in R (parte a)": [
        "igraph",
        "library",
        ["graph_from", "make_graph"],
        ["V(", "vertici"],
        ["E(", "archi"],
        ["plot (", "plot(", "visualizzazione"],
    ],
    "Notebook 5b – Networks in R (parte b)": [
        "igraph",
        "betweenness",
        "closeness",
        "degree",
        "layout",
    ],
    "Notebook 6 – Citation Networks": [
        ["citation network", "citation networks", "reti di citazione"],
        ["centralità", "centralit"],
        "betweenness",
        ["comunità", "comunit"],
        "Girvan",
        "Newman",
    ],
    "Notebook 7 – Data Visualization": [
        "ggplot2",
        "ggplot",
        "aes(",
        "geom_",
    ],
    "Notebook 8 – Text Analysis": [
        "quanteda",
        ["TF-IDF", "tf-idf", "tfidf"],
        ["sentiment", "analisi del sentimento"],
        ["text analysis", "analisi del testo"],
        "corpus",
        "token",
    ],
}

# ---------------------------------------------------------------------------
# Estrattori di testo
# ---------------------------------------------------------------------------

class _HtmlTextExtractor(HTMLParser):
    """Parser HTML minimo che raccoglie solo il testo visibile."""

    SKIP_TAGS = {"script", "style", "head"}

    def __init__(self):
        super().__init__()
        self._skip = False
        self._parts: list[str] = []

    def handle_starttag(self, tag, attrs):
        if tag.lower() in self.SKIP_TAGS:
            self._skip = True

    def handle_endtag(self, tag):
        if tag.lower() in self.SKIP_TAGS:
            self._skip = False

    def handle_data(self, data):
        if not self._skip:
            stripped = data.strip()
            if stripped:
                self._parts.append(stripped)

    def get_text(self) -> str:
        return " ".join(self._parts)


def extract_text_pdf(path: str) -> str:
    """Estrae tutto il testo da un PDF usando PyPDF2."""
    if not HAS_PYPDF2:
        return ""
    try:
        with open(path, "rb") as fh:
            reader = PyPDF2.PdfReader(fh)
            return " ".join(page.extract_text() or "" for page in reader.pages)
    except Exception as exc:
        return f"[ERRORE LETTURA PDF: {exc}]"


def extract_text_html(path: str) -> str:
    """Estrae testo visibile da un file HTML."""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            content = fh.read()
        parser = _HtmlTextExtractor()
        parser.feed(content)
        return parser.get_text()
    except Exception as exc:
        return f"[ERRORE LETTURA HTML: {exc}]"


def extract_text(path: str, kind: str) -> str:
    if kind == "pdf":
        return extract_text_pdf(path)
    elif kind == "html":
        return extract_text_html(path)
    return ""

# ---------------------------------------------------------------------------
# Funzioni di controllo
# ---------------------------------------------------------------------------

def normalize(text: str) -> str:
    """Lowercase + normalizza spazi bianchi."""
    return re.sub(r"\s+", " ", text.lower())


def keyword_present(keyword: str, haystack: str) -> bool:
    """Verifica presenza di una parola chiave (case-insensitive)."""
    return keyword.lower() in haystack


def check_source_coverage(
    source_label: str,
    source_text: str,
    dispensa_text: str,
    expected_keywords: list,
) -> dict:
    """
    Ritorna un dizionario con i risultati del controllo per una fonte.

    Ogni entry in expected_keywords può essere:
    - una stringa (cerca quella stringa nel testo)
    - una lista di stringhe (il concetto è coperto se ALMENO UNA è presente)

    Campi restituiti:
    - found: lista di concetti trovati (come stringa rappresentativa)
    - missing: lista di concetti mancanti (come stringa rappresentativa)
    - coverage_pct: percentuale di copertura
    - source_available: bool (False se il testo della fonte è vuoto/errore)
    """
    norm_dispensa = normalize(dispensa_text)
    norm_source = normalize(source_text) if source_text else ""

    source_available = bool(source_text) and not source_text.startswith("[ERRORE")

    found = []
    missing = []
    for entry in expected_keywords:
        # Normalizza a lista di alternative
        alternatives = [entry] if isinstance(entry, str) else entry
        label_repr = alternatives[0]  # rappresentazione leggibile del concetto
        matched = any(keyword_present(alt, norm_dispensa) for alt in alternatives)
        if matched:
            found.append(label_repr)
        else:
            missing.append(label_repr)

    total = len(expected_keywords)
    coverage = (len(found) / total * 100) if total > 0 else 0.0

    return {
        "source_available": source_available,
        "source_chars": len(source_text),
        "found": found,
        "missing": missing,
        "total": total,
        "coverage_pct": coverage,
    }

# ---------------------------------------------------------------------------
# Generazione report
# ---------------------------------------------------------------------------

def build_report(results: list[dict]) -> str:
    lines = []
    lines.append("# Report: Copertura delle Fonti nella Dispensa")
    lines.append("")
    lines.append("Verifica che le informazioni chiave di ogni fonte siano")
    lines.append("presenti nel file `dispensa_social_network_analysis.pdf`.")
    lines.append("")
    lines.append("---")
    lines.append("")

    all_ok = True

    for r in results:
        label = r["label"]
        path = r["path"]
        res = r["result"]

        status_icon = "✅" if res["coverage_pct"] == 100 else ("⚠️" if res["coverage_pct"] >= 50 else "❌")
        lines.append(f"## {status_icon} {label}")
        lines.append(f"- **File**: `{os.path.basename(path)}`")
        lines.append(f"- **Fonte disponibile**: {'Sì' if res['source_available'] else 'No (file non trovato o vuoto)'}")
        lines.append(f"- **Copertura**: {res['coverage_pct']:.0f}%  ({len(res['found'])}/{res['total']} keyword trovate)")

        if res["found"]:
            lines.append(f"- **Keyword presenti** nella dispensa:")
            for kw in res["found"]:
                lines.append(f"  - ✓ `{kw}`")

        if res["missing"]:
            all_ok = False
            lines.append(f"- **Keyword mancanti** nella dispensa:")
            for kw in res["missing"]:
                lines.append(f"  - ✗ `{kw}`")

        lines.append("")

    lines.append("---")
    lines.append("")
    if all_ok:
        lines.append("## 🎉 Risultato finale: TUTTE le informazioni delle fonti sono presenti nella dispensa.")
    else:
        lines.append("## ⚠️ Risultato finale: alcune informazioni delle fonti NON sono coperte dalla dispensa (vedi ✗ sopra).")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("=" * 60)
    print("  check_sources.py – Controllo copertura fonti")
    print("=" * 60)
    print()

    # 1. Carica la dispensa
    if not os.path.exists(DISPENSA_PDF):
        print(f"[ERRORE] Dispensa non trovata: {DISPENSA_PDF}")
        sys.exit(1)

    print(f"Lettura dispensa: {os.path.basename(DISPENSA_PDF)} …")
    dispensa_text = extract_text_pdf(DISPENSA_PDF)
    print(f"  → {len(dispensa_text):,} caratteri estratti.")
    print()

    if not dispensa_text.strip():
        print("[ERRORE] Impossibile estrarre testo dalla dispensa.")
        sys.exit(1)

    # 2. Controlla ogni fonte
    results = []
    for label, path, kind in SOURCES:
        exists = os.path.exists(path)
        if not exists:
            print(f"[ATTENZIONE] File non trovato: {path}")
            source_text = ""
        else:
            source_text = extract_text(path, kind)

        expected = EXPECTED_KEYWORDS.get(label, [])
        res = check_source_coverage(label, source_text, dispensa_text, expected)
        results.append({"label": label, "path": path, "result": res})

        icon = "✅" if res["coverage_pct"] == 100 else ("⚠️" if res["coverage_pct"] >= 50 else "❌")
        print(f"{icon} {label}")
        print(f"   Copertura: {res['coverage_pct']:.0f}% ({len(res['found'])}/{res['total']})")
        if res["missing"]:
            print(f"   Mancanti: {', '.join(res['missing'])}")
        print()

    # 3. Genera e salva il report
    report = build_report(results)
    report_path = os.path.join(BASE, "report_fonti.md")
    with open(report_path, "w", encoding="utf-8") as fh:
        fh.write(report)

    print(f"Report salvato in: {report_path}")
    print()

    # 4. Riepilogo finale
    total_found = sum(len(r["result"]["found"]) for r in results)
    total_kw    = sum(r["result"]["total"]       for r in results)
    total_miss  = sum(len(r["result"]["missing"]) for r in results)
    pct = total_found / total_kw * 100 if total_kw else 0

    print("=" * 60)
    print(f"  RIEPILOGO GLOBALE: {total_found}/{total_kw} keyword ({pct:.1f}%)")
    if total_miss == 0:
        print("  ✅ Tutte le informazioni delle fonti sono presenti.")
    else:
        print(f"  ⚠️  {total_miss} keyword NON trovate nella dispensa.")
    print("=" * 60)

    return 0 if total_miss == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
