#!/usr/bin/env python3
"""统计学位论文正文的字数与页数分布。

方法：从编译后的 PDF 文本层提取内容，按页眉把每页归属到章，再统计中文字符。
不直接数 Typst 源码，因为源码里混有表格、图片与排版的标记代码。

口径与排除项：
  * 页眉（"石河子大学博士学位论文"、章名）与页码已排除；
  * "中文字"只计中日韩统一表意文字，不含数字、西文与公式符号；
  * "含标点"另加中文全角标点；
  * 包含图表标题（图注、表注为中文）；不含参考文献条目的英文内容。

用法：
    python3 scripts/count_words.py                 # 用现有的 main.pdf
    python3 scripts/count_words.py --compile       # 先重新编译再统计
    python3 scripts/count_words.py --pdf path.pdf  # 指定其他 PDF
"""

import argparse
import collections
import re
import subprocess
import sys
from pathlib import Path

try:
    import pypdf
except ImportError:
    sys.exit("需要 pypdf：python3 -m pip install pypdf")

ROOT = Path(__file__).resolve().parents[1]

CHAPTER_HEADER = re.compile(r"^第 ?([1-7]) ?章")
RUNNING_TITLE = "石河子大学博士学位论文"
CJK = re.compile(r"[\u3400-\u9fff]")
FULLWIDTH_PUNCT = re.compile(r"[，。、；：？！“”‘’（）《》—…·]")
PAGE_NUMBER = re.compile(r"\d{1,3}")
REF_HEADING = "参考文献"
ACK_HEADING = "致谢"


def compile_thesis() -> Path:
    """重新编译 main.pdf，返回其路径。"""
    pdf = ROOT / "main.pdf"
    print("正在编译 main.typ …", flush=True)
    subprocess.run(
        ["typst", "compile", "--root", "..", "main.typ", "main.pdf"],
        cwd=ROOT,
        check=True,
    )
    return pdf


def content_lines(page_text: str) -> list:
    """去掉页眉、章名页眉与页码，返回该页的正文行。"""
    out = []
    for raw in page_text.split("\n"):
        line = raw.strip()
        if not line:
            continue
        if line == RUNNING_TITLE or CHAPTER_HEADER.match(line):
            continue
        if PAGE_NUMBER.fullmatch(line):
            continue
        out.append(line)
    return out


def count(text: str):
    cjk = len(CJK.findall(text))
    return cjk, cjk + len(FULLWIDTH_PUNCT.findall(text))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pdf", default=None, help="待统计的 PDF（默认 main.pdf）")
    ap.add_argument("--compile", action="store_true", help="统计前先重新编译")
    args = ap.parse_args()

    if args.compile:
        pdf = compile_thesis()
    else:
        pdf = Path(args.pdf) if args.pdf else ROOT / "main.pdf"
    if not pdf.exists():
        sys.exit(f"找不到 {pdf}，请先编译或用 --compile")

    pages = [(p.extract_text() or "") for p in pypdf.PdfReader(str(pdf)).pages]
    toc_pages = {i for i, t in enumerate(pages) if t.count("....") > 3}

    # 正文起点：目录之后第一次出现章页眉
    body_start = None
    for i, t in enumerate(pages):
        if i in toc_pages:
            continue
        first = [l.strip() for l in t.split("\n") if l.strip()][:3]
        if any(CHAPTER_HEADER.match(l) for l in first):
            body_start = i
            break

    if body_start is None:
        sys.exit("未能在 PDF 中定位正文起点，请检查页眉格式是否变化")

    # 后置部分起点：正文之后第一次以"参考文献"开头的页
    ref_page = None
    for i in range(body_start, len(pages)):
        if i in toc_pages:
            continue
        if pages[i].strip().startswith(REF_HEADING):
            ref_page = i
            break

    per_chapter = collections.defaultdict(lambda: [0, 0, 0])  # 页数, 中文字, 含标点
    chapter = None
    back = [0, 0]
    for i in range(body_start, len(pages)):
        if i in toc_pages:
            continue
        lines = content_lines(pages[i])
        body = "".join(lines)
        cjk, full = count(body)
        if ref_page is not None and i >= ref_page:
            back[0] += cjk
            back[1] += full
            continue
        first = [l.strip() for l in pages[i].split("\n") if l.strip()][:3]
        for l in first:
            m = CHAPTER_HEADER.match(l)
            if m:
                chapter = int(m.group(1))
                break
        if chapter is None:
            continue
        per_chapter[chapter][0] += 1
        per_chapter[chapter][1] += cjk
        per_chapter[chapter][2] += full

    front_cjk = sum(count("".join(content_lines(pages[i])))[0]
                    for i in range(0, body_start) if i not in toc_pages)

    print(f"\n统计文件：{pdf.relative_to(ROOT)}\n")
    print("  章 | 页数 |   中文字 |   含标点")
    print("  ---+------+----------+----------")
    total = [0, 0, 0]
    for c in sorted(per_chapter):
        n, cjk, full = per_chapter[c]
        total[0] += n
        total[1] += cjk
        total[2] += full
        print(f"   {c} | {n:4d} | {cjk:8d} | {full:8d}")
    print("  ---+------+----------+----------")
    print(f" 正文合计 | {total[0]:4d} | {total[1]:8d} | {total[2]:8d}")
    print(f"\n  前置部分（封面与中英文摘要，不含目录）：约 {front_cjk} 个中文字")
    print(f"  后置部分（参考文献/致谢/附录）：{back[0]} 个中文字")
    print(f"  全文 {len(pages)} 页")


if __name__ == "__main__":
    main()
