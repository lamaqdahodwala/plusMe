
import os
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from datetime import datetime

from schemas import CampusEvent

# Load API key from .env
load_dotenv()

api_key = os.getenv("OPENROUTER_API_KEY")

if not api_key:
    raise ValueError("OPENROUTER_API_KEY not found in .env")

# Connect to OpenRouter
llm = ChatOpenAI(
    model="openai/gpt-4o-mini",
    openai_api_key=api_key,
    openai_api_base="https://openrouter.ai/api/v1",
    temperature=0
)

# Require the AI to return our Pydantic schema
structured_llm = llm.with_structured_output(
    CampusEvent,
    method="function_calling"
)


def parse_instagram_post(caption: str) -> CampusEvent:
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    prompt = f"""
        You are an AI assistant that extracts campus events from
        Instagram posts published by university organizations.

        Today's date is {current_date}.

        Your task is to determine whether a post advertises an actual
        event and extract the available information.

        IMPORTANT CLASSIFICATION RULES:

        1. An event announcement is still an event even if some
        details are missing.
        2. Phrases like "save the date", "join us", "register now",
        "we are hosting", and "coming soon" can indicate an event.
        3. Do NOT require a specific date, time, or location to
        classify something as an event.
        4. A holiday greeting, general announcement, or unrelated
        promotional post is NOT an event unless it advertises
        a specific activity or gathering.
        5. Never invent missing information. Use null instead.

        EXTRACTION RULES:

        - title: Extract or infer a concise title from the post.
        - date: Return YYYY-MM-DD when unambiguous.
        - time: Return the start time in HH:MM format when known.
        - location: Extract the building or general location.
        - room: Extract the specific room when available.
        - description: Summarize what the event is about.
        - is_event: True if the post advertises an actual event,
        even if details are incomplete.

        If a date is ambiguous, use null rather than guessing.

        Instagram post:
        {caption}
        """


    result = structured_llm.invoke(prompt)
    return result
