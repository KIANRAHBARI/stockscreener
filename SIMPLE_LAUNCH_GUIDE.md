SIMPLE_LAUNCH_GUIDE.md# 🚀 SUPER SIMPLE LAUNCH GUIDE

Don't worry! I'll walk you through this step-by-step. Just copy and paste the commands.

---

## What You Need Installed First

1. **Node.js** - Download from: https://nodejs.org/ (get the LTS version)
2. **Docker Desktop** - Download from: https://www.docker.com/products/docker-desktop/
3. Open **Docker Desktop** and make sure it's running (you'll see the Docker icon in your system tray)

---

## Step 1: Download the Project

Open your **Terminal** (Mac) or **Command Prompt** (Windows) and run:

```bash
# Navigate to where you want to save the project (like Desktop)
cd ~/Desktop

# Download the project
git clone https://github.com/KIANRAHBARI/stockscreener.git

# Go into the project folder
cd stockscreener
```

---

## Step 2: Create the Needed Folders

Just copy and paste this:

```bash
mkdir -p backend/src/config
mkdir -p backend/src/routes  
mkdir -p backend/src/utils
mkdir -p backend/src/middleware
mkdir -p backend/src/services
mkdir -p frontend/src/components
mkdir -p frontend/src/pages
```

---

## Step 3: Create docker-compose.yml File

Create a file called `docker-compose.yml` in your project root folder with this content:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: stockscreener-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: stockscreener
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**How to create it:**
- Mac: `nano docker-compose.yml` (paste content, press Ctrl+X, then Y, then Enter)
- Windows: Use Notepad, save as `docker-compose.yml`

---

## Step 4: Start the Database

```bash
# Make sure Docker Desktop is running first!

# Start PostgreSQL database
docker-compose up -d postgres

# Wait 10 seconds

# Check it's running (you should see stockscreener-postgres)
docker ps
```

---

## Step 5: Create the Database Tables

```bash
# Connect to the database
docker exec -it stockscreener-postgres psql -U postgres -d stockscreener
```

Then paste this SQL code:

```sql
CREATE TABLE signals (
  id SERIAL PRIMARY KEY,
  symbol VARCHAR(10) NOT NULL,
  signal VARCHAR(10) NOT NULL,
  entry_price DECIMAL(10,2) NOT NULL,
  stop_loss DECIMAL(10,2) NOT NULL,
  take_profit DECIMAL(10,2) NOT NULL,
  position_size INTEGER NOT NULL,
  rsi DECIMAL(5,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE backtest_results (
  id SERIAL PRIMARY KEY,
  symbol VARCHAR(10) NOT NULL,
  signal VARCHAR(10) NOT NULL,
  entry_time TIMESTAMP NOT NULL,
  entry_price DECIMAL(10,2) NOT NULL,
  exit_price DECIMAL(10,2) NOT NULL,
  stop_loss DECIMAL(10,2) NOT NULL,
  take_profit DECIMAL(10,2) NOT NULL,
  position_size INTEGER NOT NULL,
  risk_amount DECIMAL(10,2) NOT NULL,
  profit_loss DECIMAL(10,2) NOT NULL,
  pl_percent DECIMAL(5,2) NOT NULL,
  rsi_entry DECIMAL(5,2) NOT NULL,
  outcome VARCHAR(10) NOT NULL,
  hold_duration VARCHAR(20)
);

CREATE TABLE trades (
  id SERIAL PRIMARY KEY,
  symbol VARCHAR(10) NOT NULL,
  signal VARCHAR(10) NOT NULL,
  entry_price DECIMAL(10,2) NOT NULL,
  exit_price DECIMAL(10,2),
  position_size INTEGER NOT NULL,
  profit_loss DECIMAL(10,2),
  status VARCHAR(20) DEFAULT 'OPEN',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Then type `\q` and press Enter to exit.

---

## Step 6: I'll Create All the Code Files for You

**I'm going to create all the necessary files in your GitHub repository.** 

After I create them, you'll need to:

1. Go to: https://github.com/KIANRAHBARI/stockscreener
2. Click the green "Code" button
3. Click "Download ZIP"
4. Extract it to replace your current folder

OR just run:

```bash
# Pull the latest code
git pull origin main
```

---

## Step 7: Install Everything

### Backend:
```bash
cd backend
npm install
```

### Frontend:
```bash
cd ../frontend  
npm install
```

---

## Step 8: Start Everything (3 Terminals)

### Terminal 1 - Backend:
```bash
cd backend
npm run dev
```

You should see:
```
✅ Database connected successfully
🚀 Backend server running on http://localhost:5000
```

### Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

You should see:
```
➜  Local:   http://localhost:5173/
```

### Terminal 3 - Keep this ready for commands

---

## Step 9: Open Your Browser

Go to: **http://localhost:5173**

You should see your Stock Screener dashboard! 🎉

---

## If Something Goes Wrong:

### Backend won't start?
```bash
# Check if port 5000 is already in use
lsof -i :5000

# If something is using it, kill it:
kill -9 <PID_NUMBER>
```

### Database won't connect?
```bash
# Restart Docker
docker-compose restart postgres

# Check logs
docker logs stockscreener-postgres
```

### Frontend shows errors?
```bash
# Make sure backend is running first
curl http://localhost:5000/health

# Should return: {"status":"ok"}
```

---

## Quick Restart Commands

If you close everything and want to start again:

```bash
# Make sure Docker Desktop is running

# Terminal 1:
cd ~/Desktop/stockscreener/backend
npm run dev

# Terminal 2:
cd ~/Desktop/stockscreener/frontend  
npm run dev

# Browser: http://localhost:5173
```

---

## What's Next?

Once it's running, you can:
- ✅ View live trading signals
- ✅ Export data to Excel/CSV
- ✅ See performance metrics
- ✅ Click signals to see details

---

**WAIT FOR ME TO CREATE ALL THE CODE FILES, THEN FOLLOW THESE STEPS!** 🚀
