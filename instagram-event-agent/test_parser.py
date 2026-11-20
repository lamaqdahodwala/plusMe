
from parser import parse_instagram_post

test_posts = [
    {
        "name": "Normal Event",
        "caption": """
        Join us November 26 at 7 PM in Hill Center,
        Room 114, for our General Body Meeting!
        Free food provided.
        """
    },
    {
        "name": "Incomplete Event",
        "caption": """
        Save the date! USACS is hosting a networking
        night next week. More details coming soon!
        """
    },
    {
        "name": "Non-Event",
        "caption": """
        Happy Halloween from USACS!
        We hope everyone has a fun and safe holiday!
        """
    }
]

for post in test_posts:
    print("\n" + "=" * 50)
    print(f"TEST: {post['name']}")
    print("=" * 50)

    try:
        event = parse_instagram_post(post["caption"])
        print(event.model_dump_json(indent=2))

    except Exception as error:
        print(f"ERROR: {error}")
