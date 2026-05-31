// Deterministic graph-based level generator + validator for Phase 9.
// Builds 15 varied-shape levels, ensures every node is covered by an arrow
// (no free nodes), validates structure, and proves solvability under the
// EXACT full-shape resolver before writing the asset.
//
// Run: node tool/gen_levels.js  (writes assets/levels/manual_levels.json)

const fs = require('fs');
const path = require('path');

const nid = (x, y) => `n${x}_${y}`;
const eid = (a, b) => `${a}-${b}`;

function dirBetween(a, b) {
  if (b.x === a.x + 1 && b.y === a.y) return 'right';
  if (b.x === a.x - 1 && b.y === a.y) return 'left';
  if (b.x === a.x && b.y === a.y + 1) return 'down';
  if (b.x === a.x && b.y === a.y - 1) return 'up';
  return null;
}

function L(number, name, difficulty) {
  return {
    number, name, difficulty,
    _nodes: new Map(),
    _edges: new Map(),
    _arrows: [],
    addNode(x, y) { const id = nid(x, y); if (!this._nodes.has(id)) this._nodes.set(id, { x, y }); return id; },
    segment(cells) {
      const ids = cells.map(([x, y]) => this.addNode(x, y));
      for (let i = 0; i < ids.length - 1; i++) {
        const a = ids[i], b = ids[i + 1];
        if (!this._edges.has(eid(a, b)) && !this._edges.has(eid(b, a))) this._edges.set(eid(a, b), { from: a, to: b });
      }
      return ids;
    },
    edgeBetween(a, b) { if (this._edges.has(eid(a, b))) return eid(a, b); if (this._edges.has(eid(b, a))) return eid(b, a); return null; },
    arrow(id, cells, direction) {
      const ids = cells.map(([x, y]) => this.addNode(x, y));
      const occ = [];
      for (let i = 0; i < ids.length - 1; i++) {
        const e = this.edgeBetween(ids[i], ids[i + 1]);
        if (!e) throw new Error(`${name}: arrow ${id} missing edge ${ids[i]}->${ids[i + 1]}`);
        occ.push(e);
      }
      this._arrows.push({ id, occupiedEdges: occ, startNodeId: ids[0], endNodeId: ids[ids.length - 1], direction });
    },
    build(meta) {
      return {
        number, name, difficulty,
        definitionJson: {
          nodes: [...this._nodes.entries()].map(([id, p]) => ({ id, x: p.x, y: p.y })),
          edges: [...this._edges.entries()].map(([id, e]) => ({ id, fromNodeId: e.from, toNodeId: e.to, direction: dirBetween(this._nodes.get(e.from), this._nodes.get(e.to)) })),
          arrows: this._arrows.map(a => ({ id: a.id, occupiedEdges: a.occupiedEdges, startNodeId: a.startNodeId, endNodeId: a.endNodeId, direction: a.direction })),
          blockedEdges: [],
          metadata: Object.assign({ difficulty, timeLimit: meta.t, maxMoves: meta.m, generationType: 'manual', seed: null }, meta.extra || {}),
        },
      };
    },
  };
}

const levels = [];

// 1 First Exit — L-shaped board, single L-arrow exits down
{ const l = L(1, 'First Exit', 'easy');
  l.segment([[0,0],[1,0],[2,0]]); l.segment([[2,0],[2,1]]);
  l.arrow('a1', [[0,0],[1,0],[2,0],[2,1]], 'down');
  levels.push(l.build({ t:120, m:8 })); }

// 2 L-Turn — single L-arrow (vertical then horizontal) exits right
{ const l = L(2, 'L-Turn', 'easy');
  l.segment([[0,0],[0,1],[0,2]]); l.segment([[0,2],[1,2],[2,2]]);
  l.arrow('a1', [[0,0],[0,1],[0,2],[1,2],[2,2]], 'right');
  levels.push(l.build({ t:120, m:8 })); }

// 3 Corridor — narrow lane, queue of 2 exiting right
{ const l = L(3, 'Corridor', 'easy');
  l.segment([[0,0],[1,0],[2,0],[3,0]]);
  l.arrow('a1', [[2,0],[3,0]], 'right');
  l.arrow('a2', [[0,0],[1,0]], 'right');
  levels.push(l.build({ t:120, m:10 })); }

// 4 Two Lanes — two separate lanes with a gap row -> irregular
{ const l = L(4, 'Two Lanes', 'easy');
  l.segment([[0,0],[1,0],[2,0]]);
  l.segment([[0,2],[1,2],[2,2]]);
  l.arrow('a1', [[0,0],[1,0],[2,0]], 'right');
  l.arrow('a2', [[0,2],[1,2],[2,2]], 'right');
  levels.push(l.build({ t:120, m:10 })); }

// 5 Queue Up — 5-node lane, 2-node + 3-node queue
{ const l = L(5, 'Queue Up', 'easy');
  l.segment([[0,0],[1,0],[2,0],[3,0],[4,0]]);
  l.arrow('a1', [[3,0],[4,0]], 'right');
  l.arrow('a2', [[0,0],[1,0],[2,0]], 'right');
  levels.push(l.build({ t:120, m:10 })); }

// 6 Cross Roads — plus shape, 3 arrows exiting outward
{ const l = L(6, 'Cross Roads', 'medium');
  l.segment([[0,2],[1,2],[2,2],[3,2],[4,2]]);
  l.segment([[2,0],[2,1],[2,2]]);
  l.segment([[2,2],[2,3],[2,4]]);
  l.arrow('a1', [[0,2],[1,2],[2,2],[3,2],[4,2]], 'right');
  l.arrow('a2', [[2,1],[2,0]], 'up');
  l.arrow('a3', [[2,3],[2,4]], 'down');
  levels.push(l.build({ t:100, m:15 })); }

// 7 T-Junction — top bar queue of 2 + stem exits down
{ const l = L(7, 'T-Junction', 'medium');
  l.segment([[0,0],[1,0],[2,0],[3,0],[4,0]]);
  l.segment([[2,0],[2,1],[2,2],[2,3]]);
  l.arrow('a1', [[3,0],[4,0]], 'right');
  l.arrow('a2', [[0,0],[1,0]], 'right');
  l.arrow('a3', [[2,0],[2,1],[2,2],[2,3]], 'down');
  levels.push(l.build({ t:100, m:15 })); }

// 8 Gate Keeper — asymmetric offset lanes, 3 arrows
{ const l = L(8, 'Gate Keeper', 'medium');
  l.segment([[0,0],[1,0],[2,0],[3,0]]);
  l.segment([[0,1],[1,1],[2,1]]);
  l.arrow('a1', [[2,0],[3,0]], 'right');
  l.arrow('a2', [[0,0],[1,0]], 'right');
  l.arrow('a3', [[0,1],[1,1],[2,1]], 'right');
  levels.push(l.build({ t:100, m:15 })); }

// 9 Offset Pair — staircase, 3 arrows
{ const l = L(9, 'Offset Pair', 'medium');
  l.segment([[0,0],[1,0],[2,0]]);
  l.segment([[1,1],[2,1],[3,1]]);
  l.segment([[2,2],[3,2],[4,2]]);
  l.arrow('a1', [[0,0],[1,0],[2,0]], 'right');
  l.arrow('a2', [[1,1],[2,1],[3,1]], 'right');
  l.arrow('a3', [[2,2],[3,2],[4,2]], 'right');
  levels.push(l.build({ t:100, m:15 })); }

// 10 Three Way — branching/tree, 3 arrows different directions
{ const l = L(10, 'Three Way', 'medium');
  l.segment([[2,0],[2,1],[2,2]]);
  l.segment([[2,0],[3,0],[4,0]]);
  l.segment([[0,2],[1,2],[2,2]]);
  l.arrow('a1', [[2,0],[2,1],[2,2]], 'down');
  l.arrow('a2', [[3,0],[4,0]], 'right');
  l.arrow('a3', [[1,2],[0,2]], 'left');
  levels.push(l.build({ t:100, m:15 })); }

// 11 Deadlock Intro — crossing queues (cross with cross-blocking), 4 arrows
{ const l = L(11, 'Deadlock Intro', 'hard');
  l.segment([[0,2],[1,2],[2,2],[3,2],[4,2]]);
  l.segment([[2,0],[2,1],[2,2],[2,3],[2,4]]);
  l.arrow('h1', [[3,2],[4,2]], 'right');
  l.arrow('h2', [[0,2],[1,2]], 'right');
  l.arrow('vA', [[2,0],[2,1]], 'down');
  l.arrow('vB', [[2,2],[2,3],[2,4]], 'down');
  levels.push(l.build({ t:90, m:20 })); }

// 12 Chain Block — long queue + side lane, 4 arrows, asymmetric
{ const l = L(12, 'Chain Block', 'hard');
  l.segment([[0,0],[1,0],[2,0],[3,0],[4,0],[5,0]]);
  l.segment([[0,1],[1,1],[2,1]]);
  l.arrow('a1', [[4,0],[5,0]], 'right');
  l.arrow('a2', [[2,0],[3,0]], 'right');
  l.arrow('a3', [[0,0],[1,0]], 'right');
  l.arrow('a4', [[0,1],[1,1],[2,1]], 'right');
  levels.push(l.build({ t:90, m:20 })); }

// 13 Interlace — crossing lanes with split vertical queue, 4 arrows
{ const l = L(13, 'Interlace', 'hard');
  l.segment([[0,1],[1,1],[2,1],[3,1],[4,1]]);
  l.segment([[2,0],[2,1],[2,2],[2,3]]);
  l.arrow('h1', [[3,1],[4,1]], 'right');
  l.arrow('h2', [[0,1],[1,1]], 'right');
  l.arrow('vTop', [[2,0],[2,1]], 'down');   // owns center 2,1
  l.arrow('vBot', [[2,2],[2,3]], 'down');
  levels.push(l.build({ t:90, m:20 })); }

// 14 Four Locks — H/ladder shape (two columns + top rung), 4 arrows
{ const l = L(14, 'Four Locks', 'hard');
  l.segment([[0,0],[0,1],[0,2]]);
  l.segment([[3,0],[3,1],[3,2]]);
  l.segment([[0,0],[1,0],[2,0],[3,0]]);
  l.arrow('a1', [[0,1],[0,2]], 'down');
  l.arrow('a2', [[3,1],[3,2]], 'down');
  l.arrow('a3', [[2,0],[3,0]], 'right');   // rung front exits right
  l.arrow('a4', [[0,0],[1,0]], 'right');   // rung rear (blocked by a3)
  levels.push(l.build({ t:80, m:20 })); }

// 15 Final Maze — dense asymmetric multi-arm, 5 arrows
{ const l = L(15, 'Final Maze', 'hard');
  l.segment([[0,0],[1,0],[2,0],[3,0]]);
  l.segment([[0,2],[1,2],[2,2],[3,2]]);
  l.segment([[4,0],[4,1],[4,2]]);
  l.segment([[3,0],[4,0]]);
  l.segment([[3,2],[4,2]]);
  l.arrow('a1', [[2,0],[3,0]], 'right');
  l.arrow('a2', [[0,0],[1,0]], 'right');
  l.arrow('a3', [[2,2],[3,2]], 'right');
  l.arrow('a4', [[0,2],[1,2]], 'right');
  l.arrow('a5', [[4,0],[4,1],[4,2]], 'down');
  levels.push(l.build({ t:80, m:25 })); }

// ---------------- VALIDATION ----------------
function coveredNodes(dj, arrow) {
  const s = new Set([arrow.startNodeId, arrow.endNodeId]);
  const byId = {}; for (const e of dj.edges) byId[e.id] = e;
  for (const eId of arrow.occupiedEdges) { const e = byId[eId]; if (e) { s.add(e.fromNodeId); s.add(e.toNodeId); } }
  return s;
}
function neighbor(dj, nodeById, nodeId, dir) {
  const node = nodeById[nodeId];
  for (const e of dj.edges) {
    let other = null;
    if (e.fromNodeId === nodeId) other = e.toNodeId; else if (e.toNodeId === nodeId) other = e.fromNodeId; else continue;
    if (dirBetween(node, nodeById[other]) === dir) return other;
  }
  return null;
}
function resolve(dj, nodeById, arrow, active) {
  const blocker = new Set();
  for (const o of active) { if (o.id === arrow.id) continue; for (const n of coveredNodes(dj, o)) blocker.add(n); }
  for (const start of coveredNodes(dj, arrow)) {
    let cur = start;
    while (true) {
      const nb = neighbor(dj, nodeById, cur, arrow.direction);
      if (nb === null) break;
      // blocked edges always empty in these levels
      if (blocker.has(nb)) return 'collision';
      cur = nb;
    }
  }
  return 'escaped';
}
function solvable(dj) {
  const nodeById = {}; for (const n of dj.nodes) nodeById[n.id] = n;
  function rec(active) {
    if (active.length === 0) return true;
    for (const a of active) {
      if (resolve(dj, nodeById, a, active) === 'escaped') {
        if (rec(active.filter(x => x.id !== a.id))) return true;
      }
    }
    return false;
  }
  return rec(dj.arrows);
}
function noFreeNodes(dj) {
  const covered = new Set();
  for (const a of dj.arrows) for (const n of coveredNodes(dj, a)) covered.add(n);
  return dj.nodes.every(n => covered.has(n.id)) ? null : dj.nodes.filter(n => !covered.has(n.id)).map(n => n.id);
}
function structureErrors(dj) {
  const errs = [];
  const nodeIds = new Set(dj.nodes.map(n => n.id));
  if (new Set(dj.nodes.map(n=>n.id)).size !== dj.nodes.length) errs.push('dup node');
  const edgeIds = new Set();
  const byId = {};
  for (const n of dj.nodes) byId[n.id] = n;
  for (const e of dj.edges) {
    if (edgeIds.has(e.id)) errs.push('dup edge ' + e.id); edgeIds.add(e.id);
    if (!nodeIds.has(e.fromNodeId) || !nodeIds.has(e.toNodeId)) errs.push('edge endpoint missing ' + e.id);
    if (dirBetween(byId[e.fromNodeId], byId[e.toNodeId]) === null) errs.push('edge not orthogonal ' + e.id);
  }
  const arrowIds = new Set();
  for (const a of dj.arrows) {
    if (arrowIds.has(a.id)) errs.push('dup arrow ' + a.id); arrowIds.add(a.id);
    if (!nodeIds.has(a.startNodeId) || !nodeIds.has(a.endNodeId)) errs.push('arrow node missing ' + a.id);
    for (const eId of a.occupiedEdges) if (!edgeIds.has(eId)) errs.push('arrow edge missing ' + a.id + ' ' + eId);
    if (a.occupiedEdges.length < 1) errs.push('arrow has no edges ' + a.id);
  }
  return errs;
}
function shape(dj) {
  const xs = dj.nodes.map(n=>n.x), ys = dj.nodes.map(n=>n.y);
  const w = Math.max(...xs)-Math.min(...xs)+1, h = Math.max(...ys)-Math.min(...ys)+1;
  return { w, h, full: w*h, n: dj.nodes.length, rect: dj.nodes.length === w*h };
}

let ok = true;
const diffByNum = {};
for (const lvl of levels) {
  const dj = lvl.definitionJson;
  const se = structureErrors(dj);
  const free = noFreeNodes(dj);
  const sv = solvable(dj);
  const sh = shape(dj);
  diffByNum[lvl.number] = lvl.difficulty;
  const bad = se.length || free || !sv;
  if (bad) ok = false;
  console.log(
    '#' + String(lvl.number).padStart(2) + ' ' + lvl.name.padEnd(15) +
    ' ' + lvl.difficulty.padEnd(6) +
    ' nodes=' + String(sh.n).padStart(2) + ' bbox=' + sh.w + 'x' + sh.h +
    ' arrows=' + dj.arrows.length +
    ' rect=' + (sh.rect ? 'Y' : 'n') +
    ' free=' + (free ? JSON.stringify(free) : '-') +
    ' solvable=' + sv +
    (se.length ? ' STRUCT_ERR=' + JSON.stringify(se) : '')
  );
}
// difficulty progression
const prog = [1,2,3,4,5].every(n=>diffByNum[n]==='easy') &&
             [6,7,8,9,10].every(n=>diffByNum[n]==='medium') &&
             [11,12,13,14,15].every(n=>diffByNum[n]==='hard');
const hardRects = levels.filter(l=>l.number>=11).filter(l=>shape(l.definitionJson).rect).length;
console.log();
console.log('difficulty progression ok:', prog);
console.log('hard levels that are full rectangles:', hardRects, '(must be < 5)');
console.log('ALL VALID & SOLVABLE:', ok && prog && hardRects < 5);

if (ok && prog && hardRects < 5) {
  const out = path.join(__dirname, '..', 'assets', 'levels', 'manual_levels.json');
  fs.writeFileSync(out, JSON.stringify({ levels }, null, 2) + '\n');
  console.log('WROTE', out);
} else {
  console.log('NOT WRITTEN — fix issues first');
  process.exitCode = 1;
}
