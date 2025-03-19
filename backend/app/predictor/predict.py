from fastapi import APIRouter

router = APIRouter()
print("hello world")

@router.get("/")
async def give_prediction():
    return {"message": "This is a prediction"}
