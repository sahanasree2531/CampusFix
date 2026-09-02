from fastapi import FastAPI

from app.database import engine, Base
from app.models import User, Issue

from app.routes.auth import router as auth_router
from app.routes.issues import router as issues_router
from app.routes.admin import router as admin_router
from app.routes.maintenance import router as maintenance_router


app = FastAPI(
    title="CampusFix API",
    description="Smart Campus Issue Reporting & Maintenance Management System",
    version="1.0.0"
)


Base.metadata.create_all(bind=engine)


app.include_router(auth_router)
app.include_router(issues_router)
app.include_router(admin_router)
app.include_router(maintenance_router)


@app.get("/")
def root():
    return {
        "message": "CampusFix Backend is running!"
    }