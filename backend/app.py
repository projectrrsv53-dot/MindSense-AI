
from urllib import request

from fastapi import FastAPI, UploadFile, File,Form
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from email_services import (send_new_session_email
)
from alert_services import process_alert
from routes.emergency_routes import (
    router as emergency_router
)

import os
import uuid
import soundfile as sf
import shutil
from datetime import datetime

# ============================================================
# DATABASE/routes
# ============================================================

from database import db
from routes.auth_routes import (
    router as auth_router
)
from routes.doc_routes import (router as doctor_router)
from routes.admin_routes import router as admin_router
from routes.pat_routes import router as pat_router
from routes.appointment_router import router as appointment_router
from routes.alert_routes import router as alert_router
# Removed redundant module import that shadowed `appointment_router` router

from audio.audio_converter import convert_to_standard_wav
# ============================================================
# AUDIO
# ============================================================

from audio.audio_inference import (
    predict_audio,
    load_audio
)

from audio.preprocessing import process_file
from audio.speech_to_text import transcribe_audio

# ============================================================
# TEXT
# ============================================================

from text.clean_text import preprocess_text
from text.depression_predictor import predict_all

# ============================================================
# FUSION
# ============================================================

from fusion.fusion_inference import predict_fusion

# global holders for last saved session
last_inserted_id = None
last_session_data = None

async def save_session_result(session_data: dict):
    """Insert session_data into `analysis_results` and store last inserted info."""
    result = await db.analysis_results.insert_one(session_data)
    global last_inserted_id, last_session_data
    try:
        last_inserted_id = str(result.inserted_id)
    except Exception:
        last_inserted_id = None
    # copy session data and attach id for easy inspection
    last_session_data = dict(session_data)
    if last_inserted_id:
        last_session_data["_id"] = last_inserted_id
    return result
# ==========================================
# EMAIL CONNECTED DOCTORS
# ==========================================

async def notify_connected_doctors(
    patient_id: str,
    shared_with: list,
    analysis_type: str
):

    patient = await db.users.find_one({
        "user_id": patient_id
    })

    if not patient:
        return

    for doctor_info in shared_with:

        try:

            doctor = await db.users.find_one({
                "user_id": doctor_info["doctor_id"]
            })

            if doctor and doctor.get("email"):

                await send_new_session_email(
                    doctor["email"],
                    doctor["name"],
                    patient["name"],
                    analysis_type
                )

        except Exception as e:

            print(
                f"Failed to send email to "
                f"{doctor_info['doctor_id']}: {e}"
            )


def save_permanent_audio(cleaned_path: str, uid: str) -> str:
    """Copy cleaned audio to permanent storage and return its path."""
    os.makedirs(AUDIO_STORAGE_DIR, exist_ok=True)
    permanent_audio_path = os.path.join(
        AUDIO_STORAGE_DIR,
        f"{uid}.wav"
    )
    try:
        shutil.copy(cleaned_path, permanent_audio_path)
    except Exception:
        # if copy fails, raise so caller can handle
        raise
    return permanent_audio_path

# ===== CHANGE START: Generate recommendation from risk level =====
def generate_recommendation(risk_level: str) -> str:
    """Generate a recommendation based on depression risk level."""
    recommendations = {
        "LOW": "No significant signs of depression were detected. Continue maintaining healthy habits and monitor your emotional wellbeing.",
        "MEDIUM": "Some symptoms of depression were detected. Monitor your wellbeing and consider speaking with a mental health professional if symptoms persist.",
        "HIGH": "Signs of depression were detected. Scheduling an appointment with a licensed mental health professional is strongly recommended.",
        "CRITICAL": "Immediate professional intervention is recommended. Please contact your mental health provider or a trusted person immediately."
    }
    return recommendations.get(risk_level, "Please consult with a mental health professional for personalized guidance.")
# ===== CHANGE END =====

# ============================================================
# FASTAPI
# ============================================================

app = FastAPI()
app.include_router(auth_router)
app.include_router(admin_router)
app.include_router(pat_router)
app.include_router(doctor_router)
app.include_router(appointment_router)
app.include_router(alert_router)
app.include_router(emergency_router)
# Note: appointment_router is already the `router` instance imported above
# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
from fastapi.staticfiles import StaticFiles

app.mount(
    "/uploads",
    StaticFiles(directory="uploads"),
    name="uploads"
)
BASE_URL = "http://192.168.1.33:8000"
audio_url_template = (
    f"{BASE_URL}/uploads/patient_audio/{{uid}}.wav"
)


# ============================================================
# PATHS
# ============================================================

UPLOAD_DIR = "uploads"
OUTPUT_DIR = "outputs"
AUDIO_STORAGE_DIR = "uploads/patient_audio"

os.makedirs(
    AUDIO_STORAGE_DIR,
    exist_ok=True
)
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

SR = 16000

# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():

    return {
        "message": "Multimodal Depression API Running"
    }

# ============================================================
# TEXT PREDICTION API
# ============================================================
class TextRequest(BaseModel):
    patient_id: str
    text: str

@app.post("/predict-text")
async def predict_text(
     patient_id: str = Form(...),
    file: UploadFile = File(...)
):

    uid = str(uuid.uuid4())

    extension = os.path.splitext(file.filename)[1].lower()

    if extension == "":
        extension = ".wav"

    input_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}{extension}"
    )

    standard_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}_standard.wav"
    )

    cleaned_path = os.path.join(
        OUTPUT_DIR,
        f"{uid}_clean.wav"
    )

    try:

        # ====================================================
        # SAVE INPUT
        # ====================================================

        with open(input_path, "wb") as f:
            f.write(await file.read())

        # ====================================================
        # CLEAN AUDIO
        # ====================================================

        convert_to_standard_wav(
        input_path,
        standard_path,
    )

        cleaned_audio = process_file(
            standard_path
        )

        sf.write(
            cleaned_path,
            cleaned_audio,
            SR
        )

        # ====================================================
        # TRANSCRIBE
        # ====================================================

        transcript = transcribe_audio(
            cleaned_path
        )

        cleaned_text = preprocess_text(
            transcript
        )

        # ====================================================
        # TEXT MODEL
        # ====================================================

        prediction = predict_all(
            cleaned_text
        )
        
        # ===== CHANGE START: Calculate risk_level early =====
        depression = prediction["depression"]
        dep_label = depression["label"].lower() if isinstance(depression, dict) else str(depression).lower()
        dep_confidence = depression["confidence"] if isinstance(depression, dict) else 0.0

        if dep_label == "depressed":
            if dep_confidence >= 0.60:
                risk_level = "CRITICAL"
            elif dep_confidence >= 0.55:
                risk_level = "HIGH"
            else:
                risk_level = "MEDIUM"
        else:
            risk_level = "LOW"
        
        # ===== CHANGE START: Generate recommendation =====
        recommendation = generate_recommendation(risk_level)
        # ===== CHANGE END =====
        # ===== CHANGE END =====
        
        # ====================================================
        # GET CONNECTED DOCTORS
        # ====================================================

        shared_with = []

        cursor = db.doctor_patient_access.find({
            "patient_id": patient_id,
            "active": True
        })

        async for access in cursor:

            doctor = await db.users.find_one({
                "user_id": access["doctor_id"]
            })

            if doctor:
                shared_with.append({
                    "doctor_id": doctor["user_id"],
                    "doctor_name": f"Dr. {doctor['name']}"
                })

        # ====================================================
        # DATABASE SAVE (use single collection `analyze_results`)
        # ====================================================

        analysis_collection = db.analysis_results

        # persist cleaned audio permanently
        permanent_audio_path = save_permanent_audio(cleaned_path, uid)

        # ===== CHANGE START: Standardized session schema =====
        session_data = {

            "session_id": uid,

            "patient_id": patient_id,

            "analysis_type": "text",

            "shared_with": shared_with,

            "doctor_reviewed": False,

            "risk_level": risk_level,

            "critical_confirmed": False,

            "emergency_notified": False,

            "emergency_notified_at": None,

            "transcript": transcript,

            "cleaned_text": cleaned_text,

            "depression": prediction["depression"],

            "sentiment": prediction["sentiment"],

            "recommendation": recommendation,

            "audio_file": permanent_audio_path,

            "audio_url": audio_url_template.format(uid=uid),

            "created_at": datetime.utcnow()
        }
        # ===== CHANGE END =====

        await save_session_result(session_data)
        await process_alert(
            session_data
        )

        # ===== CHANGE START: Call notify once after session saved =====
        import asyncio
        asyncio.create_task(
            notify_connected_doctors(
                patient_id,
                shared_with,
                session_data["analysis_type"]
            )
        )
        # ===== CHANGE END =====

        return {

            "session_id": uid,

            "transcript": transcript,

            "cleaned_text": cleaned_text,

            "sentiment": prediction["sentiment"],

            "depression": prediction["depression"],

            "recommendation": recommendation
        }


    except Exception as e:

        return {
            "error": str(e)
        }

    finally:

        # ====================================================
        # CLEANUP
        # ====================================================

        try:

            if os.path.exists(input_path):
                os.remove(input_path)

            if os.path.exists(standard_path):
                os.remove(standard_path)

            if os.path.exists(cleaned_path):
                os.remove(cleaned_path)

        except Exception:
            pass

# ============================================================
# DIRECT TEXT INPUT API
# ============================================================

@app.post("/predict-text-direct")
async def predict_text_direct(request: TextRequest):

    try:

        cleaned_text = preprocess_text(
            request.text
        )

        prediction = predict_all(
            cleaned_text
        )
        depression = prediction["depression"]

        label = depression["label"].lower()
        confidence = depression["confidence"]

        if label == "depressed":

            if confidence >= 0.60:
                risk_level = "CRITICAL"

            elif confidence >= 0.55:
                risk_level = "HIGH"

            else:
                risk_level = "MEDIUM"

        else:
            risk_level = "LOW"
        
        # ===== CHANGE START: Generate recommendation =====
        recommendation = generate_recommendation(risk_level)
        # ===== CHANGE END =====
        
        # ====================================================
        # GET CONNECTED DOCTORS
        # ====================================================

        shared_with = []

        cursor = db.doctor_patient_access.find({
            "patient_id": request.patient_id,
            "active": True
        })

        async for access in cursor:

            doctor = await db.users.find_one({
                "user_id": access["doctor_id"]
            })

            if doctor:
                shared_with.append({
                    "doctor_id": doctor["user_id"],
                    "doctor_name": f"Dr. {doctor['name']}"
                })
        # ====================================================
        # DATABASE SAVE
        # ====================================================
        dep = prediction["depression"]
        # ===== CHANGE START: Standardized session schema =====
        session_data = {

            "session_id": str(uuid.uuid4()),

            "patient_id": request.patient_id,

            "analysis_type": "text",

            "shared_with": shared_with,

            "doctor_reviewed": False,

            "risk_level": risk_level,

            "critical_confirmed": False,

            "emergency_notified": False,

            "emergency_notified_at": None,

            "original_text": request.text,

            "cleaned_text": cleaned_text,

            # "depression": prediction["depression"],

            "depression": {
                "label": dep["label"],
                "prediction": dep["label"],
                "confidence": float(dep["confidence"]),
            },

            "sentiment": prediction["sentiment"],

            "recommendation": recommendation,

            "created_at": datetime.utcnow()
        }
        # ===== CHANGE END =====

        await save_session_result(session_data)
        await process_alert(
            session_data
        )

        # ===== CHANGE START: Fix notify call syntax =====
        import asyncio
        asyncio.create_task(
            notify_connected_doctors(
                request.patient_id,
                shared_with,
                session_data["analysis_type"]
            )
        )
        # ===== CHANGE END =====

        return {
            "session_id": session_data["session_id"],
            "original_text": request.text,
            "cleaned_text": cleaned_text,
            "depression": prediction["depression"],
            "sentiment": prediction["sentiment"],
            "recommendation": recommendation,
            "shared_with": shared_with,
            "doctor_reviewed": False
        }

    except Exception as e:

        return {
            "error": str(e)
        }

# ============================================================
# AUDIO ONLY API
# ============================================================

@app.post("/predict-audio")
async def predict_audio_route(
     patient_id: str=Form(...) ,
    file: UploadFile = File(...)
):

    uid = str(uuid.uuid4())

    extension = os.path.splitext(file.filename)[1].lower()

    if extension == "":
        extension = ".wav"

    input_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}{extension}"
    )

    standard_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}_standard.wav"
    )

    cleaned_path = os.path.join(
        OUTPUT_DIR,
        f"{uid}_clean.wav"
    )

    try:

        # ====================================================
        # SAVE INPUT
        # ====================================================

        with open(input_path, "wb") as f:
            f.write(await file.read())

        # ====================================================
        # PREPROCESS
        # ====================================================

        convert_to_standard_wav(
        input_path,
        standard_path,
    )

        cleaned_audio = process_file(
            standard_path
        )

        if cleaned_audio is None:

            return {
                "error": "Audio preprocessing failed"
            }

        if len(cleaned_audio) == 0:

            return {
                "error": "Empty processed audio"
            }

        # ====================================================
        # SAVE CLEANED AUDIO
        # ====================================================

        sf.write(
            cleaned_path,
            cleaned_audio,
            SR
        )

        # ====================================================
        # PREDICT
        # ====================================================

        result = predict_audio(
            cleaned_path
        )
        
        # ===== CHANGE START: Calculate risk_level =====
        audio_pred = result.get("depression", {})
        audio_label = audio_pred.get("label", "not_depressed").lower() if isinstance(audio_pred, dict) else str(audio_pred).lower()
        audio_confidence = audio_pred.get("confidence", 0.0) if isinstance(audio_pred, dict) else 0.0

        if audio_label == "depressed":
            if audio_confidence >= 0.60:
                risk_level = "CRITICAL"
            elif audio_confidence >= 0.55:
                risk_level = "HIGH"
            else:
                risk_level = "MEDIUM"
        else:
            risk_level = "LOW"
        
        # ===== CHANGE START: Generate recommendation =====
        recommendation = generate_recommendation(risk_level)
        # ===== CHANGE END =====
        # ===== CHANGE END =====
        
        # ====================================================
        # GET CONNECTED DOCTORS
        # ====================================================

        shared_with = []

        cursor = db.doctor_patient_access.find({
            "patient_id": patient_id,
            "active": True
        })

        async for access in cursor:

            doctor = await db.users.find_one({
                "user_id": access["doctor_id"]
            })

            if doctor:
                shared_with.append({
                    "doctor_id": doctor["user_id"],
                    "doctor_name": f"Dr. {doctor['name']}"
                })
        # ====================================================
        # DATABASE SAVE (use single collection `analyze_results`)
        # ====================================================

        analysis_collection = db.analysis_results

        permanent_audio_path = save_permanent_audio(cleaned_path, uid)

        # ===== CHANGE START: Standardized session schema =====
        session_data = {

            "session_id": uid,

            "patient_id": patient_id,

            "analysis_type": "audio",

            "shared_with": shared_with,

            "doctor_reviewed": False,

            "risk_level": risk_level,

            "critical_confirmed": False,

            "emergency_notified": False,

            "emergency_notified_at": None,

            "depression": result.get("depression", {}),

            "sentiment": result.get("sentiment", {}),

            "recommendation": recommendation,

            "audio_file": permanent_audio_path,

            "audio_url": audio_url_template.format(uid=uid),

            "created_at": datetime.utcnow()
        }
        # ===== CHANGE END =====

        await save_session_result(session_data)
        await process_alert(
            session_data
        )

        # ===== CHANGE START: Call notify once after session saved =====
        import asyncio
        asyncio.create_task(
            notify_connected_doctors(
                patient_id,
                shared_with,
                session_data["analysis_type"]
            )
        )
        # ===== CHANGE END =====

        return {

            "session_id": uid,

            "message": "Audio submitted successfully",

            "recommendation": recommendation,

            "shared_with": shared_with
        }

    except Exception as e:

        return {
            "error": str(e)
        }

    finally:

        # ====================================================
        # CLEANUP
        # ====================================================

        try:

            if os.path.exists(input_path):
                os.remove(input_path)

            if os.path.exists(standard_path):
                os.remove(standard_path)

            if os.path.exists(cleaned_path):
                os.remove(cleaned_path)

        except Exception:
            pass

# ============================================================
# FUSION API
# ============================================================

@app.post("/predict-fusion")
async def predict_fusion_api(
    patient_id: str=Form(...),
    file: UploadFile = File(...)
):

    uid = str(uuid.uuid4())

    extension = os.path.splitext(file.filename)[1].lower()

    if extension == "":
        extension = ".wav"

    input_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}{extension}"
    )

    standard_path = os.path.join(
        UPLOAD_DIR,
        f"{uid}_standard.wav"
    )

    cleaned_path = os.path.join(
        OUTPUT_DIR,
        f"{uid}_clean.wav"
    )

    try:

        # ====================================================
        # SAVE INPUT FILE
        # ====================================================

        with open(input_path, "wb") as f:
            f.write(await file.read())

        # ====================================================
        # CLEAN AUDIO
        # ====================================================

        convert_to_standard_wav(
        input_path,
        standard_path,
        )

        cleaned_audio = process_file(
            standard_path
        )
        if cleaned_audio is None:

            return {
                "error": "Audio preprocessing failed"
            }

        sf.write(
            cleaned_path,
            cleaned_audio,
            SR
        )

        # ====================================================
        # SPEECH TO TEXT
        # ====================================================

        transcript = transcribe_audio(
            cleaned_path
        )

        cleaned_text = preprocess_text(
            transcript
        )

        # ====================================================
        # LOAD AUDIO TENSOR
        # ====================================================

        audio_tensor, audio_mask = load_audio(
            cleaned_path
        )

        # ====================================================
        # FUSION PREDICTION
        # ====================================================

        prediction = predict_fusion(
            cleaned_text,
            audio_tensor,
            audio_mask
        )
        label = prediction["prediction"].lower()
        confidence = prediction["confidence"]

        if label == "depressed":

            if confidence >= 0.60:
                risk_level = "CRITICAL"

            elif confidence >= 0.55:
                risk_level = "HIGH"

            else:
                risk_level = "MEDIUM"

        else:
            risk_level = "LOW"

        # ===== CHANGE START: Generate recommendation =====
        recommendation = generate_recommendation(risk_level)
        # ===== CHANGE END =====

        # ====================================================
        # TEXT SENTIMENT
        # ====================================================

        text_result = predict_all(
            cleaned_text
        )
        # ====================================================
        # GET CONNECTED DOCTORS
        # ====================================================

        shared_with = []

        cursor = db.doctor_patient_access.find({
            "patient_id": patient_id,
            "active": True
        })

        async for access in cursor:

            doctor = await db.users.find_one({
                "user_id": access["doctor_id"]
            })

            if doctor:
                shared_with.append({
                    "doctor_id": doctor["user_id"],
                    "doctor_name": doctor["name"]
                })

        # ====================================================
        # DATABASE SAVE (use single collection `analyze_results`)
        # ====================================================

        analysis_collection = db.analysis_results

        permanent_audio_path = save_permanent_audio(cleaned_path, uid)

        # ===== CHANGE START: Standardized session schema for fusion =====
        session_data = {

            "session_id": uid,

            "patient_id": patient_id,

            "analysis_type": "fusion",

            "shared_with": shared_with,

            "doctor_reviewed": False,

            "risk_level": risk_level,

            "critical_confirmed": False,

            "emergency_notified": False,

            "emergency_notified_at": None,

            "transcript": transcript,

            "cleaned_text": cleaned_text,

            "depression": {
                "label": label,
                "confidence": confidence,
                "prediction": label
            },

            "sentiment": text_result["sentiment"],

            "recommendation": recommendation,

            "fusion_prediction": prediction,

            "audio_file": permanent_audio_path,

            "audio_url": audio_url_template.format(uid=uid),

            "created_at": datetime.utcnow()
        }
        # ===== CHANGE END =====

        inserted = await save_session_result(session_data)
        await process_alert(
            session_data
        )

        # ===== CHANGE START: Call notify once after session saved =====
        import asyncio
        asyncio.create_task(
            notify_connected_doctors(
                patient_id,
                shared_with,
                session_data["analysis_type"]
            )
        )
        
        response_data = {

            "db_id": str(inserted.inserted_id),

            "session_id": uid,

            "transcript": transcript,

            "cleaned_text": cleaned_text,

            "fusion_prediction": prediction,

            "sentiment": text_result["sentiment"],

            "recommendation": recommendation,

            "shared_with": shared_with,

            "submitted_at": datetime.utcnow().isoformat()
        }


        print("\n========== FINAL API RESPONSE ==========")

        print(response_data)

        return response_data
       


    except Exception as e:

        return {
            "error": str(e)
        }

    finally:

        # ====================================================
        # CLEANUP TEMP FILES
        # ====================================================

        try:

            if os.path.exists(input_path):
                os.remove(input_path)

            if os.path.exists(standard_path):
                os.remove(standard_path)

            if os.path.exists(cleaned_path):
                os.remove(cleaned_path)

        except Exception:
            pass


@app.get("/sessions/trend")
async def get_trend_data():

    try:

        analysis_collection = db.analysis_results

        sessions = await (
            analysis_collection
            .find()
            .sort("created_at", 1)
            .to_list(length=100)
        )

        trend = []

        for s in sessions:

            probs = s.get(
                "fusion_prediction",
                {}
            ).get(
                "probabilities",
                {}
            )

            score = (
                probs.get(
                    "non_depressed",
                    0
                ) * 100
            )

            created = s.get(
                "created_at"
            )

            day = created.strftime(
                "%a"
            )

            trend.append({

                "day": day,

                "score": round(
                    score,
                    1
                )
            })

        print("\n========== TREND DATA ==========")

        print(trend)

        return trend

    except Exception as e:

        print("\n========== TREND ERROR ==========")

        print(str(e))

        return {
            "error": str(e)
        }
from datetime import datetime
from bson import ObjectId


@app.get("/patient/history/{patient_id}")
async def get_patient_history(patient_id: str):

    results = await db.analysis_results.find(
        {
            "patient_id": patient_id
        }
    ).sort(
        "created_at",
        -1
    ).to_list(None)

    formatted = []

    for item in results:

        # ==========================================
        # Calculate confidence score
        # ==========================================

        score = 0

        if isinstance(item.get("depression"), dict):

            score = (
                item["depression"].get(
                    "confidence",
                    0,
                ) * 100
            )

        elif isinstance(
            item.get("fusion_prediction"),
            dict,
        ):

            score = (
                item["fusion_prediction"].get(
                    "confidence",
                    0,
                ) * 100
            )

        elif isinstance(
            item.get("prediction"),
            dict,
        ):

            score = (
                item["prediction"].get(
                    "confidence",
                    0,
                ) * 100
            )

        formatted.append({

            # ===============================
            # IDs
            # ===============================

            "id":
                str(item["_id"]),

            "session_id":
                item.get(
                    "session_id",
                    "",
                ),

            # ===============================
            # Session Info
            # ===============================

            "analysis_type":
                item.get(
                    "analysis_type",
                    "",
                ),

            "risk_level":
                item.get(
                    "risk_level",
                    "LOW",
                ),

            "score":
                score,

            # ===============================
            # Prediction Objects
            # ===============================

            "depression":
                item.get(
                    "depression",
                    {},
                ),

            "prediction":
                item.get(
                    "prediction",
                    {},
                ),

            "fusion_prediction":
                item.get(
                    "fusion_prediction",
                    {},
                ),

            "sentiment":
                item.get(
                    "sentiment",
                    {},
                ),

            # ===============================
            # Transcript
            # ===============================

            "transcript":
                item.get(
                    "transcript",
                    item.get(
                        "original_text",
                        "",
                    ),
                ),

            "cleaned_text":
                item.get(
                    "cleaned_text",
                    "",
                ),

            # ===============================
            # Recommendation
            # ===============================

            "recommendation":
                item.get(
                    "recommendation",
                    "",
                ),

            # ===============================
            # Doctor Review
            # ===============================

            "doctor_reviewed":
                item.get(
                    "doctor_reviewed",
                    False,
                ),

            "shared_with":
                item.get(
                    "shared_with",
                    [],
                ),

            # ===============================
            # Audio
            # ===============================

            "audio_url":
                item.get(
                    "audio_url",
                ),

            "audio_file":
                item.get(
                    "audio_file",
                ),

            # ===============================
            # Date
            # ===============================

            "created_at":
                item["created_at"].isoformat()
                if item.get("created_at")
                else None,
        })

    return {
        "sessions": formatted
    }
