// Catppuccin Mocha theme — enhanced with show rules
// Add to the top of your document:
//   #import "catppuccin.typ": apply, flavors
//   #show: apply.with(flavors.mocha)

#import "@preview/catppuccin:1.1.0": catppuccin, flavors

#let apply(flavor, body) = {
  // ── Base page + text from official package ──────────────
  show: catppuccin.with(flavor, code-syntax: true)
  let c = flavor.colors

  // ── Text defaults ──────────────────────────────────────
  set text(
    font: ("Libertinus Serif", "Liberation Serif", "FreeSerif", "serif"),
    size: 11pt,
  )

  // ── Headings ───────────────────────────────────────────
  show heading.where(level: 1): it => {
    v(0.4em)
    text(size: 1.6em, weight: "bold", fill: c.mauve.rgb, it.body)
    v(0.15em)
    line(length: 100%, stroke: (paint: c.surface1.rgb, thickness: 1pt))
    v(0.3em)
  }

  show heading.where(level: 2): it => {
    v(0.3em)
    text(size: 1.25em, weight: "semibold", fill: c.blue.rgb, it.body)
    v(0.2em)
  }

  show heading.where(level: 3): it => {
    v(0.2em)
    text(size: 1.1em, weight: "semibold", fill: c.teal.rgb, it.body)
    v(0.1em)
  }

  // ── Bold / Italic ─────────────────────────────────────
  show strong: it => text(fill: c.peach.rgb, weight: "bold", it.body)
  show emph:   it => text(fill: c.green.rgb, style: "italic", it.body)

  // ── Links ─────────────────────────────────────────────
  show link: it => text(fill: c.sapphire.rgb, it.body)

  // ── Lists & Enums ─────────────────────────────────────
  set list(marker: text(fill: c.mauve.rgb)[•])
  set enum(numbering: n => text(fill: c.mauve.rgb)[#n.])

  // ── Inline code ───────────────────────────────────────
  show raw.where(block: false): it => {
    text(
      font: ("Iosevka Nerd Font", "Iosevka", "Fira Code", "monospace"),
      fill: c.pink.rgb,
      size: 0.95em,
      it
    )
  }

  // ── Code blocks ───────────────────────────────────────
  show raw.where(block: true): it => {
    block(
      fill: c.crust.rgb,
      stroke: (paint: c.surface1.rgb, thickness: 0.5pt),
      radius: 6pt,
      inset: 10pt,
      width: 100%,
    )[#text(
      font: ("Iosevka Nerd Font", "Iosevka", "Fira Code", "monospace"),
      size: 0.9em,
      it
    )]
  }

  // ── Tables ────────────────────────────────────────────
  set table(
    stroke: c.surface1.rgb,
    fill: (x, y) => if y == 0 { c.surface0.rgb } else { none },
    inset: 7pt,
  )
  show table.cell.where(y: 0): set text(weight: "bold", fill: c.mauve.rgb)

  // ── Blockquotes ───────────────────────────────────────
  show quote: it => {
    block(
      fill: c.surface0.rgb,
      stroke: (left: (paint: c.lavender.rgb, thickness: 3pt)),
      inset: (left: 14pt, right: 10pt, top: 8pt, bottom: 8pt),
      radius: 4pt,
      it.body
    )
  }

  // ── Captions ──────────────────────────────────────────
  show figure.caption: set text(fill: c.subtext0.rgb, size: 0.9em)

  // ── Math ──────────────────────────────────────────────
  show math.equation: set text(fill: c.text.rgb)

  body
}
