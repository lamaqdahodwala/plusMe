
from parser import parse_instagram_post


def main():
    print("=== +me Instagram Event Agent ===")
    print("Paste your Instagram caption below.")
    print("When finished, type END on its own line.")

    lines = []

    while True:
        line = input()

        if line.strip() == "END":
            break

        lines.append(line)

    caption = "\n".join(lines)

    if not caption.strip():
        print("No caption provided.")
        return

    print("\nAnalyzing post...")

    event = parse_instagram_post(caption)

    print("\n=== PARSED RESULT ===")

    if event.is_event:
        print("Event detected!")
    else:
        print("No event detected.")

    print(event.model_dump_json(indent=2))


if __name__ == "__main__":
    main()
