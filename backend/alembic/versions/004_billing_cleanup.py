"""Remove user data tables, add billing tables

Revision ID: 004_billing_cleanup
Revises: 003_memory_graph
Create Date: 2024-11-25

This migration:
- Drops tables that move to device (conversations, messages, jarvis_profiles, memory_*)
- Adds Stripe billing tables (subscriptions, usage_records, webhook_events)
- Adds stripe_customer_id to users table
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '004_billing_cleanup'
down_revision: Union[str, None] = '003_memory_graph'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ========================================
    # 1. DROP tables that move to device
    # ========================================

    # Drop messages first (depends on conversations)
    op.drop_index('ix_messages_conversation_id', table_name='messages', if_exists=True)
    op.drop_index('ix_messages_created_at', table_name='messages', if_exists=True)
    op.drop_index('ix_messages_memory_extracted', table_name='messages', if_exists=True)
    op.drop_table('messages')

    # Drop conversations (depends on users)
    op.drop_index('ix_conversations_user_id', table_name='conversations', if_exists=True)
    op.drop_index('ix_conversations_created_at', table_name='conversations', if_exists=True)
    op.drop_table('conversations')

    # Drop jarvis_profiles
    op.drop_table('jarvis_profiles')

    # Drop memory_edges (depends on memory_nodes)
    op.drop_index('ix_memory_edges_user_id', table_name='memory_edges', if_exists=True)
    op.drop_index('ix_memory_edges_source_node_id', table_name='memory_edges', if_exists=True)
    op.drop_index('ix_memory_edges_target_node_id', table_name='memory_edges', if_exists=True)
    op.drop_index('ix_memory_edges_relation_type', table_name='memory_edges', if_exists=True)
    op.drop_table('memory_edges')

    # Drop memory_nodes
    op.execute('DROP INDEX IF EXISTS ix_memory_nodes_embedding')
    op.drop_index('ix_memory_nodes_user_id', table_name='memory_nodes', if_exists=True)
    op.drop_index('ix_memory_nodes_node_type', table_name='memory_nodes', if_exists=True)
    op.drop_index('ix_memory_nodes_label', table_name='memory_nodes', if_exists=True)
    op.drop_table('memory_nodes')

    # Drop AGE-related tables (from init.sql)
    op.execute('DROP TABLE IF EXISTS pending_conflicts CASCADE')
    op.execute('DROP TABLE IF EXISTS belief_history CASCADE')
    op.execute('DROP TABLE IF EXISTS node_embeddings CASCADE')

    # Drop AGE graph (if exists)
    op.execute("""
        DO $$
        BEGIN
            IF EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = 'jarvis_memory') THEN
                PERFORM drop_graph('jarvis_memory', true);
            END IF;
        EXCEPTION WHEN OTHERS THEN
            -- AGE extension might not be loaded, ignore
            NULL;
        END $$;
    """)

    # ========================================
    # 2. ADD stripe_customer_id to users
    # ========================================
    op.add_column('users', sa.Column('stripe_customer_id', sa.String(255), unique=True, nullable=True))
    op.create_index('ix_users_stripe_customer_id', 'users', ['stripe_customer_id'], unique=True)

    # ========================================
    # 3. CREATE subscriptions table
    # ========================================
    op.create_table(
        'subscriptions',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('stripe_customer_id', sa.String(255), nullable=False),
        sa.Column('stripe_subscription_id', sa.String(255), nullable=True),
        sa.Column('tier', sa.String(20), nullable=False, server_default='free'),
        sa.Column('status', sa.String(20), nullable=False, server_default='active'),
        sa.Column('current_period_start', sa.DateTime(timezone=True), nullable=True),
        sa.Column('current_period_end', sa.DateTime(timezone=True), nullable=True),
        sa.Column('cancel_at_period_end', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('canceled_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id'),
        sa.UniqueConstraint('stripe_customer_id'),
        sa.UniqueConstraint('stripe_subscription_id'),
    )
    op.create_index('ix_subscriptions_user_id', 'subscriptions', ['user_id'])
    op.create_index('ix_subscriptions_stripe_customer_id', 'subscriptions', ['stripe_customer_id'])
    op.create_index('ix_subscriptions_stripe_subscription_id', 'subscriptions', ['stripe_subscription_id'])

    # ========================================
    # 4. CREATE usage_records table
    # ========================================
    op.create_table(
        'usage_records',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False, server_default=sa.text('gen_random_uuid()')),
        sa.Column('subscription_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('period_start', sa.DateTime(timezone=True), nullable=False),
        sa.Column('period_end', sa.DateTime(timezone=True), nullable=False),
        sa.Column('tokens_used', sa.BigInteger(), nullable=False, server_default='0'),
        sa.Column('token_limit', sa.BigInteger(), nullable=False),
        sa.Column('llm_calls', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('NOW()')),
        sa.ForeignKeyConstraint(['subscription_id'], ['subscriptions.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('subscription_id', 'period_start', name='uq_usage_subscription_period'),
    )
    op.create_index('ix_usage_records_subscription_period', 'usage_records', ['subscription_id', 'period_start'])

    # ========================================
    # 5. CREATE webhook_events table
    # ========================================
    op.create_table(
        'webhook_events',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False, server_default=sa.text('gen_random_uuid()')),
        sa.Column('stripe_event_id', sa.String(255), nullable=False),
        sa.Column('event_type', sa.String(100), nullable=False),
        sa.Column('payload', postgresql.JSONB(), nullable=True),
        sa.Column('processed_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('NOW()')),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('stripe_event_id'),
    )
    op.create_index('ix_webhook_events_stripe_event_id', 'webhook_events', ['stripe_event_id'])
    op.create_index('ix_webhook_events_event_type', 'webhook_events', ['event_type'])


def downgrade() -> None:
    # Drop billing tables
    op.drop_index('ix_webhook_events_event_type', table_name='webhook_events')
    op.drop_index('ix_webhook_events_stripe_event_id', table_name='webhook_events')
    op.drop_table('webhook_events')

    op.drop_index('ix_usage_records_subscription_period', table_name='usage_records')
    op.drop_table('usage_records')

    op.drop_index('ix_subscriptions_stripe_subscription_id', table_name='subscriptions')
    op.drop_index('ix_subscriptions_stripe_customer_id', table_name='subscriptions')
    op.drop_index('ix_subscriptions_user_id', table_name='subscriptions')
    op.drop_table('subscriptions')

    # Remove stripe_customer_id from users
    op.drop_index('ix_users_stripe_customer_id', table_name='users')
    op.drop_column('users', 'stripe_customer_id')

    # NOTE: Downgrade does not recreate the dropped user data tables
    # Those would need to be restored from backup or recreated manually
    # This is intentional - billing cleanup is a one-way migration
