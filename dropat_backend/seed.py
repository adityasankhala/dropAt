"""
Database Seeder
───────────────
Populates the database with demo routes and waypoints for Jaipur.
Run this script once to set up the initial data.
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
    """Seed the database with initial demo data."""
    print("Creating tables...")
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)

    print("Seeding data...")
    async with async_session_factory() as session:
        
        # 1. Routes
        route1 = Route(
            name="Hostel → College",
            description="Morning shuttle from Manipal Hostel to College Campus",
            price=20.0,
            total_seats=25,
            schedule=[
                {"departure_time": "08:00 AM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri"]},
                {"departure_time": "08:30 AM", "days": ["Mon", "Tue", "Wed", "Thu", "Fri"]}
            ],
            estimated_duration_min=15,
        )
        
        route2 = Route(
            name="College → Market",
            description="Evening shuttle to local market",
            price=30.0,
            total_seats=25,
            schedule=[
                {"departure_time": "05:00 PM", "days": ["Mon", "Wed", "Fri", "Sat"]},
                {"departure_time": "06:30 PM", "days": ["Mon", "Wed", "Fri", "Sat"]}
            ],
            estimated_duration_min=25,
        )
        
        session.add(route1)
        session.add(route2)
        await session.flush()
        
        # 2. Waypoints for Route 1 (Hostel -> College)
        w1_1 = Waypoint(route_id=route1.id, name="Boys Hostel B1", lat=26.8436, lng=75.5652, order=1, is_fixed=True)
        w1_2 = Waypoint(route_id=route1.id, name="Girls Hostel G1", lat=26.8441, lng=75.5661, order=2, is_fixed=True)
        w1_3 = Waypoint(route_id=route1.id, name="Main Gate", lat=26.8450, lng=75.5670, order=3, is_fixed=True)
        w1_4 = Waypoint(route_id=route1.id, name="Academic Block 1", lat=26.8465, lng=75.5685, order=4, is_fixed=True)
        
        session.add_all([w1_1, w1_2, w1_3, w1_4])
        
        # 3. Waypoints for Route 2 (College -> Market)
        w2_1 = Waypoint(route_id=route2.id, name="Main Gate", lat=26.8450, lng=75.5670, order=1, is_fixed=True)
        w2_2 = Waypoint(route_id=route2.id, name="Bagru Bus Stand", lat=26.8156, lng=75.5422, order=2, is_fixed=True)
        w2_3 = Waypoint(route_id=route2.id, name="Ajmer Road Crossing", lat=26.8833, lng=75.7145, order=3, is_fixed=True)
        
        session.add_all([w2_1, w2_2, w2_3])
        
        # 4. Vouchers
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
        print("✅ Database seeded successfully!")


if __name__ == "__main__":
    asyncio.run(seed_data())
