#!/bin/bash
set -e

echo "🚀 UPGRADE 1: Real Market Data Integration"
echo "=========================================="
echo ""
echo "This upgrade replaces mock data with:"
echo "  ✅ Live Yahoo Finance 15-minute candles"
echo "  ✅ Real-time RSI 2-Period calculations"
echo "  ✅ Dynamic signal generation"
echo "  ✅ Market hours validation (9:30 AM - 4:00 PM ET)"
echo "  ✅ Auto-refresh every 5 minutes"
echo ""

# Update server.js with real market data
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

// RSI Calculator (2-Period)
function calculateRSI(prices, period = 2) {
  if (!prices || prices.length < period + 1) return null;
  
  const gains = [];
  const losses = [];
  
  for (let i = 1; i < prices.length; i++) {
    const change = prices[i] - prices[i - 1];
    gains.push(change > 0 ? change : 0);
    losses.push(change < 0 ? Math.abs(change) : 0);
  }
  
  const recentGains = gains.slice(-period);
  const recentLosses = losses.slice(-period);
  
  const avgGain = recentGains.reduce((a, b) => a + b, 0) / period;
  const avgLoss = recentLosses.reduce((a, b) => a + b, 0) / period;
  
  if (avgLoss === 0) return 100;
  const rs = avgGain / avgLoss;
  return 100 - (100 / (1 + rs));
}

// Market Hours Check
function isMarketOpen() {
  const now = new Date();
  const et = new Date(now.toLocaleString('en-US', { timeZone: 'America/New_York' }));
  const day = et.getDay(); // 0=Sun, 6=Sat
  const hour = et.getHours();
  const minute = et.getMinutes();
  
  if (day === 0 || day === 6) return false; // Weekend
  if (hour < 9 || hour >= 16) return false; // Before 9 AM or after 4 PM
  if (hour === 9 && minute < 30) return false; // Before 9:30 AM
  
  return true;
}

// Signal Generator
function generateSignal(symbol, price, rsi) {
  const STOP_LOSS_PCT = 0.005; // 0.5%
  const TAKE_PROFIT_PCT = 0.015; // 1.5%
  const RISK_PER_TRADE = 0.01; // 1%
  const CAPITAL = 10000;
  
  let signal = null;
  let stopLoss, takeProfit;
  
  if (rsi < 20) {
    signal = 'BUY';
    stopLoss = price * (1 - STOP_LOSS_PCT);
    takeProfit = price * (1 + TAKE_PROFIT_PCT);
  } else if (rsi > 80) {
    signal = 'SELL';
    stopLoss = price * (1 + STOP_LOSS_PCT);
    takeProfit = price * (1 - TAKE_PROFIT_PCT);
  }
  
  if (!signal) return null;
  
  const riskAmount = CAPITAL * RISK_PER_TRADE;
  const riskPerShare = Math.abs(price - stopLoss);
  const positionSize = Math.floor(riskAmount / riskPerShare);
  
  return {
    symbol,
    price: parseFloat(price.toFixed(2)),
    rsi: parseFloat(rsi.toFixed(1)),
    signal,
    entry_price: parseFloat(price.toFixed(2)),
    stop_loss: parseFloat(stopLoss.toFixed(2)),
    take_profit: parseFloat(takeProfit.toFixed(2)),
    position_size: positionSize,
    risk_amount: riskAmount,
    timestamp: new Date().toISOString(),
    status: 'ACTIVE'
  };
}

const WATCHLIST = ['AAPL', 'MSFT', 'GOOGL', 'TSLA', 'AMZN', 'NVDA', 'META', 'AMD', 'NFLX', 'SPY'];
let cachedSignals = [];
let lastUpdate = null;

// Fetch Real Market Data
async function fetchMarketData() {
  try {
    if (!isMarketOpen()) {
      console.log('⏰ Market closed - using cached data');
      return cachedSignals;
    }
    
    const signals = [];
    
    for (const symbol of WATCHLIST) {
      try {
        const result = await yahooFinance.chart(symbol, {
          period1: new Date(Date.now() - 24 * 60 * 60 * 1000),
          interval: '15m'
        });
        
        if (!result?.quotes || result.quotes.length < 10) continue;
        
        const prices = result.quotes.map(q => q.close).filter(p => p != null);
        const currentPrice = prices[prices.length - 1];
        const rsi = calculateRSI(prices, 2);
        
        if (rsi === null || rsi === undefined) continue;
        
        const signal = generateSignal(symbol, currentPrice, rsi);
        if (signal) signals.push(signal);
      } catch (err) {
        console.error(`Error fetching ${symbol}:`, err.message);
      }
    }
    
    cachedSignals = signals;
    lastUpdate = new Date();
    console.log(`🔄 Updated: ${signals.length} signals found`);
    
    return signals;
  } catch (error) {
    console.error('Market data error:', error);
    return cachedSignals;
  }
}

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    marketOpen: isMarketOpen(),
    lastUpdate: lastUpdate,
    signalCount: cachedSignals.length
  });
});

app.get('/api/signals', async (req, res) => {
  const signals = await fetchMarketData();
  res.json(signals);
});

app.get('/api/performance', (req, res) => {
  res.json({
    total_trades: cachedSignals.length,
    winning_trades: 0,
    win_rate: 0,
    total_profit: 0,
    account_balance: 10000
  });
});

app.get('/api/export/csv', async (req, res) => {
  const signals = await fetchMarketData();
  const csv = 'Symbol,Price,RSI,Signal,Entry,StopLoss,TakeProfit,Position,Status,Timestamp\\n' +
    signals.map(s => `${s.symbol},${s.price},${s.rsi},${s.signal},${s.entry_price},${s.stop_loss},${s.take_profit},${s.position_size},${s.status},${s.timestamp}`).join('\\n');
  
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename=signals.csv');
  res.send(csv);
});

app.listen(PORT, async () => {
  console.log(`✅ Backend: http://localhost:${PORT}`);
  console.log(`📊 UPGRADE 1: Real Market Data Active!`);
  console.log(`⏰ Market Open: ${isMarketOpen()}`);
  
  await fetchMarketData();
  
  setInterval(async () => {
    if (isMarketOpen()) {
      console.log('🔄 Refreshing market data...');
      await fetchMarketData();
    }
  }, 5 * 60 * 1000); // Every 5 minutes
});
EOF

echo "✅ Upgrade complete!"
echo ""
echo "🔄 Restart your backend:"
echo "   cd backend && npm run dev"
echo ""
echo "🌐 Then open: http://localhost:5173"
echo ""
echo "📊 You now have REAL market data!"
