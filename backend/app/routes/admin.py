from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.database import get_db
from app.models.issue import Issue
from app.models.user import User
from app.schemas.issue import IssueResponse
from app.core.dependencies import get_current_admin


router = APIRouter(
    prefix="/admin",
    tags=["Admin"]
)


# ============================================================
# STATUS UPDATE REQUEST
# ============================================================

class IssueStatusUpdate(BaseModel):
    status: str


# ============================================================
# GET ALL ISSUES
# ============================================================

@router.get(
    "/issues/",
    response_model=list[IssueResponse]
)
def get_all_issues(
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):

    issues = db.query(Issue).all()

    return issues


# ============================================================
# ASSIGN ISSUE TO MAINTENANCE STAFF
# ============================================================

@router.put(
    "/issues/{issue_id}/assign/{staff_id}",
    response_model=IssueResponse
)
def assign_issue(
    issue_id: int,
    staff_id: int,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):

    # Find the issue
    issue = db.query(Issue).filter(
        Issue.id == issue_id
    ).first()

    if not issue:
        raise HTTPException(
            status_code=404,
            detail="Issue not found"
        )

    # Find the staff member
    staff = db.query(User).filter(
        User.id == staff_id
    ).first()

    if not staff:
        raise HTTPException(
            status_code=404,
            detail="Staff user not found"
        )

    # Make sure the user is maintenance staff
    if staff.role != "maintenance":
        raise HTTPException(
            status_code=400,
            detail="User is not maintenance staff"
        )

    # Assign the issue
    issue.assigned_to = staff.id

    # Change status
    issue.status = "Assigned"

    db.commit()
    db.refresh(issue)

    return issue


# ============================================================
# UPDATE ISSUE STATUS
# ============================================================

@router.put(
    "/issues/{issue_id}/status",
    response_model=IssueResponse
)
def update_issue_status(
    issue_id: int,
    status_update: IssueStatusUpdate,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):

    # Find the issue
    issue = db.query(Issue).filter(
        Issue.id == issue_id
    ).first()

    if not issue:
        raise HTTPException(
            status_code=404,
            detail="Issue not found"
        )

    # Allowed statuses for Admin
    allowed_statuses = [
        "Reported",
        "Assigned",
        "In Progress",
        "Resolved",
        "Closed"
    ]

    if status_update.status not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail="Invalid status"
        )

    # Update status
    issue.status = status_update.status

    db.commit()
    db.refresh(issue)

    return issue