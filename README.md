# Upstyle 🌱  
AI-Powered Sustainable Fashion Platform

Upstyle is an AI-driven mobile application that helps people make better use of the clothes they already own by digitizing personal wardrobes, enabling smart styling, and encouraging upcycling through AI guidance and local maker collaboration.

---

## 🌍 Problem Statement

The fashion industry is one of the world’s largest polluters:
- Over **92 million tons** of textile waste are generated annually
- Less than **1% of clothing** is recycled into new garments
- Fast fashion contributes nearly **10% of global carbon emissions**
- Around **60% of microplastics** in oceans originate from synthetic clothing

At the same time, users often experience:
- Unconscious overconsumption
- “Nothing to wear” syndrome despite full wardrobes
- Lack of creativity or knowledge to reuse garments
- Blind trend-following driven by fast fashion cycles

---

## 💡 Solution

**Upstyle** transforms wardrobes into intelligent, sustainable fashion ecosystems by:

- Digitizing personal closets
- Recommending outfits from existing clothes
- Generating AI-powered upcycling ideas
- Connecting users with local designers and makers

---

## ✨ Key Features

### 👚 Digital Wardrobe
- Upload and organize clothing items
- Visual attribute extraction (category, color, style)
- Smart filtering by season, type, and occasion

### 🤖 AI Styling Assistant
- Personalized outfit recommendations
- Context-aware styling (events, daily wear, dates)
- Uses visual embeddings and language reasoning

### ♻️ AI Upcycling Guidance
- Step-by-step upcycling instructions
- Sustainable reuse ideas
- Optional AI-generated visual previews

### 🧵 Maker Marketplace
- Connects users with local designers and tailors
- Supports circular economy and local creativity

---

## 🧠 AI & Technical Stack

### Core AI Technologies
- **FashionCLIP** – zero-shot visual-language model for clothing understanding
- **ONNX Runtime** – portable, lightweight inference
- **MindSpore / MindSpore Lite** – optimized model execution
- **Pangu LLM (via ModelArts)** – reasoning for styling and upcycling

### Huawei Cloud Stack
- **ModelArts** – AI model deployment & management
- **OBS** – image and media storage
- **RDS / GaussDB** – user and wardrobe metadata
- **CCE (Kubernetes)** – scalable backend services
- **IAM & API Gateway** – authentication and access control

---

## 🏗️ Architecture Overview

1. User uploads clothing images via Flutter app
2. Images stored in Huawei OBS
3. FashionCLIP extracts embeddings using MindSpore
4. Attributes and vectors stored in cloud databases
5. User requests styling or upcycling
6. Pangu LLM generates recommendations
7. Optional image generation for upcycling preview
8. User can connect with local makers

---

## 📊 Impact & UN SDG Alignment

Upstyle directly supports:
- **SDG 12** – Responsible Consumption & Production
- **SDG 13** – Climate Action
- **SDG 9** – Industry, Innovation & Infrastructure
- **SDG 11** – Sustainable Cities & Communities

---

## 💼 Business Model

- **Freemium Subscription**
  - Free: limited wardrobe & styling
  - Premium: advanced AI styling & upcycling
  - Pro: professional tools & early features

- **Marketplace Commissions**
  - 10–15% on upcycled clothing sales
  - 15–20% on stylist and tailor services

---

## 👥 Team

- **Nurmukhammad Nuriddinov** – Founder, AI Engineer & Researcher  
- **Qobil Risqaliyev** – Co-founder, Mobile Developer  
- **Sunnat Axmadov** – Backend Engineer  
- **Dr. Ashish Seth** – Academic Supervisor, INHA University  

---

## 🚀 Future Work

- Native MindSpore model conversion (MindIR)
- Ascend NPU acceleration
- AR try-on integration
- Sustainability impact dashboards

---

## 📜 License

This project is developed for the **Huawei ICT Innovation Competition**.  
All rights reserved © 2025.
