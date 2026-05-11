-- Jarvis Memory Graph Initialization
-- PostgreSQL with Apache AGE + pgvector

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS age;

-- Load AGE and set search path
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create the memory graph
SELECT create_graph('jarvis_memory');

-- Create embedding table for hybrid search (pgvector)
-- This table stores embeddings for AGE graph nodes
CREATE TABLE IF NOT EXISTS node_embeddings (
    node_id TEXT PRIMARY KEY,
    user_id UUID NOT NULL,
    node_type TEXT NOT NULL,
    label TEXT NOT NULL,
    embedding vector(384),  -- sentence-transformers all-MiniLM-L6-v2 dimension
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_node_embeddings_user_id ON node_embeddings(user_id);
CREATE INDEX IF NOT EXISTS idx_node_embeddings_node_type ON node_embeddings(node_type);
CREATE INDEX IF NOT EXISTS idx_node_embeddings_vector ON node_embeddings
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Create belief history table for tracking changes
CREATE TABLE IF NOT EXISTS belief_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_id TEXT NOT NULL,
    field TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT NOT NULL,
    confidence FLOAT NOT NULL,
    source_message_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_belief_history_entity ON belief_history(entity_id);
CREATE INDEX IF NOT EXISTS idx_belief_history_user ON belief_history(user_id);

-- Create pending conflicts table (for low-confidence updates that need user input)
CREATE TABLE IF NOT EXISTS pending_conflicts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_id TEXT NOT NULL,
    field TEXT NOT NULL,
    current_value TEXT,
    proposed_value TEXT NOT NULL,
    confidence FLOAT NOT NULL,
    source_message_id UUID,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    resolution TEXT,  -- 'accepted', 'rejected', 'merged'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pending_conflicts_user ON pending_conflicts(user_id, resolved);

-- Grant permissions
GRANT USAGE ON SCHEMA ag_catalog TO jarvis;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ag_catalog TO jarvis;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ag_catalog TO jarvis;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO jarvis;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO jarvis;

-- Verify setup
DO $$
BEGIN
    RAISE NOTICE 'Jarvis Memory Graph initialized successfully';
    RAISE NOTICE 'Graph: jarvis_memory';
    RAISE NOTICE 'Extensions: age, vector';
END $$;
