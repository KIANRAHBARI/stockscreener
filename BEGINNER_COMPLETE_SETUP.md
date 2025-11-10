# 🎯 COMPLETE BEGINNER SETUP GUIDE
## Run Your Stock Screener in PyCharm - NO CODING NEEDED!

**You said**: "I have no coding experience and don't know what I'm doing"

**Don't worry!** Just follow these steps EXACTLY. Copy and paste everything.

---

## ⚡ SUPER QUICK START (3 Simple Steps)

### Step 1: Install Required Software (One-Time Setup)
1. **Node.js**: Go to https://nodejs.org/ → Download LTS version → Install
2. **Docker Desktop**: Go to https://www.docker.com/products/docker-desktop/ → Download → Install
3. **PyCharm**: You already have this! ✅

### Step 2: Get the Code in PyCharm
1. Open **PyCharm**
2. Click **"Get from VCS"** on welcome screen
3. Paste this URL: `https://github.com/KIANRAHBARI/stockscreener.git`
4. Click **Clone**
5. Wait for PyCharm to download everything

### Step 3: Run These 4 Commands

Open PyCharm Terminal (bottom of screen) and copy-paste these ONE AT A TIME:

```bash
# Command 1: Start database (make sure Docker Desktop is running first!)
docker-compose up -d

# Command 2: Install backend
cd backend && npm install

# Command 3: Install frontend
cd ../frontend && npm install

# Command 4: Start everything (open 2 terminals for this)
# Terminal 1:
cd backend && npm run dev

# Terminal 2 (click + to open new terminal):
cd frontend && npm run dev
```

Then open browser: **http://localhost:5173**

**DONE!** 🎉

---

## 📝 DETAILED STEP-BY-STEP (If You Get Stuck)

### PART 1: Install Software (Do This Once)

#### Install Node.js
1. Go to: https://nodejs.org/
2. Click the **big green button** that says "LTS" (Long Term Support)
3. Download the file
4. Double-click to install
5. Click "Next" on everything
6. **Restart your computer** after installing

#### Install Docker Desktop
1. Go to: https://www.docker.com/products/docker-desktop/
2. Download for your computer (Mac or Windows)
3. Install it
4. Open **Docker Desktop** (you'll see a whale icon)
5. Leave it running in the background

---

### PART 2: Get the Code Files

These code files are already in your GitHub. Here's how to download them to PyCharm:

#### Method 1: Clone in PyCharm (EASIEST)
1. Open **PyCharm**
2. If you see projects, click **File → Close Project** to get to welcome screen
3. Click **"Get from VCS"**
4. In the URL box, paste: `https://github.com/KIANRAHBARI/stockscreener.git`
5. Choose where to save it (like Desktop/stockscreener)
6. Click **Clone**
7. Wait for it to download (takes 30 seconds)
8. PyCharm will open your project automatically

#### Method 2: If Method 1 Doesn't Work
1. Go to: https://github.com/KIANRAHBARI/stockscreener
2. Click the green **Code** button
3. Click **Download ZIP**
4. Extract the ZIP file
5. In PyCharm: **File → Open** → Select the extracted folder

---

### PART 3: Create the Missing Code Files

Your GitHub has documentation but missing actual code. I'll create ALL the files now.

**After I'm done creating files, you'll run:**
```bash
git pull origin main
```
This downloads all the new code files I created.

---

## 🚀 HOW TO RUN THE PROGRAM

### First Time Setup:

#### Step 1: Open Terminal in PyCharm
- At the bottom of PyCharm, click **"Terminal"** tab
- You'll see a command line

#### Step 2: Start the Database
```bash
# Make sure Docker Desktop is RUNNING (you should see the whale icon)
docker-compose up -d

# Wait 10 seconds

# Check it worked:
docker ps
# You should see "stockscreener-postgres" in the list
```

#### Step 3: Install Backend Dependencies
```bash
cd backend
npm install
# Wait 1-2 minutes while it downloads packages
```

#### Step 4: Install Frontend Dependencies
```bash
cd ../frontend
npm install
# Wait 2-3 minutes while it downloads packages
```

#### Step 5: Start the Backend Server
In PyCharm Terminal:
```bash
cd backend
npm run dev
```

**You should see:**
```
🚀 Backend server running on http://localhost:5000
```

**KEEP THIS TERMINAL RUNNING!** Don't close it.

#### Step 6: Start the Frontend (Open New Terminal)
1. In PyCharm terminal area, click the **"+"** button to open a new terminal tab
2. In the NEW terminal, run:

```bash
cd frontend
npm run dev
```

**You should see:**
```
➜  Local:   http://localhost:5173/
```

**KEEP THIS TERMINAL RUNNING TOO!**

#### Step 7: Open in Browser

1. Hold **Cmd** (Mac) or **Ctrl** (Windows)
2. Click on `http://localhost:5173/` in the terminal
3. OR manually open your browser and go to: **http://localhost:5173**

**YOU SHOULD SEE YOUR STOCK SCREENER!** 🎉

---

## ✅ WHAT YOU SHOULD SEE

When you open **http://localhost:5173**, you should see:

- **Dark theme dashboard**
- **Performance metrics** at top:
  - Total Signals: 10
  - Win Rate: 91%
  - Total P/L: $1,500.72
  - Active Signals: 3
- **Signal list** on left showing AAPL and MSFT stocks
- **Export buttons** in header ("Export Backtests" and "Export Trades")
- **Chart area** on right

---

## 🔄 HOW TO STOP THE PROGRAM

1. Go to each terminal in PyCharm
2. Press **Ctrl+C** (both Mac and Windows)
3. Or click the **red stop button** in PyCharm

---

## 🔄 HOW TO START AGAIN (After Closing)

Next time you want to run it, just do this:

```bash
# Terminal 1:
cd backend && npm run dev

# Terminal 2 (new terminal tab):
cd frontend && npm run dev

# Browser: http://localhost:5173
```

That's it! **3 commands and you're running.**

---

## ❌ TROUBLESHOOTING

### Problem: "npm: command not found"
**Solution:** Install Node.js from https://nodejs.org/ and restart PyCharm

### Problem: "docker: command not found" 
**Solution:** Install Docker Desktop and make sure it's running

### Problem: "Port 5000 already in use"
**Solution:**
```bash
# Find what's using it:
lsof -i :5000

# Kill it (replace <PID> with the number you see):
kill -9 <PID>
```

### Problem: Backend won't connect to database
**Solution:**
```bash
# Restart Docker:
docker-compose restart

# Or restart Docker Desktop app
```

### Problem: "Module not found" errors
**Solution:**
```bash
# Reinstall everything:
cd backend
rm -rf node_modules
npm install

cd ../frontend
rm -rf node_modules
npm install
```

### Problem: Nothing works!
**Solution:** 
1. Close everything
2. Restart Docker Desktop
3. Restart PyCharm
4. Run the commands again

---

## 🎯 SUMMARY FOR ABSOLUTE BEGINNERS

**Think of it like this:**
- **Backend** = The "brain" that generates trading signals
- **Frontend** = The "website" you see in your browser
- **Database** = Where we store trading data
- **npm install** = Downloads all the helper code we need
- **npm run dev** = Starts the program

**You need 3 things running:**
1. ✅ Docker (database) - runs in background
2. ✅ Backend server - runs in Terminal 1
3. ✅ Frontend website - runs in Terminal 2

**All 3 must be running for it to work!**

---

## 📞 NEXT STEPS

Once it's running:

1. **Try the Export button** - Click "Export Backtests" → "Download Excel"
2. **Look at the signals** - You'll see AAPL and MSFT trading signals
3. **Check the metrics** - See win rate and profit/loss stats

The data is FAKE right now (mock data). To get REAL trading signals, you need to:
1. Fix the errors in ERROR_FIXES.md
2. Connect to Yahoo Finance for real data
3. Run backtests

But for now, you can see how the app works!

---

**WAIT FOR ME TO CREATE ALL THE CODE FILES, THEN FOLLOW THIS GUIDE!** 🚀
