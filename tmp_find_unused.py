#!/usr/bin/env python3
import re
from pathlib import Path
from collections import defaultdict, deque

ROOT = Path('lib')
files = sorted(ROOT.rglob('*.dart'))
contents = {f: f.read_text(encoding='utf-8', errors='ignore') for f in files}
file_set = {f.relative_to(ROOT) for f in files}
import_re = re.compile(r"""(?:import|export)\s+['\"]([^'\"]+)['\"]""")


def resolve_import(from_file: Path, imp: str):
    if imp.startswith('package:flutter_provider_data/'):
        return Path(imp[len('package:flutter_provider_data/'):])
    if imp.startswith('package:') or imp.startswith('dart:'):
        return None
    try:
        return (from_file.parent / imp).resolve().relative_to(ROOT.resolve())
    except ValueError:
        return None


def is_in_block_comment(text, pos):
    last_open = text.rfind('/*', 0, pos)
    if last_open == -1:
        return False
    last_close = text.rfind('*/', 0, pos)
    return last_close < last_open


graph = defaultdict(set)
for f, text in contents.items():
    rel = f.relative_to(ROOT)
    for m in import_re.finditer(text):
        start = m.start()
        line_start = text.rfind('\n', 0, start) + 1
        nl = text.find('\n', start)
        line = text[line_start: nl if nl != -1 else len(text)]
        if line.strip().startswith('//'):
            continue
        if is_in_block_comment(text, start):
            continue
        tgt = resolve_import(f, m.group(1))
        if tgt is not None and tgt in file_set:
            graph[rel].add(tgt)

reachable = set()
q = deque([Path('main.dart')])
while q:
    cur = q.popleft()
    if cur in reachable:
        continue
    reachable.add(cur)
    for nxt in graph.get(cur, ()):
        if nxt not in reachable:
            q.append(nxt)

soft_keep = {Path('page/001-molding/report/totalngchartpage.dart')}
unreachable = sorted(file_set - reachable - soft_keep)
print(f'Reachable: {len(reachable)}  Softkeep: {len(soft_keep)}  Delete: {len(unreachable)}')
total = 0
for u in unreachable:
    size = (ROOT / u).stat().st_size
    total += size
    print(f'{size:8d}  {u}')
print('TOTAL_BYTES', total)
print('TOTAL_KB', round(total / 1024, 1))
