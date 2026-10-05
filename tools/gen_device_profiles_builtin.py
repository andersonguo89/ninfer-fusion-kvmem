# -*- coding: utf-8 -*-
"""gen_device_profiles_builtin.py — 从 device_profiles.json 重生成内置源文件

用法: 在 src-tree/fusion-engine-src 下执行
  python ../../tools/gen_device_profiles_builtin.py  (路径见下方常量)
背景: MSVC 19.44 对 ~16KB 以上的 raw string literal 报 C2026（实测阈值，
文档写 65535 不可信），因此把 device_profiles.json 按 8000 字节分块，
生成相邻 raw literal 拼接的源文件 device_profiles_builtin_static.cpp。
device_profiles.json 更新（ninfer-calibrate 重新合并）后重跑本脚本即可。
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, '..', 'src-tree', 'fusion-engine-src',
                   'src', 'runtime', 'engine', 'device_profiles.json')
OUT = os.path.join(HERE, '..', 'src-tree', 'fusion-engine-src',
                   'src', 'runtime', 'engine', 'device_profiles_builtin_static.cpp')
CS = 8000

j = open(SRC, 'rb').read().decode('utf-8')
chunks = []
off = 0
while off < len(j):
    chunks.append(j[off:off + CS])
    off += CS

parts = '\n           '.join(
    f'R"ninfer_c{i}({c})ninfer_c{i}"' for i, c in enumerate(chunks))

tmpl = (
    '// Generated from src/runtime/engine/device_profiles.json by\n'
    '// tools/gen_device_profiles_builtin.py (chunked raw literals: MSVC 19.44\n'
    '// rejects raw strings beyond ~16KB with C2026). Regenerate with:\n'
    '//   python tools/gen_device_profiles_builtin.py\n'
    '#include <string_view>\n\n'
    'namespace ninfer::runtime {\n\n'
    'std::string_view compiled_device_route_profiles_json() {\n'
    '    return ' + parts + ';\n'
    '}\n\n'
    '} // namespace ninfer::runtime\n'
)
open(OUT, 'w', encoding='utf-8', newline='\n').write(tmpl)
print('written', os.path.abspath(OUT), '| chunks:', len(chunks))
