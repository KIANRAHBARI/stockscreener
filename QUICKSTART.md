# 🚀 Quick Start Guide - Launch Phase 1

**Estimated Time**: 15-20 minutes  
**Last Updated**: November 9, 2025

---

## Prerequisites Check

Before starting, ensure you have:

- ✅ **Node.js 18+** installed ([Download here](https://nodejs.org/))
- ✅ **Docker Desktop** installed and running ([Download here](https://www.docker.com/products/docker-desktop))
- ✅ **Git** installed ([Download here](https://git-scm.com/))
- ✅ **Finnhub API key** (free tier) - [Get it here](https://finnhub.io/register)

### Verify Installations

Open your terminal and run:

```bash
# Check Node.js (should show v18 or higher)
node --version

# Check npm
npm --version

# Check Docker
docker --version

# Check Git
git --version
```

---

## Step 1: Clone the Repository (2 minutes)

```bash
# Clone your repo
git clone https://github.com/KIANRAHBARI/stockscreener.git

# Navigate into the folder
cd stockscreener
```

---

## Step 2: Create Directory Structure (1 minute)

```bash
# Create all necessary folders
mkdir -p backend/src/config
mkdir -p backend/src/models
mkdir -p backend/src/services
mkdir -p backend/src/routes
mkdir -p backend/src/middleware
mkdir -p frontend/src/components
mkdir -p frontend/src/services
mkdir -p database
```

---

## Step 3: Copy Code from PHASE1_IMPLEMENTATION.md (5 minutes)

Open `PHASE1_IMPLEMENTATION.md` in your repository and copy each code section into the corresponding file:

### Backend Files

**File 1: `backend/package.json`**
```bash
# Copy Section 1 from PHASE1_IMPLEMENTATION.md
```

**File 2: `backend/.env.example`**
```bash
# Copy Section 2 from PHASE1_IMPLEMENTATION.md
```

**File 3: `backend/src/server.js`**
```bash
# Copy Section 3 from PHASE1_IMPLEMENTATION.md
```

**File 4: `backend/src/services/rsiCalculator.js`**
```bash
# Copy Section 4 from PHASE1_IMPLEMENTATION.md (CORE ALGORITHM)
```

**File 5: `backend/src/services/signalGenerator.js`**
```bash
# Copy Section 5 from PHASE1_IMPLEMENTATION.md
```

### Database Files

**File 6: `database/schema.sql`**
```bash
# Copy Section 6 from PHASE1_IMPLEMENTATION.md
```

### Docker Files

**File 7: `docker-compose.yml`** (in root folder)
```bash
# Copy Section 7 from PHASE1_IMPLEMENTATION.md
```

---

## Step 4: Get Your Finnhub API Key (3 minutes)

1. Go to https://finnhub.io/register
2. Sign up with your email (free tier gives 60 API calls/minute)
3. Verify your email
4. Copy your API key from the dashboard

---

## Step 5: Configure Environment (2 minutes)

```bash
cd backend

# Copy the example env file
cp .env.example .env

# Edit the .env file
nano .env  # or use: code .env (VS Code) / open .env (Mac)
```

**Edit the `.env` file and add your Finnhub API key:**

```env
FINNHUB_API_KEY=your_actual_api_key_here
```

Save and close the file.

---

## Step 6: Install Dependencies (2 minutes)

```bash
# Make sure you're in the backend folder
cd backend

# Install all Node.js packages
npm install

# Go back to root
cd ..
```

---

## Step 7: Start PostgreSQL Database (1 minute)

```bash
# From the root directory, start PostgreSQL
docker-compose up -d postgres

# Wait 10 seconds for the database to initialize
sleep 10

# Verify it's running
docker ps
```

You should see a container named `stockscreener-db` running.

---

## Step 8: Start the Backend Server (1 minute)

```bash
# Navigate to backend
cd backend

# Start the development server
npm run dev
```

You should see:
```
Server running on port 5000
Environment: development
```

---

## Step 9: Test the System (2 minutes)

Open a new terminal window (keep the server running in the first one):

```bash
# Test the health endpoint
curl http://localhost:5000/health
```

**Expected response:**
```json
{"status":"ok","timestamp":"2025-11-09T..."}
```

✅ **If you see this, Phase 1 is successfully running!**

---

## Step 10: Test the RSI Calculator (Optional)

Create a test file `backend/test-rsi.js`:

```javascript
import { RSICalculator } from './src/services/rsiCalculator.js';

const rsi = new RSICalculator(2);
const prices = [100, 102, 98, 101, 97, 103, 99];

const rsiValues = rsi.calculate(prices);
console.log('RSI Values:', rsiValues);

const buySignal = rsi.isBuySignal(prices, 30);
const sellSignal = rsi.isSellSignal(prices, 70);

console.log('Buy Signal:', buySignal);
console.log('Sell Signal:', sellSignal);
```

Run it:
```bash
node test-rsi.js
```

---

## Troubleshooting

### Issue: "Port 5000 already in use"
**Solution**: Kill the process using port 5000
```bash
# Mac/Linux
lsof -ti:5000 | xargs kill -9

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F
```

### Issue: "Cannot connect to PostgreSQL"
**Solution**: Restart Docker container
```bash
docker-compose down
docker-compose up -d postgres
sleep 10
```

### Issue: "Module not found"
**Solution**: Reinstall dependencies
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

### Issue: "FINNHUB_API_KEY is undefined"
**Solution**: Check your .env file
```bash
# Make sure .env exists in backend folder
ls -la backend/.env

# Check the content
cat backend/.env
```

---

## What's Running Now?

✅ **PostgreSQL Database** (port 5432)
- Storing: stocks, signals, trades, alerts
- Schema: Fully initialized

✅ **Backend API Server** (port 5000)
- RSI 2-Period calculator ready
- Signal generator active
- Health endpoint working

🔄 **Next**: Add market data integration (Phase 2)

---

## Quick Commands Reference

```bash
# Start PostgreSQL
docker-compose up -d postgres

# Stop PostgreSQL
docker-compose down

# View PostgreSQL logs
docker logs stockscreener-db

# Start backend in dev mode
cd backend && npm run dev

# Check what's running
docker ps
curl http://localhost:5000/health

# Access PostgreSQL CLI
docker exec -it stockscreener-db psql -U postgres -d stockscreener
```

---

## Next Steps

🎯 **You're now running Phase 1!** Here's what to do next:

1. **Test the RSI calculator** with sample price data
2. **Explore the database schema** using PostgreSQL CLI
3. **Review the code** in `PHASE1_IMPLEMENTATION.md`
4. **Prepare for Phase 2**: Market data integration

When ready, ask Perplexity to start **Phase 2: Market Data Integration**

---

## Support

- 📖 Full code: See `PHASE1_IMPLEMENTATION.md`
- 📋 Project overview: See `README.md`
- 🐛 Issues: Create a GitHub issue

**Phase 1 Status**: Running ✅
