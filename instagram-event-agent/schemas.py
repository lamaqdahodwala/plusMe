
from pydantic import BaseModel, Field
from typing import Optional


class CampusEvent(BaseModel):
    is_event: bool = Field(
        description="Whether this Instagram post advertises an actual event."
    )

    title: Optional[str] = Field(
        default=None,
        description="The name or title of the event."
    )

    date: Optional[str] = Field(
        default=None,
        description="The event date in YYYY-MM-DD format."
    )

    time: Optional[str] = Field(
        default=None,
        description="The event start time."
    )

    location: Optional[str] = Field(
        default=None,
        description="The building or general location of the event."
    )

    room: Optional[str] = Field(
        default=None,
        description="The specific room number or room name, if provided."
    )

    description: Optional[str] = Field(
        default=None,
        description="A concise description of the event."
    )
