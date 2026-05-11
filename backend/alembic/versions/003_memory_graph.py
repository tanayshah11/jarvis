"""Add memory graph tables with pgvector

Revision ID: 003_memory_graph
Revises: 002_conversations_messages
Create Date: 2024-11-24

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '003_memory_graph'
down_revision: Union[str, None] = '002_conversations_messages'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable pgvector extension
    op.execute('CREATE EXTENSION IF NOT EXISTS vector')

    # Create memory_nodes table
    op.create_table(
        'memory_nodes',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('node_type', sa.String(50), nullable=False),
        sa.Column('label', sa.String(255), nullable=False),
        sa.Column('attributes', postgresql.JSONB(), nullable=False, server_default='{}'),
        sa.Column('confidence', sa.Float(), nullable=False, server_default='1.0'),
        sa.Column('source_message_ids', postgresql.ARRAY(postgresql.UUID(as_uuid=True)), nullable=False, server_default='{}'),
        sa.Column('reference_count', sa.Integer(), nullable=False, server_default='1'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('last_referenced', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_memory_nodes_user_id', 'memory_nodes', ['user_id'])
    op.create_index('ix_memory_nodes_node_type', 'memory_nodes', ['node_type'])
    op.create_index('ix_memory_nodes_label', 'memory_nodes', ['label'])

    # Add vector column for embeddings (1536 dimensions for OpenAI embeddings)
    op.execute('ALTER TABLE memory_nodes ADD COLUMN embedding vector(1536)')

    # Create index for vector similarity search (using IVFFlat for faster queries)
    op.execute('''
        CREATE INDEX ix_memory_nodes_embedding
        ON memory_nodes
        USING ivfflat (embedding vector_cosine_ops)
        WITH (lists = 100)
    ''')

    # Create memory_edges table
    op.create_table(
        'memory_edges',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('source_node_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('target_node_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('relation_type', sa.String(100), nullable=False),
        sa.Column('attributes', postgresql.JSONB(), nullable=False, server_default='{}'),
        sa.Column('strength', sa.Float(), nullable=False, server_default='1.0'),
        sa.Column('source_message_ids', postgresql.ARRAY(postgresql.UUID(as_uuid=True)), nullable=False, server_default='{}'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['source_node_id'], ['memory_nodes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['target_node_id'], ['memory_nodes.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_memory_edges_user_id', 'memory_edges', ['user_id'])
    op.create_index('ix_memory_edges_source_node_id', 'memory_edges', ['source_node_id'])
    op.create_index('ix_memory_edges_target_node_id', 'memory_edges', ['target_node_id'])
    op.create_index('ix_memory_edges_relation_type', 'memory_edges', ['relation_type'])

    # Add preferred_ai_provider to jarvis_profiles
    op.add_column('jarvis_profiles', sa.Column('preferred_ai_provider', sa.String(50), server_default='anthropic', nullable=False))


def downgrade() -> None:
    # Remove preferred_ai_provider from jarvis_profiles
    op.drop_column('jarvis_profiles', 'preferred_ai_provider')

    # Drop memory_edges
    op.drop_index('ix_memory_edges_relation_type', table_name='memory_edges')
    op.drop_index('ix_memory_edges_target_node_id', table_name='memory_edges')
    op.drop_index('ix_memory_edges_source_node_id', table_name='memory_edges')
    op.drop_index('ix_memory_edges_user_id', table_name='memory_edges')
    op.drop_table('memory_edges')

    # Drop memory_nodes
    op.execute('DROP INDEX IF EXISTS ix_memory_nodes_embedding')
    op.drop_index('ix_memory_nodes_label', table_name='memory_nodes')
    op.drop_index('ix_memory_nodes_node_type', table_name='memory_nodes')
    op.drop_index('ix_memory_nodes_user_id', table_name='memory_nodes')
    op.drop_table('memory_nodes')

    # Note: We don't drop the vector extension as it might be used by other tables
