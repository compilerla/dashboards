import os


def get_secret(name: str) -> str | None:
    """Resolve a secret from the environment.

    Reads secrets from environment variables. For future use, a Secret Manager
    fallback path can be added here.

    Args:
        name: The secret name (e.g., "TOGGL_API_TOKEN").

    Returns:
        The secret value, or None if not found.
    """
    return os.environ.get(name)
