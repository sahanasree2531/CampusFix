from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.issue import Issue
from app.schemas.issue import IssueResponse, IssueStatusUpdate
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/maintenance",
    tags=["Maintenance"]
)


# ============================================================
# GET MY ASSIGNED ISSUES
# ============================================================

@router.get(
    "/issues/",
    response_model=list[IssueResponse]
)
def get_assigned_issues(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):

    if current_user["role"] != "maintenance":
        raise HTTPException(
            status_code=403,
            detail="Maintenance staff access required"
        )

    issues = db.query(Issue).filter(
        Issue.assigned_to == current_user["user_id"]
    ).all()

    return issues


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
    current_user: dict = Depends(get_current_user)
):

    # Only maintenance staff can update issue status
    if current_user["role"] != "maintenance":
        raise HTTPException(
            status_code=403,
            detail="Maintenance staff access required"
        )

    # Find the issue
    issue = db.query(Issue).filter(
        Issue.id == issue_id
    ).first()

    if not issue:
        raise HTTPException(
            status_code=404,
            detail="Issue not found"
        )

    # Make sure this issue is assigned to this staff member
    if issue.assigned_to != current_user["user_id"]:
        raise HTTPException(
            status_code=403,
            detail="This issue is not assigned to you"
        )

    # Only allow these status changes
    allowed_statuses = [
        "In Progress",
        "Resolved"
    ]

    if status_update.status not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail="Invalid status. Use 'In Progress' or 'Resolved'"
        )

    # Update status
    issue.status = status_update.status

    db.commit()
    db.refresh(issue)

    return issue