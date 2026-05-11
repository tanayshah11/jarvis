"""add_ai_settings_to_user_preferences

Revision ID: 97ac2536a173
Revises: 005_user_preferences
Create Date: 2025-11-28 01:18:42.408212

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '97ac2536a173'
down_revision: Union[str, None] = '005_user_preferences'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add AI settings columns with defaults
    op.add_column('user_preferences', sa.Column('ai_provider', sa.String(length=50), nullable=False, server_default='groq'))
    op.add_column('user_preferences', sa.Column('creativity', sa.Float(), nullable=False, server_default='0.5'))
    op.add_column('user_preferences', sa.Column('response_length', sa.String(length=20), nullable=False, server_default='medium'))


def downgrade() -> None:
    op.drop_column('user_preferences', 'response_length')
    op.drop_column('user_preferences', 'creativity')
    op.drop_column('user_preferences', 'ai_provider')
