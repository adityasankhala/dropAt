"""
Database Seeder — Real Bagru → Jaipur Routes
──────────────────────────────────────────────
Populates the database with actual campus shuttle routes.

ROUTE LOGIC (2 shuttles, optimized):
  College is in Bagru, ~25km west of Jaipur city center.
  Students go to 7 key destinations in Jaipur.

  Route A (City Express) — south-east corridor:
    Bagru → Airport → Malviya Nagar → WTP → C-Scheme
    WHY: These 4 stops form a clean south→center line on the map.
          One bus can cover them without backtracking.

  Route B (Station Express) — north corridor:
    Bagru → Chandpole → Sindhi Camp → Railway Station
    WHY: Chandpole/Sindhi Camp/Station are clustered in old city.
          Avoids crossing into the south corridor.
"""

import asyncio
from datetime import datetime

from sqlmodel import SQLModel

from app.core.database import engine, async_session_factory
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.trip import Trip, TripMode
from app.models.voucher import Voucher


async def seed_data():
    """Seed the database with real Bagru-Jaipur shuttle routes."""
    print("Creating tables...")
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)

    print("Seeding data...")
    async with async_session_factory() as session:

        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # ROUTE A — City Express (South-East)
        # Bagru → Airport → Malviya Nagar → WTP → C-Scheme
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        route_a = Route(
            name="City Express",
            description="Bagru → Airport → Malviya Nagar → WTP → C-Scheme. Covers the south-east corridor of Jaipur.",
            price=60.0,
            total_seats=30,
            schedule=[
                {"departure_time": "07:00 AM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]},
                {"departure_time": "05:00 PM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]},
            ],
            estimated_duration_min=55,
        )

        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # ROUTE B — Station Express (North)
        # Bagru → Chandpole → Sindhi Camp → Railway Station
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        route_b = Route(
            name="Station Express",
            description="Bagru → Chandpole → Sindhi Camp Bus Stand → Jaipur Railway Station. Covers the old city and transport hubs.",
            price=50.0,
            total_seats=30,
            schedule=[
                {"departure_time": "07:00 AM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]},
                {"departure_time": "05:30 PM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]},
            ],
            estimated_duration_min=45,
        )

        session.add(route_a)
        session.add(route_b)
        await session.flush()

        # ── Route A Waypoints (real GPS coordinates) ──
        # 1. College Campus (Bagru)
        wa_1 = Waypoint(route_id=route_a.id, name="College Campus (Bagru)",
                        lat=26.8156, lng=75.5422, order=1, is_fixed=True)
        # 2. Jaipur Airport (Sanganer)
        wa_2 = Waypoint(route_id=route_a.id, name="Jaipur Airport",
                        lat=26.8242, lng=75.8122, order=2, is_fixed=True)
        # 3. Malviya Nagar
        wa_3 = Waypoint(route_id=route_a.id, name="Malviya Nagar",
                        lat=26.8530, lng=75.8025, order=3, is_fixed=True)
        # 4. World Trade Park (WTP)
        wa_4 = Waypoint(route_id=route_a.id, name="WTP (World Trade Park)",
                        lat=26.8927, lng=75.8050, order=4, is_fixed=True)
        # 5. C-Scheme
        wa_5 = Waypoint(route_id=route_a.id, name="C-Scheme",
                        lat=26.9040, lng=75.7930, order=5, is_fixed=True)

        session.add_all([wa_1, wa_2, wa_3, wa_4, wa_5])

        # ── Route B Waypoints (real GPS coordinates) ──
        # 1. College Campus (Bagru) — same starting point
        wb_1 = Waypoint(route_id=route_b.id, name="College Campus (Bagru)",
                        lat=26.8156, lng=75.5422, order=1, is_fixed=True)
        # 2. Chandpole
        wb_2 = Waypoint(route_id=route_b.id, name="Chandpole",
                        lat=26.9218, lng=75.7770, order=2, is_fixed=True)
        # 3. Sindhi Camp Bus Stand
        wb_3 = Waypoint(route_id=route_b.id, name="Sindhi Camp Bus Stand",
                        lat=26.9270, lng=75.7870, order=3, is_fixed=True)
        # 4. Jaipur Railway Station
        wb_4 = Waypoint(route_id=route_b.id, name="Jaipur Railway Station",
                        lat=26.9196, lng=75.7878, order=4, is_fixed=True)

        session.add_all([wb_1, wb_2, wb_3, wb_4])

        # ── Vouchers ──
        v1 = Voucher(
            code="WELCOME50",
            description="50% off your first ride",
            discount_amount=50.0,
            is_percentage=True,
            max_discount=100.0,
            usage_limit=1000,
        )
        v2 = Voucher(
            code="FLAT20",
            description="Flat ₹20 off",
            discount_amount=20.0,
            is_percentage=False,
            min_order_amount=50.0,
            usage_limit=500,
        )
        session.add_all([v1, v2])

        await session.commit()
        print("✅ Database seeded with real Bagru → Jaipur routes!")
        print("   Route A (City Express): Bagru → Airport → Malviya Nagar → WTP → C-Scheme")
        print("   Route B (Station Express): Bagru → Chandpole → Sindhi Camp → Railway Station")


if __name__ == "__main__":
    asyncio.run(seed_data())

