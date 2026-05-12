import os
import base64
import requests
from fastapi import FastAPI, UploadFile, File,Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from groq import Groq

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ================= MEMORY =================
memory = {}
MAX_HISTORY = 6

def get_history(user_id):
    return memory.get(user_id, [])

def save(user_id, role, content):
    if user_id not in memory:
        memory[user_id] = []

    memory[user_id].append({
        "role": role,
        "content": content
    })

    memory[user_id] = memory[user_id][-MAX_HISTORY:]

# ================= AI =================
client = Groq(api_key=os.getenv("GROQ_API_KEY"))
MODEL = "llama-3.3-70b-versatile"
def generate(messages):
    response = client.chat.completions.create(
        model=MODEL,
        messages=messages,
        temperature=0.4,
        top_p=0.9,
        max_tokens=400,
    )
    return response.choices[0].message.content

# ================= DATA =================
API_KEY = os.getenv("OPENTRIP_API_KEY")
BASE = "https://api.opentripmap.com/0.1/en/places"

def get_landmarks(query):
    try:
        geo = requests.get(
            f"{BASE}/geoname",
            params={"name": query, "apikey": API_KEY},
            timeout=5
        ).json()

        if geo.get("status") != "OK":
            return []

        lat, lon = geo["lat"], geo["lon"]

        places = requests.get(
            f"{BASE}/radius",
            params={
                "radius": 10000,
                "lon": lon,
                "lat": lat,
                "limit": 5,
                "format": "json",
                "apikey": API_KEY
            },
            timeout=5
        ).json()

        return places

    except:
        return []

def build_context(data):
    if not data:
        return ""

    lines = []
    for item in data[:3]:
        name = item.get("name", "Unknown")
        kinds = item.get("kinds", "")
        lines.append(f"{name} is a {kinds}")
    return "\n".join(lines)

# ================= SCHEMA =================
class ChatRequest(BaseModel):
    user_id: str
    message: str

# ================= PROMPT =================
SYSTEM_PROMPT = """
You are a professional and knowledgeable Egyptian tourism assistant for "Kemet App".

Identity:
- You represent Kemet App, a smart tourism assistant focused on Egypt.
- If asked "who are you", respond in a friendly way like:
  "I'm your tourism assistant from Kemet App, here to help you explore Egypt."

Main Behavior:
- You ONLY answer questions related to tourism in Egypt.
- This includes:
  (landmarks, history, ancient Egypt, temples, pyramids, museums, cities, travel tips).
- If the question is NOT related to Egypt tourism:
  politely refuse and guide the user back.

Example refusal:
"I'm here to help only with tourism in Egypt 🇪🇬. Ask me about places, history, or travel tips!"

Tone & Style:
- Be friendly but confident (like a professional tour guide).
- Speak naturally, not robotic.
- Give rich but clear answers.
- Use short paragraphs or bullet points when helpful.

Language:
- Detect user's language automatically.
- Reply in Arabic if the user writes Arabic.
- Reply in English if the user writes English.

Knowledge Style:
When describing a place, try to include:
1) What it is
2) Why it is important historically
3) Where it is located
4) Why people visit it
5) Practical tip (best time, advice, etc.)

Accuracy:
- Do NOT invent fake facts.
- If unsure, say:
  "I'm not completely sure, but..."

Extra Personality:
- Show pride in Egyptian civilization 🏺
- Make the user feel excited about visiting Egypt

Example:
User: "احكيلي عن الأهرامات"
Assistant:
"الأهرامات من أعظم إنجازات الحضارة المصرية القديمة..."

User: "what is Python?"
Assistant:
"I'm here to help only with tourism in Egypt 🇪🇬..."
- Format answers nicely using:
  - bullet points
  - short paragraphs
  - emojis when appropriate (light use)
"""

WHISPER_API_KEY = os.getenv("WHISPER_API_KEY")
VISION_API_KEY = os.getenv("VISION_API_KEY")

# ================= ROUTES =================

@app.get("/")
def home():
    return {"message": "Chatbot is running 🚀"}

@app.post("/chat")
def chat(req: ChatRequest):
    user_id = req.user_id
    msg = req.message

    data = get_landmarks(msg)
    context = build_context(data)

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    if context:
        messages.append({
            "role": "system",
            "content": f"Tourism data:\n{context}"
        })

    messages += get_history(user_id)
    messages.append({"role": "user", "content": msg})

    try:
        reply = generate(messages)
    except:
        return {"status": "error", "message": "AI failed"}

    save(user_id, "user", msg)
    save(user_id, "assistant", reply)

    return {
        "response": reply,
        "history": get_history(user_id)
    }

@app.get("/history/{user_id}")
def history(user_id: str):
    return {"history": get_history(user_id)}

@app.delete("/history/{user_id}")
def clear(user_id: str):
    memory[user_id] = []
    return {"message": "cleared"}

# ================= VOICE =================

@app.post("/voice")
async def voice_chat(user_id: str, file: UploadFile = File(...)):
    audio_path = f"temp_{user_id}.mp3"
    with open(audio_path, "wb") as f:
        f.write(await file.read())

    url = "https://api.groq.com/openai/v1/audio/transcriptions"
    headers = {"Authorization": f"Bearer {WHISPER_API_KEY}"}

    files = {"file": open(audio_path, "rb")}
    data = {"model": "whisper-large-v3-turbo"}

    res = requests.post(url, headers=headers, files=files, data=data)
    text = res.json()["text"]

    data_landmarks = get_landmarks(text)
    context = build_context(data_landmarks)

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    if context:
        messages.append({
            "role": "system",
            "content": f"Tourism data:\n{context}"
        })

    messages += get_history(user_id)
    messages.append({"role": "user", "content": text})

    reply = generate(messages)

    save(user_id, "user", text)
    save(user_id, "assistant", reply)

    return {"transcript": text, "response": reply}

# ================= IMAGE =================
@app.post("/image")
async def image_chat(
    user_id: str = Form(...),
    file: UploadFile = File(...)
):
    image_path = f"temp_{user_id}.jpg"

    with open(image_path, "wb") as f:
        f.write(await file.read())

    with open(image_path, "rb") as img:
        b64 = base64.b64encode(img.read()).decode()

    url = "https://api.groq.com/openai/v1/chat/completions"

    headers = {
        "Authorization": f"Bearer {VISION_API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "meta-llama/llama-4-scout-17b-16e-instruct",
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Describe this image"},
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{b64}"}
                    }
                ]
            }
        ]
    }

    res = requests.post(url, headers=headers, json=payload)

    print(res.status_code, res.text)

    if res.status_code != 200:
        return {"error": res.text}

    description = res.json()["choices"][0]["message"]["content"]

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    messages += get_history(user_id)
    messages.append({
        "role": "user",
        "content": f"User shared an image: {description}"
    })

    reply = generate(messages)

    save(user_id, "user", f"[image]: {description}")
    save(user_id, "assistant", reply)

    return {
        "response": reply
    }