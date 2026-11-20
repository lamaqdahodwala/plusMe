
from schemas import CampusEvent

# Create a sample event
event = CampusEvent(
    is_event="banana",
    title="General Body Meeting",
    date="2026-11-26",
    time="7:00 PM",
    location="Hill Center",
    room=None,
    description="USACS general body meeting with free food."
)

# Print the validated event
print(event)

# Print it as JSON
print(event.model_dump_json(indent=2))