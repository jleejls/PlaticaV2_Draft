#!/usr/bin/env python3
"""
insert_guide_audio.py

Utility for InglésYa / Pathway Guides.

What it does:
- Reads a guidelines_audio JSON file with keys like guide01, guide02, guide03...
- Inserts one new guide at the position you choose.
- Renumbers all guide keys automatically.
- Writes a new JSON file, leaving the original untouched.

Example:
python insert_guide_audio.py guidelines_audio.json --insert-at 2 --audio ./audio/new_guide.m4a --output guidelines_audio_new.json

That example creates:
guide01 = original guide01
guide02 = new audio
guide03 = original guide02
guide04 = original guide03
...
"""

import argparse
import json
import re
from collections import OrderedDict
from pathlib import Path


GUIDE_KEY_RE = re.compile(r"^guide(\d+)$")


def guide_number(key: str) -> int:
    match = GUIDE_KEY_RE.match(key)
    if not match:
        raise ValueError(f"Bad guide key: {key!r}. Expected guide01, guide02, etc.")
    return int(match.group(1))


def key_width(keys) -> int:
    widths = []
    for key in keys:
        match = GUIDE_KEY_RE.match(key)
        if match:
            widths.append(len(match.group(1)))
    return max(widths) if widths else 2


def insert_guide(data: dict, insert_at: int, audio_path: str) -> OrderedDict:
    if insert_at < 1:
        raise ValueError("--insert-at must be 1 or higher.")

    sorted_items = sorted(data.items(), key=lambda item: guide_number(item[0]))
    width = key_width(data.keys())

    new_items = []
    inserted = False

    for old_key, value in sorted_items:
        old_num = guide_number(old_key)

        if old_num == insert_at and not inserted:
            new_items.append({"audio": audio_path})
            inserted = True

        new_items.append(value)

    # Allow inserting after the last existing guide.
    if not inserted:
        max_existing = guide_number(sorted_items[-1][0]) if sorted_items else 0
        if insert_at == max_existing + 1:
            new_items.append({"audio": audio_path})
            inserted = True
        else:
            raise ValueError(
                f"Cannot insert at guide{insert_at:0{width}d}; "
                f"current file only goes through guide{max_existing:0{width}d}."
            )

    renumbered = OrderedDict()
    for index, value in enumerate(new_items, start=1):
        renumbered[f"guide{index:0{width}d}"] = value

    return renumbered


def main():
    parser = argparse.ArgumentParser(
        description="Insert a guide audio into guidelines_audio.json and renumber automatically."
    )
    parser.add_argument("input_json", help="Path to the existing guidelines_audio JSON file.")
    parser.add_argument(
        "--insert-at",
        type=int,
        required=True,
        help="Guide number where the new audio should be inserted. Example: 2 inserts as guide02.",
    )
    parser.add_argument(
        "--audio",
        required=True,
        help="Audio path to insert. Example: ./audio/new_guide.m4a",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Output JSON file. If omitted, creates INPUTNAME_updated.json.",
    )
    args = parser.parse_args()

    input_path = Path(args.input_json)

    if not input_path.exists():
        raise FileNotFoundError(f"Could not find input file: {input_path}")

    with input_path.open("r", encoding="utf-8") as f:
        data = json.load(f, object_pairs_hook=OrderedDict)

    renumbered = insert_guide(data, args.insert_at, args.audio)

    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_name(input_path.stem + "_updated" + input_path.suffix)

    with output_path.open("w", encoding="utf-8") as f:
        json.dump(renumbered, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Done. Wrote: {output_path}")
    print(f"Total guides now: {len(renumbered)}")


if __name__ == "__main__":
    main()
