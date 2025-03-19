from fastapi import FastAPI
from .predictor.predict import router as predict_router  # Note the change here

app = FastAPI()

print(predict_router)

app.include_router(predict_router, prefix="/predict", tags=["predict"])

@app.get("/")
async def read():
    return {"message": "Hello, FastAPI!"}
