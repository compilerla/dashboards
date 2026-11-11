"""Fixtures for ingestion tests."""

import pendulum
import pytest
from pendulum.testing.traveller import Traveller


@pytest.fixture
def fixed_time():
    """Fixture to fix pendulum.now() to a specific time.

    Usage:
        def test_something(fixed_time):
            with fixed_time("2026-11-10 12:00:00"):
                assert pendulum.now("UTC").date() == date(2026, 11, 10)
    """
    return _FixedTimeContext()


class _FixedTimeContext:
    """Callable context manager for fixing time."""

    def __call__(self, dt_str, tz="UTC"):
        t = Traveller()
        dt = pendulum.parse(dt_str, tz=tz)
        return t.travel_to(dt)
