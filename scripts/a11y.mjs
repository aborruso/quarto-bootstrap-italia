// Controllo di accessibilità delle pagine generate.
// Uso: node scripts/a11y.mjs http://localhost:8080/index.html [altre pagine…]
// Esce con codice 1 se trova violazioni WCAG 2.1 AA.

import { chromium } from 'playwright'
import AxeBuilder from '@axe-core/playwright'

const pagine = process.argv.slice(2)
if (pagine.length === 0) {
  console.error('Nessuna pagina da controllare.')
  process.exit(2)
}

const browser = await chromium.launch()
// axe-core/playwright richiede una pagina creata da un contesto, non da browser.newPage()
const contesto = await browser.newContext()
let violazioni = 0

for (const url of pagine) {
  const pagina = await contesto.newPage()
  await pagina.goto(url, { waitUntil: 'networkidle' })

  const esito = await new AxeBuilder({ page: pagina })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .analyze()

  if (esito.violations.length === 0) {
    console.log(`ok      ${url}`)
  } else {
    violazioni += esito.violations.length
    console.log(`FALLITO ${url}`)
    for (const v of esito.violations) {
      console.log(`        ${v.id} (${v.impact}) — ${v.help}`)
      for (const nodo of v.nodes.slice(0, 3)) {
        console.log(`          ${nodo.target.join(', ')}`)
      }
    }
  }
  await pagina.close()
}

await browser.close()
process.exit(violazioni > 0 ? 1 : 0)
