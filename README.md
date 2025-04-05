# Backend Setup Guide

This guide will walk you through setting up the backend of the application, including placing the model file, activating the virtual environment, installing dependencies, and running the application.

## Prerequisites

- Python 3.7 or above installed on your machine
- A virtual environment configured in the `backend` directory

## Setup Steps

1. **Place the Model File**
   - Copy the `model.h5` file into the `app/predictor` directory.

2. **Open Terminal and Navigate to the Backend Directory**
   - If you're not already in the `backend` directory, run the following command:
     ```bash
     cd backend
     ```

3. **Activate the Virtual Environment**
   - Activate the virtual environment using the following command (Windows):
     ```bash
     .\env\Scripts\activate
     ```
   - For macOS/Linux, use:
     ```bash
     source env/bin/activate
     ```

4. **Install Dependencies**
   - Install the required Python packages by running:
     ```bash
     pip install -r requirements.txt
     ```

5. **Run the Application**
   - Start the backend server with hot-reloading enabled:
     ```bash
     python -m uvicorn app.main:app --reload
     ```


