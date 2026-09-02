from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.issue import Issue
from app.schemas.issue import IssueCreate, IssueResponse
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/issues",
    tags=["Issues"]
)


# ============================================================
# CREATE ISSUE
# ============================================================

@router.post("/", response_model=IssueResponse)
def create_issue(
    issue: IssueCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):

    # Only students can create issues
    if current_user["role"] != "student":
        raise HTTPException(
            status_code=403,
            detail="Only students can create issues"
        )

    new_issue = Issue(
        title=issue.title,
        category=issue.category,
        description=issue.description,
        location=issue.location,
        priority=issue.priority,
        status="Reported",
        photo_url=issue.photo_url,
        student_id=current_user["user_id"]
    )

    db.add(new_issue)
    db.commit()
    db.refresh(new_issue)

    return new_issue


# ============================================================
# GET MY ISSUES
# ============================================================

@router.get("/", response_model=list[IssueResponse])
def get_my_issues(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):

    issues = db.query(Issue).filter(
        Issue.student_id == current_user["user_id"]
    ).all()

    return issues


# ============================================================
# GET ONE ISSUE
# ============================================================

@router.get("/{issue_id}", response_model=IssueResponse)
def get_issue(
    issue_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):

    issue = db.query(Issue).filter(
        Issue.id == issue_id
    ).first()

    # Issue doesn't exist
    if not issue:
        raise HTTPException(
            status_code=404,
            detail="Issue not found"
        )

    # Students can only view their own issues
    if (
        current_user["role"] == "student"
        and issue.student_id != current_user["user_id"]
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not allowed to view this issue"
        )

    return issue