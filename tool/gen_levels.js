// Level tool for the Arrow game (Phase 10).
//
// manual_levels.json is the AUTHORITATIVE source. This tool NEVER overwrites it
// unless you explicitly pass --generate.
//
//   node tool/gen_levels.js --validate-only   (default)
//       Reads assets/levels/manual_levels.json and validates it. Never writes.
//
//   node tool/gen_levels.js --generate
//       Rebuilds the denser levels from the in-script builders, validates them,
//       and writes assets/levels/manual_levels.json. Use intentionally.
//
// Checks: structure (orthogonal edges, unique ids, arrow edges/nodes exist),
// no-free-nodes, greedy solvability, difficulty progression, density bands,
// and hard-not-all-rectangular.
//
// Solvability uses a GREEDY solver: repeatedly exit any currently-exitable
// arrow. Because escaped arrows are non-blocking and exiting only frees nodes
// (monotonic), greedy is both sound and complete — it succeeds iff the level is
// solvable. This stays fast even at 50-60 arrows.

const fs = require('fs');
const path = require('path');

const ASSET = path.join(__dirname, '..', 'assets', 'levels', 'manual_levels.json');

const nid = (x, y) => `n${x}_${y}`;
const eid = (a, b) => `${a}-${b}`;

function dirBetween(a, b) {
  if (b.x === a.x + 1 && b.y === a.y) return 'right';
  if (b.x === a.x - 1 && b.y === a.y) return 'left';
  if (b.x === a.x && b.y === a.y + 1) return 'down';
  if (b.x === a.x && b.y === a.y - 1) return 'up';
  return null;
}
const DELTA = { right: [1, 0], left: [-1, 0], down: [0, 1], up: [0, -1] };

// ---------------------------------------------------------------------------
// Builder
// ---------------------------------------------------------------------------
function Builder(number, name, difficulty) {
  return {
    number, name, difficulty,
    _nodes: new Map(),
    _edges: new Map(),
    _arrows: [],
    _seq: 0,
    addNode(x, y) {
      const id = nid(x, y);
      if (!this._nodes.has(id)) this._nodes.set(id, { x, y });
      return id;
    },
    addEdge(a, b) {
      if (!this._edges.has(eid(a, b)) && !this._edges.has(eid(b, a))) {
        this._edges.set(eid(a, b), { from: a, to: b });
      }
    },
    edgeBetween(a, b) {
      if (this._edges.has(eid(a, b))) return eid(a, b);
      if (this._edges.has(eid(b, a))) return eid(b, a);
      return null;
    },
    // Add an arrow over a contiguous cell sequence; head = last cell.
    arrowOverCells(cells, direction) {
      const ids = cells.map(([x, y]) => this.addNode(x, y));
      for (let i = 0; i < ids.length - 1; i++) this.addEdge(ids[i], ids[i + 1]);
      const occ = [];
      for (let i = 0; i < ids.length - 1; i++) occ.push(this.edgeBetween(ids[i], ids[i + 1]));
      this._arrows.push({
        id: 'a' + (++this._seq),
        occupiedEdges: occ,
        startNodeId: ids[0],
        endNodeId: ids[ids.length - 1],
        direction,
      });
    },
    // Fill a straight lane with a queue of arrows exiting toward `dir`.
    // cellsInOrder: lane cells ordered left->right (h) or top->bottom (v).
    // segLens: arrow lengths (in nodes) from the EXIT end. Sum must == lane len.
    laneQueue(cellsInOrder, dir, segLens) {
      const total = cellsInOrder.length;
      const sum = segLens.reduce((a, b) => a + b, 0);
      if (sum !== total) throw new Error(`${name}: lane len ${total} != segs ${sum}`);
      // Exit end: for right/down the exit is the LAST cell; for left/up the FIRST.
      const exitAtEnd = dir === 'right' || dir === 'down';
      // Ensure consecutive edges exist along the whole lane.
      const ids = cellsInOrder.map(([x, y]) => this.addNode(x, y));
      for (let i = 0; i < ids.length - 1; i++) this.addEdge(ids[i], ids[i + 1]);
      // Assign arrows from the exit end inward.
      let idx = exitAtEnd ? total - 1 : 0;
      const step = exitAtEnd ? -1 : 1;
      for (const len of segLens) {
        const cells = [];
        for (let k = 0; k < len; k++) {
          cells.push(cellsInOrder[idx + step * k]);
        }
        // `cells` is always collected starting from the EXIT-facing cell.
        // The arrow head (endNodeId) must be the exit-facing cell, so it must
        // be LAST in the path → always reverse. (Previously left/up lanes were
        // not reversed, putting the head on the wrong end and rendering the
        // arrowhead at the inner end.)
        const ordered = cells.slice().reverse();
        this.arrowOverCells(ordered, dir);
        idx += step * len;
      }
    },
    // Split a lane of `len` nodes into `nArrows` segments, each >= 2 nodes,
    // distributing any remainder to the exit-side arrows first.
    _segs(len, nArrows) {
      if (len < 2 * nArrows) {
        throw new Error(`${name}: lane len ${len} too short for ${nArrows} arrows`);
      }
      const sizes = new Array(nArrows).fill(2);
      let extra = len - 2 * nArrows;
      let i = 0;
      while (extra > 0) { sizes[i % nArrows]++; extra--; i++; }
      return sizes;
    },
    hLane(y, x0, x1, dir, nArrows) {
      const cells = [];
      for (let x = x0; x <= x1; x++) cells.push([x, y]);
      this.laneQueue(cells, dir, this._segs(cells.length, nArrows));
    },
    vLane(x, y0, y1, dir, nArrows) {
      const cells = [];
      for (let y = y0; y <= y1; y++) cells.push([x, y]);
      this.laneQueue(cells, dir, this._segs(cells.length, nArrows));
    },
    connect(ax, ay, bx, by) {
      const a = this.addNode(ax, ay);
      const b = this.addNode(bx, by);
      this.addEdge(a, b);
    },
    // Add a vertical edge between every vertically-adjacent node pair. These
    // connectors make the whole board ONE connected traversal graph. They are
    // perpendicular to the (horizontal) arrows, so they never extend an arrow's
    // exit sweep — solvability is unchanged, but the graph is no longer split
    // into islands.
    weave() {
      for (const [id, p] of [...this._nodes.entries()]) {
        const below = nid(p.x, p.y + 1);
        if (this._nodes.has(below)) this.addEdge(id, below);
      }
    },
    build(meta) {
      const nodeById = this._nodes;
      return {
        number, name, difficulty,
        definitionJson: {
          nodes: [...nodeById.entries()].map(([id, p]) => ({ id, x: p.x, y: p.y })),
          edges: [...this._edges.entries()].map(([id, e]) => ({
            id, fromNodeId: e.from, toNodeId: e.to,
            direction: dirBetween(nodeById.get(e.from), nodeById.get(e.to)),
          })),
          arrows: this._arrows.map(a => ({ ...a })),
          blockedEdges: [],
          metadata: Object.assign(
            { difficulty, timeLimit: meta.t, maxMoves: meta.m, generationType: 'manual', seed: null },
            meta.extra || {}
          ),
        },
      };
    },
  };
}

// ---------------------------------------------------------------------------
// Level builders — denser, varied, no free nodes, greedy-solvable
// (disjoint lanes guarantee solvability; ragged silhouettes give variety)
// ---------------------------------------------------------------------------
// Build a level from a stack of horizontal rows. Each row is `[width, dir,
// arrows]` at y = its index, left-aligned at x=0 so consecutive rows always
// overlap (column 0) — after weaving, the whole board is one connected graph.
// Ragged widths give non-rectangular silhouettes; alternating directions
// exercise both left- and right-pointing arrowheads.
function rowStack(number, name, difficulty, meta, rows) {
  const b = Builder(number, name, difficulty);
  rows.forEach((r, y) => b.hLane(y, 0, r[0] - 1, r[1], r[2]));
  b.weave();
  return b.build(meta);
}

function buildLevels() {
  const out = [];
  const R = 'right', L = 'left';

  // Each level is a single CONNECTED traversal graph: rows are left-aligned and
  // woven with vertical connector edges, so there are no disconnected islands.
  // All arrows are horizontal queues (left/right). Ragged row widths give
  // non-rectangular silhouettes; alternating directions exercise both arrowhead
  // orientations. Solvability is preserved because vertical connectors are
  // perpendicular to the arrows' exit sweep.

  // ===== EASY (soft ramp 10 -> 15 arrows) =====
  out.push(rowStack(1, 'First Exit', 'easy', { t: 120, m: 30 }, [
    [4, R, 2], [5, L, 2], [4, R, 2], [5, L, 2], [4, R, 2],
  ])); // 10
  out.push(rowStack(2, 'L-Turn', 'easy', { t: 120, m: 33 }, [
    [4, R, 2], [4, L, 2], [4, R, 2], [4, L, 2], [6, R, 3],
  ])); // 11
  out.push(rowStack(3, 'Corridor', 'easy', { t: 120, m: 36 }, [
    [5, R, 2], [4, L, 2], [5, R, 2], [4, L, 2], [5, R, 2], [4, L, 2],
  ])); // 12
  out.push(rowStack(4, 'Two Lanes', 'easy', { t: 120, m: 39 }, [
    [6, R, 3], [4, L, 2], [6, R, 3], [4, L, 2], [6, R, 3],
  ])); // 13
  out.push(rowStack(5, 'Queue Up', 'easy', { t: 120, m: 45 }, [
    [6, R, 3], [7, L, 3], [6, R, 3], [7, L, 3], [6, R, 3],
  ])); // 15

  // ===== MEDIUM (16 -> 28) =====
  out.push(rowStack(6, 'Cross Roads', 'medium', { t: 100, m: 48 }, [
    [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4],
  ])); // 16
  out.push(rowStack(7, 'T-Junction', 'medium', { t: 100, m: 54 }, [
    [10, R, 5], [8, L, 4], [10, R, 5], [8, L, 4],
  ])); // 18
  out.push(rowStack(8, 'Gate Keeper', 'medium', { t: 100, m: 60 }, [
    [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4], [8, R, 4],
  ])); // 20
  out.push(rowStack(9, 'Offset Pair', 'medium', { t: 100, m: 72 }, [
    [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4],
  ])); // 24
  out.push(rowStack(10, 'Three Way', 'medium', { t: 100, m: 84 }, [
    [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4], [8, R, 4], [9, L, 4], [8, R, 4],
  ])); // 28

  // ===== HARD (22 -> 50) =====
  out.push(rowStack(11, 'Deadlock Intro', 'hard', { t: 90, m: 66 }, [
    [9, R, 4], [10, L, 5], [9, R, 4], [10, L, 5], [9, R, 4],
  ])); // 22
  out.push(rowStack(12, 'Chain Block', 'hard', { t: 90, m: 84 }, [
    [10, R, 5], [9, L, 4], [10, R, 5], [9, L, 4], [10, R, 5], [9, L, 4],
  ])); // 28
  out.push(rowStack(13, 'Interlace', 'hard', { t: 90, m: 102 }, [
    [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 4],
  ])); // 34
  out.push(rowStack(14, 'Four Locks', 'hard', { t: 80, m: 126 }, [
    [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5],
  ])); // 40
  out.push(rowStack(15, 'Final Maze', 'hard', { t: 80, m: 150 }, [
    [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 5],
    [11, L, 5], [10, R, 5], [11, L, 5], [10, R, 5], [11, L, 5],
  ])); // 50

  return out;
}

// ---------------------------------------------------------------------------
// Validation (works on any {definitionJson})
// ---------------------------------------------------------------------------
function coveredNodes(dj, arrow, byId) {
  const s = new Set([arrow.startNodeId, arrow.endNodeId]);
  for (const eId of arrow.occupiedEdges) {
    const e = byId.edges[eId];
    if (e) { s.add(e.fromNodeId); s.add(e.toNodeId); }
  }
  return s;
}
function index(dj) {
  const nodes = {}; for (const n of dj.nodes) nodes[n.id] = n;
  const edges = {}; for (const e of dj.edges) edges[e.id] = e;
  return { nodes, edges };
}
function neighbor(dj, byId, nodeId, dir) {
  const node = byId.nodes[nodeId];
  const [dx, dy] = DELTA[dir];
  for (const e of dj.edges) {
    let other = null;
    if (e.fromNodeId === nodeId) other = e.toNodeId;
    else if (e.toNodeId === nodeId) other = e.fromNodeId;
    else continue;
    const o = byId.nodes[other];
    if (o.x === node.x + dx && o.y === node.y + dy) return other;
  }
  return null;
}
function edgeInDir(dj, byId, nodeId, dir) {
  const node = byId.nodes[nodeId];
  const [dx, dy] = DELTA[dir];
  for (const e of dj.edges) {
    let other = null;
    if (e.fromNodeId === nodeId) other = e.toNodeId;
    else if (e.toNodeId === nodeId) other = e.fromNodeId;
    else continue;
    const o = byId.nodes[other];
    if (o.x === node.x + dx && o.y === node.y + dy) return e;
  }
  return null;
}
// Full-shape resolver mirror of MovementResolver.
function canExit(dj, byId, arrow, activeById, blockedSet) {
  const blocker = new Set();
  for (const id in activeById) {
    if (id === arrow.id) continue;
    for (const n of coveredNodes(dj, activeById[id], byId)) blocker.add(n);
  }
  for (const start of coveredNodes(dj, arrow, byId)) {
    let cur = start;
    while (true) {
      const e = edgeInDir(dj, byId, cur, arrow.direction);
      if (!e) break;
      if (blockedSet.has(e.id)) return false;
      const nb = neighbor(dj, byId, cur, arrow.direction);
      if (nb === null) break;
      if (blocker.has(nb)) return false;
      cur = nb;
    }
  }
  return true;
}
// Greedy solver (sound + complete for this game).
function solvableGreedy(dj) {
  const byId = index(dj);
  const blockedSet = new Set(dj.blockedEdges || []);
  const active = {};
  for (const a of dj.arrows) active[a.id] = a;
  let remaining = dj.arrows.length;
  let progress = true;
  while (remaining > 0 && progress) {
    progress = false;
    for (const id of Object.keys(active)) {
      if (canExit(dj, byId, active[id], active, blockedSet)) {
        delete active[id];
        remaining--;
        progress = true;
      }
    }
  }
  return remaining === 0;
}
// Visible no-free-nodes: every node that is NOT a hidden connector must be
// covered by an arrow. (No hidden connectors exist in the current levels, so
// this applies to all nodes.)
function noFreeNodes(dj) {
  const byId = index(dj);
  const covered = new Set();
  for (const a of dj.arrows) for (const n of coveredNodes(dj, a, byId)) covered.add(n);
  const free = dj.nodes
    .filter(n => !n.hidden && !covered.has(n.id))
    .map(n => n.id);
  return free.length ? free : null;
}
// Number of connected components over the full traversal graph (all nodes +
// edges, including any hidden connectors). A valid level must be ONE component
// — no disconnected islands.
function connectedComponents(dj) {
  if (dj.nodes.length === 0) return 0;
  const adj = {};
  for (const n of dj.nodes) adj[n.id] = [];
  for (const e of dj.edges) {
    if (adj[e.fromNodeId]) adj[e.fromNodeId].push(e.toNodeId);
    if (adj[e.toNodeId]) adj[e.toNodeId].push(e.fromNodeId);
  }
  const seen = new Set();
  let components = 0;
  for (const start of dj.nodes.map(n => n.id)) {
    if (seen.has(start)) continue;
    components++;
    const stack = [start];
    seen.add(start);
    while (stack.length) {
      const cur = stack.pop();
      for (const nb of adj[cur]) if (!seen.has(nb)) { seen.add(nb); stack.push(nb); }
    }
  }
  return components;
}
function structureErrors(dj) {
  const errs = [];
  const nodeIds = new Set();
  for (const n of dj.nodes) { if (nodeIds.has(n.id)) errs.push('dup node ' + n.id); nodeIds.add(n.id); }
  const byId = index(dj);
  const edgeIds = new Set();
  for (const e of dj.edges) {
    if (edgeIds.has(e.id)) errs.push('dup edge ' + e.id); edgeIds.add(e.id);
    if (!nodeIds.has(e.fromNodeId) || !nodeIds.has(e.toNodeId)) errs.push('edge endpoint missing ' + e.id);
    else if (dirBetween(byId.nodes[e.fromNodeId], byId.nodes[e.toNodeId]) === null) errs.push('edge not orthogonal/unit ' + e.id);
  }
  const arrowIds = new Set();
  for (const a of dj.arrows) {
    if (arrowIds.has(a.id)) errs.push('dup arrow ' + a.id); arrowIds.add(a.id);
    if (!nodeIds.has(a.startNodeId) || !nodeIds.has(a.endNodeId)) errs.push('arrow node missing ' + a.id);
    for (const eId of a.occupiedEdges) if (!edgeIds.has(eId)) errs.push('arrow edge missing ' + a.id + ' ' + eId);
    if (!a.occupiedEdges || a.occupiedEdges.length < 1) errs.push('arrow has no edges ' + a.id);
    // Head orientation: the body edge at the head must lead OPPOSITE to the
    // arrow direction (the body trails behind the head). Otherwise the head is
    // on the wrong end and the arrowhead renders incorrectly.
    const head = byId.nodes[a.endNodeId];
    const [dx, dy] = DELTA[a.direction] || [0, 0];
    if (head) {
      let behind = false;
      for (const eId of a.occupiedEdges) {
        const e = byId.edges[eId];
        if (!e) continue;
        const otherId = e.fromNodeId === a.endNodeId ? e.toNodeId
          : e.toNodeId === a.endNodeId ? e.fromNodeId : null;
        if (!otherId) continue;
        const o = byId.nodes[otherId];
        if (o && o.x === head.x - dx && o.y === head.y - dy) behind = true;
      }
      if (!behind) errs.push('arrow head not at exit end ' + a.id);
    }
  }
  return errs;
}
function shape(dj) {
  const xs = dj.nodes.map(n => n.x), ys = dj.nodes.map(n => n.y);
  const w = Math.max(...xs) - Math.min(...xs) + 1, h = Math.max(...ys) - Math.min(...ys) + 1;
  return { w, h, rect: dj.nodes.length === w * h };
}
const DENSITY = {
  easy: { min: 10, max: 15 },
  medium: { min: 15, max: 30 },
  hard: { min: 20, max: 60, warn: 50 },
};
function validateAll(levels) {
  let ok = true;
  const warnings = [];
  const diffByNum = {};
  const arrowsByTier = { easy: [], medium: [], hard: [] };

  for (const lvl of levels) {
    const dj = lvl.definitionJson;
    const diff = lvl.difficulty;
    diffByNum[lvl.number] = diff;
    const se = structureErrors(dj);
    const free = noFreeNodes(dj);
    const sv = solvableGreedy(dj);
    const sh = shape(dj);
    const components = connectedComponents(dj);
    const n = dj.arrows.length;
    if (arrowsByTier[diff]) arrowsByTier[diff].push(n);

    const band = DENSITY[diff];
    let densityErr = '';
    if (band) {
      if (n < band.min || n > band.max) { densityErr = `density ${n} out of [${band.min},${band.max}]`; }
      else if (band.warn && n > band.warn) warnings.push(`#${lvl.number} dense (${n} arrows, >${band.warn})`);
    }

    const bad = se.length || free || !sv || densityErr || components !== 1;
    if (bad) ok = false;
    console.log(
      '#' + String(lvl.number).padStart(2) + ' ' + (lvl.name || '').padEnd(15) +
      ' ' + diff.padEnd(6) +
      ' nodes=' + String(dj.nodes.length).padStart(3) +
      ' arrows=' + String(n).padStart(2) +
      ' bbox=' + sh.w + 'x' + sh.h +
      ' rect=' + (sh.rect ? 'Y' : 'n') +
      ' comp=' + components +
      ' free=' + (free ? JSON.stringify(free) : '-') +
      ' solvable=' + sv +
      (components !== 1 ? ' DISCONNECTED(' + components + ')' : '') +
      (densityErr ? ' ' + densityErr.toUpperCase() : '') +
      (se.length ? ' STRUCT_ERR=' + JSON.stringify(se) : '')
    );
  }

  const prog = [1, 2, 3, 4, 5].every(k => diffByNum[k] === 'easy') &&
    [6, 7, 8, 9, 10].every(k => diffByNum[k] === 'medium') &&
    [11, 12, 13, 14, 15].every(k => diffByNum[k] === 'hard');
  const avg = t => arrowsByTier[t].reduce((a, b) => a + b, 0) / (arrowsByTier[t].length || 1);
  const increasing = avg('easy') < avg('medium') && avg('medium') < avg('hard');
  const hardRects = levels.filter(l => l.number >= 11).filter(l => shape(l.definitionJson).rect).length;

  console.log();
  console.log('difficulty progression ok:', prog);
  console.log('tier avg arrows: easy=' + avg('easy').toFixed(1) + ' medium=' + avg('medium').toFixed(1) + ' hard=' + avg('hard').toFixed(1) + ' (must strictly increase:', increasing + ')');
  console.log('hard full-rectangle levels:', hardRects, '(must be < 5)');
  if (warnings.length) console.log('WARNINGS:', warnings.join('; '));
  const allOk = ok && prog && increasing && hardRects < 5;
  console.log('ALL VALID:', allOk);
  return allOk;
}

// ---------------------------------------------------------------------------
// Main — explicit modes
// ---------------------------------------------------------------------------
function main() {
  const args = process.argv.slice(2);
  const generate = args.includes('--generate');
  const validateOnly = args.includes('--validate-only') || !generate;

  if (generate && validateOnly && args.includes('--validate-only')) {
    console.error('Pass either --generate or --validate-only, not both.');
    process.exitCode = 2;
    return;
  }

  if (generate) {
    console.log('MODE: --generate (will write manual_levels.json if valid)\n');
    const levels = buildLevels();
    const allOk = validateAll(levels);
    if (allOk) {
      fs.writeFileSync(ASSET, JSON.stringify({ levels }, null, 2) + '\n');
      console.log('\nWROTE', ASSET);
    } else {
      console.log('\nNOT WRITTEN — fix issues first');
      process.exitCode = 1;
    }
    return;
  }

  // Default: validate-only (never writes).
  console.log('MODE: --validate-only (reads manual_levels.json, never writes)\n');
  const parsed = JSON.parse(fs.readFileSync(ASSET, 'utf8'));
  const levels = parsed.levels || [];
  if (levels.length !== 15) {
    console.log(`Expected 15 levels, found ${levels.length}`);
    process.exitCode = 1;
    return;
  }
  const allOk = validateAll(levels);
  if (!allOk) process.exitCode = 1;
}

main();
