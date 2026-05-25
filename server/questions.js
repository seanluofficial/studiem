const fs = require('fs');
const path = require('path');

const CONTENT_DIR = path.join(__dirname, '..', 'content', 'apchem');

// ─── Load all MC cards from every unit*.json ──────────────────────────────────

function loadAllCards() {
  const files = fs.readdirSync(CONTENT_DIR)
    .filter(f => /^unit\d+\.json$/.test(f))
    .sort();

  const cards = [];
  for (const file of files) {
    const raw = JSON.parse(fs.readFileSync(path.join(CONTENT_DIR, file), 'utf8'));
    for (const card of raw) {
      if (card.type === 'mc_static' || card.type === 'mc_numeric') {
        cards.push(card);
      }
    }
  }
  return cards;
}

// ─── Evaluate a formula string with named param variables ─────────────────────

function evalFormula(formula, params) {
  const keys = Object.keys(params);
  const vals = keys.map(k => params[k]);
  // eslint-disable-next-line no-new-func
  return new Function(...keys, `return (${formula})`).call(null, ...vals);
}

// ─── Sample random params for a numeric card ─────────────────────────────────

function sampleParams(paramDefs) {
  const result = {};
  for (const [key, def] of Object.entries(paramDefs)) {
    const { min, max, step = 1 } = def;
    const steps = Math.floor((max - min) / step);
    result[key] = min + Math.floor(Math.random() * (steps + 1)) * step;
  }
  return result;
}

// ─── Substitute {{var}} in a string ──────────────────────────────────────────

function fillTemplate(str, params) {
  return str.replace(/\{\{(\w+)\}\}/g, (_, k) => params[k] ?? `{{${k}}}`);
}

// ─── Render any MC card into a battle-ready question object ──────────────────

function renderCard(card) {
  if (card.type === 'mc_static') {
    return {
      id: card.content.stem.slice(0, 32),
      stem: card.content.stem,
      options: card.content.options,
      correct_index: card.content.correct_index,
    };
  }

  // mc_numeric: sample params, compute values, build options
  const { stem, params: paramDefs, answer_formula, precision = 2, unit = '', distractors } = card.content;

  // Try up to 10 param samples to find one where all options are distinct
  for (let attempt = 0; attempt < 10; attempt++) {
    const params = sampleParams(paramDefs);

    const fmt = (v) => {
      const n = parseFloat(v.toFixed(precision));
      return unit ? `${n} ${unit}` : String(n);
    };

    let answerVal;
    try { answerVal = evalFormula(answer_formula, params); } catch { continue; }
    if (!isFinite(answerVal)) continue;

    const answerStr = fmt(answerVal);

    const distractorStrs = [];
    let ok = true;
    for (const d of distractors) {
      let dVal;
      try { dVal = evalFormula(d.formula, params); } catch { ok = false; break; }
      if (!isFinite(dVal)) { ok = false; break; }
      const dStr = fmt(dVal);
      if (dStr === answerStr || distractorStrs.includes(dStr)) { ok = false; break; }
      distractorStrs.push(dStr);
    }
    if (!ok) continue;

    // Shuffle answer into options
    const options = [answerStr, ...distractorStrs];
    // Fisher-Yates shuffle
    for (let i = options.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [options[i], options[j]] = [options[j], options[i]];
    }

    const correct_index = options.indexOf(answerStr);

    return {
      id: `${answer_formula}_${JSON.stringify(params)}`,
      stem: fillTemplate(stem, params),
      options,
      correct_index,
    };
  }

  // Fallback: couldn't find clean params — skip this card (caller should retry)
  return null;
}

// ─── Pick N random battle questions ──────────────────────────────────────────

let cachedCards = null;

function pickQuestions(n = 10) {
  if (!cachedCards) cachedCards = loadAllCards();

  const pool = [...cachedCards];
  // Shuffle pool
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }

  const questions = [];
  for (const card of pool) {
    if (questions.length >= n) break;
    const q = renderCard(card);
    if (q) questions.push(q);
  }

  return questions;
}

module.exports = { pickQuestions };
