#!/bin/bash

# PHASE 4: Real Market Data Integration
# Upgrades your stock screener from mock data to LIVE Yahoo Finance data

echo "🚀 Upgrading to Phase 4: Real Market Data Integration..."
echo ""

# Update backend server with real market data
cat > backend/src/server.js << 'EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import yahooFinance from 'yahoo-finance2';

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// ============================================
// REAL-TIME RSI CALCULATOR
// ============================================
function calculateRSI(prices, period = 2) {
  if (prices.length < period + 1) return null;
  
  let gains = [];
  let losses = [];
  
  for (let i = 1; i < prices.length; i++) {
    const change = prices[i] - prices[i - 1];
    gains.push(change > 0 ? change : 0);
    losses.push(change < 0 ? Math.abs(change) : 0);
  }
  
  const avgGain = gains.slice(-period).reduce((a, b) => a + b, 0) / period;
  const avgLoss = losses.slice(-period).reduce((a, b) => a + b, 0) / period;
  
  if (avgLoss === 0) return 100;
  const rs = avgGain / avgLoss;
  const rsi = 100 - (100 / (1 + rs));
  
  return rsi;
}

// ============================================
// MARKET HOURS VALIDATION
// ============================================
function isMarketOpen() {
  const now = new Date();
  const et = new Date(now.toLocaleString('en-US', { timeZone: 'America/New_York' }));
  const day = et.getDay();
  const hour = et.getHours();
  const minute = et.getMinutes();
  
  // Monday to Friday
  if (day === 0 || day === 6) return false;
  
  // 9:30 AM to 4:00 PM ET
  if (hour < 9 || hour >= 16) return false;
  if (hour === 9 && minute < 30) return false;
  
  return true;
}

// ============================================
// SIGNAL GENERATION
// ============================================
function generateSignal(symbol, price, rsi) {
  const stopLossPercent = parseFloat(process.env.STOP_LOSS_PERCENT) || 0.005;
  const takeProfitPercent = parseFloat(process.env.TAKE_PROFIT_PERCENT) || 0.015;
  const riskPerTrade = parseFloat(process.env.RISK_PER_TRADE) || 0.01;
  const capital = parseFloat(process.env.STARTING_CAPITAL) || 10000;
  
  let signal = null;
  let entryPrice = price;
  let stopLoss, takeProfit;
  
  if (rsi < 20) {
    signal = 'BUY';
    stopLoss = price * (1 - stopLossPercent);
    takeProfit = price * (1 + takeProfitPercent);
  } else if (rsi > 80) {
    signal = 'SELL';
    stopLoss = price * (1 + stopLossPercent);
    takeProfit = price * (1 - takeProfitPercent);
  }
  
  if (!signal) return null;
  
  // Position sizing: risk 1% of capital
  const riskAmount = capital * riskPerTrade;
  const riskPerShare = Math.abs(price - stopLoss);
  const positionSize = Math.floor(riskAmount / riskPerShare);
  
  return {
    symbol,
    price: parseFloat(price.toFixed(2)),
    rsi: parseFloat(rsi.toFixed(1)),
    signal,
    entry_price: parseFloat(entryPrice.toFixed(2)),
    stop_loss: parseFloat(stopLoss.toFixed(2)),
    take_profit: parseFloat(takeProfit.toFixed(2)),
    position_size: positionSize,
    risk_amount: riskAmount,
    timestamp: new Date().toISOString(),
    status: 'ACTIVE'
  };
}

// ============================================
// WATCHLIST
// ============================================
const WATCHLIST = [
  'AAPL', 'MSFT', 'GOOGL', 'TSLA', 'AMZN',
  'NVDA', 'META', 'AMD', 'NFLX', 'SPY'
];

let cachedSignals = [];
let lastUpdate = null;

// ============================================
// FETCH REAL MARKET DATA
// ============================================
async function fetchMarketData() {
  try {
    if (!isMarketOpen()) {
      console.log('⏰ Market is closed. Using cached data.');
      return cachedSignals;
    }
    
    const signals = [];
    
    for (const symbol of WATCHLIST) {
      try {
        // Fetch 15-minute candles for last 20 periods
        const result = await yahooFinance.chart(symbol, {
          period1: new Date(Date.now() - 24 * 60 * 60 * 1000), // 24 hours ago
          interval: '15m'
        });
        
        if (!result || !result.quotes || result.quotes.length < 10) {
          console.log(`⚠️  Insufficient data for ${symbol}`);
          continue;
        }
        
        const prices = result.quotes.map(q => q.close).filter(p => p != null);
        const currentPrice = prices[prices.length - 1];
        const rsi = calculateRSI(prices, 2);
        
        if (rsi === null) continue;
        
        const signal = generateSignal(symbol, currentPrice, rsi);
        if (signal) {
          signals.push(signal);
        }
      } catch (err) {
        console.error(`Error fetching ${symbol}:`, err.message);
      }
    }
    
    cachedSignals = signals;
    lastUpdate = new Date();
    
    return signals;
  } catch (error) {
    console.error('Error fetching market data:', error);
    return cachedSignals;
  }
}

// ============================================
// API ROUTES
// ============================================
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    marketOpen: isMarketOpen(),
    lastUpdate: lastUpdate
  });
});

app.get('/api/signals', async (req, res) => {
  const signals = await fetchMarketData();
  res.json(signals);
});

app.get('/api/performance', (req, res) => {
  // TODO: Implement real performance tracking in Phase 5
  res.json({
    total_trades: 0,
    winning_trades: 0,
    win_rate: 0,
    total_profit: 0,
    account_balance: 10000
  });
});

app.get('/api/export/csv', async (req, res) => {
  const signals = await fetchMarketData();
  const csv = 'Symbol,Price,RSI,Signal,Entry,Stop Loss,Take Profit,Position,Status,Timestamp\\n' +
    signals.map(s => `${s.symbol},${s.price},${s.rsi},${s.signal},${s.entry_price},${s.stop_loss},${s.take_profit},${s.position_size},${s.status},${s.timestamp}`).join('\\n');
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename=signals.csv');
  res.send(csv);
});

// Start server and fetch data every 5 minutes
app.listen(PORT, async () => {
  console.log(`✅ Backend running on http://localhost:${PORT}`);
  console.log(`📊 Phase 4: REAL market data integration active!`);
  console.log(`⏰ Market open: ${isMarketOpen()}`);
  
  // Initial fetch
  await fetchMarketData();
  
  // Refresh every 5 minutes during market hours
  setInterval(async () => {
    if (isMarketOpen()) {
      console.log('🔄 Refreshing market data...');
      await fetchMarketData();
    }
  }, 5 * 60 * 1000);
});
EOF

echo "✅ Phase 4 code installed!"
echo ""
echo "🔄 Restarting backend server..."
echo ""
echo "Run this command to restart:"
echo "cd backend && npm run dev"
echo ""
echo "📊 Phase 4 Features:"
echo "  ✅ Real Yahoo Finance data (FREE)"
echo "  ✅ 15-minute candles"
echo "  ✅ RSI 2-Period calculation"
echo "  ✅ Automatic signal generation"
echo "  ✅ Market hours validation"
echo "  ✅ Auto-refresh every 5 minutes"
echo "  ✅ Position sizing (1% risk)"
echo ""
echo "🎯 Your screener now uses REAL market data!"
