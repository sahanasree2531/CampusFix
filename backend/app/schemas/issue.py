from pydantic import BaseModel
from typing import Optional


class IssueCreate(BaseModel):
    title: str
    category: str
    description: str
    location: str
    priority: str = "Medium"
    photo_url: Optional[str] = None


class IssueStatusUpdate(BaseModel):
    status: str


class IssueResponse(BaseModel):
    id: int
    title: str
    category: str
    description: str
    location: str
    priority: str
    status: str
    photo_url: Optional[str] = None
    student_id: int
    assigned_to: Optional[int] = None

    class Config:
        from_attributes = True