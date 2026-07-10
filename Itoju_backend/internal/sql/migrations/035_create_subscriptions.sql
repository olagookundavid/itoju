-- +goose Up
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users ON DELETE CASCADE,
    rc_app_user_id TEXT NOT NULL,
    entitlement TEXT NOT NULL,
    status TEXT NOT NULL,
    platform TEXT,
    product_id TEXT,
    environment TEXT,
    expires_at TIMESTAMPTZ,
    last_event_id TEXT,
    last_event_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_subscriptions_user_entitlement UNIQUE (user_id, entitlement)
);

CREATE INDEX idx_subscriptions_rc_app_user ON subscriptions (rc_app_user_id);

-- +goose Down
DROP TABLE IF EXISTS subscriptions;
