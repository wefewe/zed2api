#!/usr/bin/env bash
set -euo pipefail

# 1. 替换 127.0.0.1 监听为 0.0.0.0
sed -i 's/127, 0, 0, 1/0, 0, 0, 0/g' upstream/src/server.zig

# 2. 移除 /v1/models 响应中非标准的 codex models 字段，防止 AxonHub 误解析空模型
python3 - << 'PY'
path = 'upstream/src/server.zig'
s = open(path, encoding='utf-8').read()
anchor_old = """    try w.writeAll("],\\"models\\":");
    try w.writeAll(std.mem.trim(u8, @embedFile("codex_models.json"), " \\n\\r\\t"));
    try w.writeAll("}");"""
if anchor_old in s:
    s = s.replace(anchor_old, '    try w.writeAll("]}");')
    open(path, 'w', encoding='utf-8').write(s)
PY

# 3. 应用 organization_id 与 double-free 修复补丁
if [ -f scripts/fix-upstream.patch ]; then
    git apply --check scripts/fix-upstream.patch >/dev/null 2>&1 && git apply scripts/fix-upstream.patch || true
fi
