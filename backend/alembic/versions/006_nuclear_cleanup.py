"""Nuclear cleanup - Drop all user data tables for privacy-first architecture

This migration removes all user data tables from the backend.
In the privacy-first architecture, ALL user data stays on-device:
- Conversations -> On-device SQLite
- Messages -> On-device SQLite
- Memory graph (nodes/edges) -> On-device SQLite + ObjectBox vectors
- User preferences -> On-device SharedPreferences
- Jarvis profiles -> On-device SQLite
- Connections (OAuth) -> On-device (Apple/Google SDKs)
- Tasks -> No longer needed

Backend becomes a thin, stateless LLM proxy with only:
- users table (auth)
- billing tables (subscriptions, usage_records, webhook_events)

Revision ID: 006_nuclear_cleanup
Revises: 97ac2536a173
Create Date: 2025-11-28

"""
from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = '006_nuclear_cleanup'
down_revision: Union[str, None] = '97ac2536a173'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Drop all user data tables - backend becomes stateless LLM proxy.
    Using raw SQL with IF EXISTS to handle partial drops.
    """
    # Use CASCADE to automatically drop dependent objects
    op.execute('DROP TABLE IF EXISTS user_preferences CASCADE')
    op.execute('DROP TABLE IF EXISTS memory_edges CASCADE')
    op.execute('DROP TABLE IF EXISTS memory_nodes CASCADE')
    op.execute('DROP TABLE IF EXISTS messages CASCADE')
    op.execute('DROP TABLE IF EXISTS conversations CASCADE')
    op.execute('DROP TABLE IF EXISTS jarvis_profiles CASCADE')
    op.execute('DROP TABLE IF EXISTS tasks CASCADE')
    op.execute('DROP TABLE IF EXISTS connections CASCADE')


def downgrade() -> None:
    """
    Note: This is a destructive migration.
    Downgrade just shows what would need to be recreated.
    User data has moved to device and cannot be restored.
    """
    # To properly downgrade, run previous migrations: 001 -> 005
    # This is intentionally left minimal as the architecture has changed
    raise NotImplementedError(
        "Cannot downgrade: User data has moved to device. "
        "Run migrations 001-005 to recreate tables if needed."
    )
