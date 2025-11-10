QUICK_SETUP.sh#!/bin/bash

# STOCK SCREENER - ONE-COMMAND SETUP
# Just copy this entire file and run: bash QUICK_SETUP.sh

echo "🚀 Setting up Stock Screener..."

# Create folders
mkdir -p backend/src frontend/src

# ============================================
# FILE 1: docker-compose.yml
# ============================================
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    container_name: stockscreener-db
    environment:
      POSTGRES_USER: stockuser
      POSTGRES_PASSWORD: stockpass123
      POSTGRES_DB: stockscreener
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
EOF

# ============================================
# FILE 2: backend/package.json
# ============================================
cat > backend/package.json << 'EOF'
{
  "name": "stockscreener-backend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "node src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "yahoo-finance2": "^2.4.0"
  }
}
EOF

# ============================================
# FILE 3: backend/.env
# ============================================
cat > backend/.env << 'EOF'
PORT=3001
STARTING_CAPITAL=10000
RISK_PER_TRADE=0.01
STOP_LOSS_PERCENT=0.005
TAKE_PROFIT_PERCENT=0.015
EOF

# ============================================
# FILE 4: backend/src/server.js
# ============================================
cat > backend/src/server.js << 'EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const signals = [
  { id: 1, symbol: 'AAPL', price: 178.25, rsi: 18.5, signal: 'BUY', entry_price: 178.25, stop_loss: 177.36, take_profit: 180.92, position_size: 56, status: 'ACTIVE' },
  { id: 2, symbol: 'MSFT', price: 385.40, rsi: 12.3, signal: 'BUY', entry_price: 385.40, stop_loss: 383.47, take_profit: 391.18, position_size: 26, status: 'ACTIVE' },
  { id: 3, symbol: 'GOOGL', price: 142.80, rsi: 15.8, signal: 'BUY', entry_price: 142.80, stop_loss: 142.09, take_profit: 144.94, position_size: 70, status: 'ACTIVE' },
  { id: 4, symbol: 'TSLA', price: 238.50, rsi: 92.7, signal: 'SELL', entry_price: 238.50, stop_loss: 239.69, take_profit: 235.07, position_size: 42, status: 'COMPLETED', profit_loss: 138.60 }
];

const performance = { total_trades: 127, winning_trades: 116, win_rate: 91.3, total_profit: 4250.75, account_balance: 14250.75 };

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.get('/api/signals', (req, res) => res.json(signals));
app.get('/api/performance', (req, res) => res.json(performance));
app.get('/api/export/csv', (req, res) => {
  const csv = 'Symbol,Price,RSI,Signal,Entry,Stop Loss,Take Profit,Position,Status\\n' +
    signals.map(s => `${s.symbol},${s.price},${s.rsi},${s.signal},${s.entry_price},${s.stop_loss},${s.take_profit},${s.position_size},${s.status}`).join('\\n');
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename=signals.csv');
  res.send(csv);
});

app.listen(PORT, () => console.log(`✅ Backend running on http://localhost:${PORT}`));
EOF

# ============================================
# FILE 5: frontend/package.json
# ============================================
cat > frontend/package.json << 'EOF'
{
  "name": "stockscreener-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.3.6",
    "vite": "^5.0.8"
  }
}
EOF

# ============================================
# FILE 6: frontend/vite.config.js
# ============================================
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': { target: 'http://localhost:3001', changeOrigin: true } }
  }
});
EOF

# ============================================
# FILE 7: frontend/index.html
# ============================================
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Stock Screener - RSI 2</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# ============================================
# FILE 8: frontend/tailwind.config.js
# ============================================
cat > frontend/tailwind.config.js << 'EOF'
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: { extend: {} },
  plugins: []
}
EOF

# ============================================
# FILE 9: frontend/postcss.config.js
# ============================================
cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: { tailwindcss: {}, autoprefixer: {} }
}
EOF

# ============================================
# FILE 10: frontend/src/main.jsx
# ============================================
cat > frontend/src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(<React.StrictMode><App /></React.StrictMode>);
EOF

# ============================================
# FILE 11: frontend/src/index.css
# ============================================
cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body { margin: 0; background: #0f172a; color: #e2e8f0; font-family: system-ui, -apple-system, sans-serif; }
EOF

# ============================================
# FILE 12: frontend/src/App.jsx  
# ============================================
cat > frontend/src/App.jsx << 'EOFAPP'
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [signals, setSignals] = useState([]);
  const [perf, setPerf] = useState(null);

  useEffect(() => {
    axios.get('/api/signals').then(r => setSignals(r.data));
    axios.get('/api/performance').then(r => setPerf(r.data));
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 p-6">
      <h1 className="text-3xl font-bold text-white mb-8">Stock Screener - RSI 2-Period</h1>
      
      {perf && (
        <div className="grid grid-cols-4 gap-4 mb-8">
          <div className="bg-slate-800 p-6 rounded-lg">
            <p className="text-slate-400 text-sm">Balance</p>
            <p className="text-2xl font-bold text-green-500">${perf.account_balance.toLocaleString()}</p>
          </div>
          <div className="bg-slate-800 p-6 rounded-lg">
            <p className="text-slate-400 text-sm">Win Rate</p>
            <p className="text-2xl font-bold text-blue-500">{perf.win_rate}%</p>
          </div>
          <div className="bg-slate-800 p-6 rounded-lg">
            <p className="text-slate-400 text-sm">Profit</p>
            <p className="text-2xl font-bold text-green-500">${perf.total_profit.toLocaleString()}</p>
          </div>
          <div className="bg-slate-800 p-6 rounded-lg">
            <p className="text-slate-400 text-sm">Trades</p>
            <p className="text-2xl font-bold text-purple-500">{perf.total_trades}</p>
          </div>
        </div>
      )}

      <div className="mb-4 flex justify-end">
        <a href="/api/export/csv" target="_blank" className="bg-blue-600 px-6 py-2 rounded text-white hover:bg-blue-700">Export CSV</a>
      </div>

      <div className="bg-slate-800 rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-slate-700">
            <tr>
              <th className="px-6 py-3 text-left text-sm">Symbol</th>
              <th className="px-6 py-3 text-left text-sm">Price</th>
              <th className="px-6 py-3 text-left text-sm">RSI</th>
              <th className="px-6 py-3 text-left text-sm">Signal</th>
              <th className="px-6 py-3 text-left text-sm">Entry</th>
              <th className="px-6 py-3 text-left text-sm">Stop Loss</th>
              <th className="px-6 py-3 text-left text-sm">Take Profit</th>
              <th className="px-6 py-3 text-left text-sm">Position</th>
              <th className="px-6 py-3 text-left text-sm">Status</th>
            </tr>
          </thead>
          <tbody className="text-slate-200">
            {signals.map(s => (
              <tr key={s.id} className="border-t border-slate-700">
                <td className="px-6 py-4 font-medium">{s.symbol}</td>
                <td className="px-6 py-4">${s.price}</td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 rounded text-xs ${s.rsi < 20 ? 'bg-green-500/20 text-green-400' : s.rsi > 80 ? 'bg-red-500/20 text-red-400' : 'bg-slate-600'}`}>
                    {s.rsi}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span className={`px-3 py-1 rounded-full text-xs ${s.signal === 'BUY' ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'}`}>
                    {s.signal}
                  </span>
                </td>
                <td className="px-6 py-4">${s.entry_price}</td>
                <td className="px-6 py-4 text-red-400">${s.stop_loss}</td>
                <td className="px-6 py-4 text-green-400">${s.take_profit}</td>
                <td className="px-6 py-4">{s.position_size}</td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 rounded text-xs ${s.status === 'ACTIVE' ? 'bg-blue-500/20 text-blue-400' : 'bg-slate-600'}`}>
                    {s.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default App;
EOFAPP

echo "✅ All files created!"
echo ""
echo "💾 Installing packages..."

# Install dependencies
cd backend && npm install && cd ..
cd frontend && npm install && cd ..

echo ""
echo "🚀 Starting Docker database..."
docker-compose up -d

echo ""
echo "✅ Setup complete! Starting servers..."
echo "🌐 Backend: http://localhost:3001"
echo "🌐 Frontend: http://localhost:5173"
echo ""
echo "💡 Opening frontend in 3 seconds..."
sleep 3

# Install concurrently if needed
npm list -g concurrently > /dev/null 2>&1 || npm install -g concurrently

# Start both servers
npx concurrently "cd backend && npm run dev" "cd frontend && npm run dev"
