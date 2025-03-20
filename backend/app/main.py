from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .predictor.predict import router as predict_router  # Adjust your import as needed

app = FastAPI()

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # can restrict this to specific origins if needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(predict_router, prefix="/predict", tags=["predict"])

@app.get("/")
async def read():
    return {"message": "Hello, FastAPI!"}
