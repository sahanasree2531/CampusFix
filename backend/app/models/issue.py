from sqlalchemy import Column, Integer, String, Text, ForeignKey
from app.database import Base


class Issue(Base):
    __tablename__ = "issues"

    id = Column(Integer, primary_key=True, index=True)

    title = Column(String, nullable=False)

    category = Column(String, nullable=False)

    description = Column(Text, nullable=False)

    location = Column(String, nullable=False)

    priority = Column(String, default="Medium")

    status = Column(String, default="Reported")

    photo_url = Column(String, nullable=True)

    student_id = Column(Integer, ForeignKey("users.id"))

    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=True)