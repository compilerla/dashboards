# Source registration will happen when sources are loaded
import click

from ingestion.base import cli


@click.group()
@click.version_option()
def main():
    """Data ingestion framework for Compiler's analytics warehouse."""
    pass


def register_source(group: click.Group, source_name: str, puller_class) -> None:
    """Register a source subcommand with the main CLI group.

    Each ingestion source (e.g., Toggl, Asana) provides a Puller subclass
    and is registered here so it becomes available as `ingestion <source> pull`.

    Args:
        group: The Click group to register the subcommand on.
        source_name: The name of the source (e.g., "toggl").
        puller_class: A class that inherits from `ingestion.base.base.Puller`.
    """

    @group.command()
    @click.argument("action", type=click.Choice(["pull"]))
    @click.option("--start", "start_date", help="Start date (absolute or relative keyword)")
    @click.option("--end", "end_date", help="End date (absolute or relative keyword)")
    def pull(action: str, start_date: str | None, end_date: str | None):
        """Pull data for the given date range."""
        resolved_start, resolved_end = cli.resolve_date_range(start_date, end_date)
        puller = puller_class()
        puller.pull(source=source_name, start_date=resolved_start, end_date=resolved_end)

    group.add_command(pull, source_name)
