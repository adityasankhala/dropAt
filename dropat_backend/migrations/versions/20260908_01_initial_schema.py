"""Create the initial DropAt schema.

Revision ID: 20260908_01
Revises:
Create Date: 2026-09-08
"""

from alembic import op
from sqlmodel import SQLModel

# Importing the package registers every SQLModel table with the shared metadata.
from app import models  # noqa: F401


revision = "20260908_01"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    SQLModel.metadata.create_all(bind=op.get_bind())


def downgrade() -> None:
    SQLModel.metadata.drop_all(bind=op.get_bind())
