/*
 * Ricerca full text per il formato bootstrap-italia-html.
 *
 * Quarto genera l'indice `search.json` per ogni sito, ma la sua interfaccia di
 * ricerca è legata al tema Bootstrap di Quarto, che qui è disattivato
 * (`theme: none`). Questo script consuma lo stesso indice e lo presenta con i
 * componenti di Bootstrap Italia.
 *
 * Si aggancia a qualunque elemento con l'attributo `data-bi-search`.
 */
;(function () {
  'use strict'

  var MAX_RESULTS = 20
  var docs = null
  var loading = null
  var modalEl = null
  var apertoDa = null

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
    })
  }

  // il percorso dell'indice è definito da uno <script> che Quarto inserisce
  // dopo questo file: va letto al momento dell'uso, non al caricamento
  function indexUrl() {
    return window.__BI_SEARCH_INDEX__ || 'search.json'
  }

  function loadIndex() {
    if (loading) return loading
    loading = fetch(indexUrl())
      .then(function (r) {
        if (!r.ok) throw new Error('indice non disponibile')
        return r.json()
      })
      .then(function (data) {
        docs = data
        return data
      })
    return loading
  }

  function score(doc, terms) {
    var title = (doc.title || '').toLowerCase()
    var section = (doc.section || '').toLowerCase()
    var text = (doc.text || '').toLowerCase()
    var total = 0
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i]
      var s = 0
      if (title.indexOf(t) !== -1) s += 10
      if (section.indexOf(t) !== -1) s += 5
      if (text.indexOf(t) !== -1) s += 1
      if (s === 0) return 0
      total += s
    }
    return total
  }

  function snippet(doc, terms) {
    var text = doc.text || ''
    var lower = text.toLowerCase()
    var pos = -1
    for (var i = 0; i < terms.length && pos === -1; i++) {
      pos = lower.indexOf(terms[i])
    }
    if (pos === -1) pos = 0
    var start = Math.max(0, pos - 60)
    var frammento = text.slice(start, start + 200).trim()
    return (start > 0 ? '… ' : '') + frammento + (start + 200 < text.length ? ' …' : '')
  }

  function search(query) {
    var terms = query.toLowerCase().split(/\s+/).filter(function (t) {
      return t.length > 1
    })
    if (!terms.length || !docs) return []
    return docs
      .map(function (doc) {
        return { doc: doc, score: score(doc, terms) }
      })
      .filter(function (r) {
        return r.score > 0
      })
      .sort(function (a, b) {
        return b.score - a.score
      })
      .slice(0, MAX_RESULTS)
      .map(function (r) {
        return { doc: r.doc, snippet: snippet(r.doc, terms) }
      })
  }

  function render(results, query, container) {
    if (!query) {
      container.innerHTML = ''
      return
    }
    if (!results.length) {
      container.innerHTML =
        '<p class="text-muted mb-0">Nessun risultato per «' + esc(query) + '».</p>'
      return
    }
    var base = indexUrl().replace(/search\.json$/, '')
    var html = ['<p class="text-muted">', results.length, ' risultati</p>', '<ul class="link-list">']
    results.forEach(function (r) {
      var titolo = r.doc.section ? r.doc.title + ' — ' + r.doc.section : r.doc.title
      html.push(
        '<li><a class="list-item" href="' + esc(base + r.doc.href) + '">',
        '<span class="fw-semibold">' + esc(titolo) + '</span>',
        '<span class="d-block text-muted small">' + esc(r.snippet) + '</span>',
        '</a></li>'
      )
    })
    html.push('</ul>')
    container.innerHTML = html.join('')
  }

  function buildModal() {
    if (modalEl) return modalEl
    var wrapper = document.createElement('div')
    wrapper.innerHTML = [
      '<div class="modal fade" tabindex="-1" id="bi-search-modal" aria-labelledby="bi-search-title" aria-hidden="true">',
      '  <div class="modal-dialog modal-lg modal-dialog-scrollable">',
      '    <div class="modal-content">',
      '      <div class="modal-header">',
      '        <h2 class="modal-title h5" id="bi-search-title">Cerca nel sito</h2>',
      '        <button class="btn-close" type="button" data-bs-dismiss="modal" aria-label="Chiudi"></button>',
      '      </div>',
      '      <div class="modal-body">',
      '        <div class="form-group mb-0">',
      '          <label for="bi-search-input" class="active">Parole da cercare</label>',
      '          <input type="search" class="form-control" id="bi-search-input" autocomplete="off">',
      '        </div>',
      '        <div id="bi-search-results" class="link-list-wrapper mt-4"></div>',
      '      </div>',
      '    </div>',
      '  </div>',
      '</div>',
    ].join('\n')
    modalEl = wrapper.firstElementChild
    document.body.appendChild(modalEl)

    var input = modalEl.querySelector('#bi-search-input')
    var results = modalEl.querySelector('#bi-search-results')
    var timer = null

    input.addEventListener('input', function () {
      clearTimeout(timer)
      timer = setTimeout(function () {
        var q = input.value.trim()
        loadIndex()
          .then(function () {
            render(search(q), q, results)
          })
          .catch(function () {
            results.innerHTML =
              '<p class="text-muted mb-0">Indice di ricerca non disponibile.</p>'
          })
      }, 150)
    })

    modalEl.addEventListener('shown.bs.modal', function () {
      input.focus()
    })

    // alla chiusura il focus torna a chi ha aperto la ricerca (WCAG 2.4.3)
    modalEl.addEventListener('hidden.bs.modal', function () {
      if (apertoDa && document.contains(apertoDa)) {
        apertoDa.focus()
      }
    })

    return modalEl
  }

  function open(origine) {
    apertoDa = origine || document.activeElement
    var el = buildModal()
    loadIndex().catch(function () {})
    if (window.bootstrap && window.bootstrap.Modal) {
      window.bootstrap.Modal.getOrCreateInstance(el).show()
    }
  }

  document.addEventListener('DOMContentLoaded', function () {
    var triggers = document.querySelectorAll('[data-bi-search]')
    Array.prototype.forEach.call(triggers, function (t) {
      t.addEventListener('click', function (e) {
        e.preventDefault()
        open(t)
      })
    })
  })

  window.biOpenSearch = open
})()
