# LMB Park Factors Report

## Estructura del proyecto

```
lmb_park_factors/
├── lmb_park_factors.qmd   ← reporte principal
├── custom.scss            ← tema visual
└── data/
    ├── park_factors_career.csv
    ├── venue_batting_profile_career.csv
    ├── venue_batted_ball_career.csv
    ├── pf_batside_career.csv
    └── venue_batted_ball_by_batside.csv
```

## Paquetes R requeridos

```r
install.packages(c(
  "tidyverse",
  "gt",
  "gtExtras",
  "ggtext",
  "scales",
  "glue",
  "ggrepel"
))
```

## Renderizar

```bash
# Desde la carpeta del proyecto:
quarto render lmb_park_factors.qmd

# Output: lmb_park_factors.html (self-contained, ~3-5MB)
```

## Secciones del reporte

1. **Resumen ejecutivo** — KPI cards globales
2. **Park Factors vista global** — Bubble chart HR vs Carreras + tabla completa
3. **Perfil ofensivo** — Slash line, temperatura vs OPS, condiciones de juego
4. **Batted Ball profile** — Trayectorias, HR/FB vs Hit Rate
5. **Bat Side analysis** — Ventaja zurdo vs derecho por parque
6. **Compatibilidad jugador-parque** — Heatmap power/contact/pitcher
7. **Ficha por equipo** — Cards individuales auto-generados para los 20 equipos
