# Phase 3: Dashboard, Visualization & Data Export - Development Plan

## Overview

Phase 3 builds the frontend user interface and implements comprehensive data export functionality. This phase transforms the backend trading engine into a complete, user-friendly application with Google Sheets and Excel export capabilities for detailed trade analysis.

**Status**: PLANNED (To be implemented after Phase 1 & 2 errors are fixed)

**Estimated Timeline**: 2-3 weeks

---

## Objectives

### Primary Goals:
1. ✅ Build React dashboard for real-time signal visualization
2. ✅ Display live RSI 2-Period signals with entry/exit prices
3. ✅ Implement backtest results visualization
4. ✅ **Export backtesting data to Google Sheets/Excel**
5. ✅ **Export trade history to Google Sheets/Excel**
6. ✅ Create interactive stock charts with RSI overlay
7. ✅ Real-time watchlist management
8. ✅ Performance metrics dashboard

### Key User Stories:
- As a trader, I want to see live trading signals in a clean dashboard
- As a trader, I want to export my backtest results to Google Sheets for detailed analysis
- As a trader, I want to export my trade history to Excel for record-keeping
- As a trader, I want to visualize RSI patterns on stock charts
- As a trader, I want to track my win rate and profit/loss metrics

---

## Architecture Overview

### Technology Stack

**Frontend:**
- React 18 + Vite
- TanStack Query (React Query) - Server state management
- Recharts - Stock charts and RSI visualization
- Tailwind CSS - Styling
- Axios - API communication

**Data Export:**
- **Google Sheets API** - Direct integration for live data sync
- **XLSX library** (SheetJS) - Excel file generation
- Backend export endpoints

**Backend Additions:**
- `/api/export/backtest/:format` - Export backtest data (google-sheets, excel, csv)
- `/api/export/trades/:format` - Export trade history
- `/api/export/signals/:format` - Export signal history
- Google Sheets OAuth integration

---

## Phase 3A: Data Export System (PRIORITY)

### Why This First?
Before building the UI, implement data export so you can analyze backtesting and trading data immediately. This provides value even before the dashboard is complete.

### 3A.1: Backend Export API

**File**: `backend/src/routes/export.js`

```javascript
const express = require('express');
const router = express.Router();
const { google } = require('googleapis');
const XLSX = require('xlsx');
const BacktestService = require('../services/backtestService');
const TradeService = require('../services/tradeService');

// Export backtest results
router.get('/backtest/:format', async (req, res) => {
  try {
    const { format } = req.params; // 'excel', 'csv', 'google-sheets'
    const { symbol, startDate, endDate } = req.query;
    
    const backtestData = await BacktestService.getBacktestResults({
      symbol,
      startDate,
      endDate
    });

    if (format === 'excel') {
      return exportToExcel(res, backtestData, 'Backtest_Results');
    } else if (format === 'csv') {
      return exportToCSV(res, backtestData);
    } else if (format === 'google-sheets') {
      // Requires OAuth - covered in 3A.3
      return await exportToGoogleSheets(req, res, backtestData);
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Export trade history
router.get('/trades/:format', async (req, res) => {
  try {
    const { format } = req.params;
    const { startDate, endDate, status } = req.query;
    
    const trades = await TradeService.getTrades({
      startDate,
      endDate,
      status
    });

    if (format === 'excel') {
      return exportToExcel(res, trades, 'Trade_History');
    } else if (format === 'csv') {
      return exportToCSV(res, trades);
    } else if (format === 'google-sheets') {
      return await exportToGoogleSheets(req, res, trades);
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 3A.2: Excel Export Implementation

**File**: `backend/src/utils/excelExport.js`

```javascript
const XLSX = require('xlsx');

function exportToExcel(res, data, sheetName) {
  // Convert data to worksheet
  const worksheet = XLSX.utils.json_to_sheet(data);
  
  // Create workbook
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, sheetName);
  
  // Generate buffer
  const buffer = XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });
  
  // Set headers
  res.setHeader('Content-Disposition', `attachment; filename="${sheetName}_${Date.now()}.xlsx"`);
  res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  
  res.send(buffer);
}

module.exports = { exportToExcel };
```

**Data Structure for Backtest Export:**
```json
[
  {
    "Date": "2025-11-09",
    "Symbol": "AAPL",
    "Signal": "LONG",
    "Entry_Price": 225.50,
    "Exit_Price": 228.88,
    "Stop_Loss": 224.38,
    "Take_Profit": 228.88,
    "Position_Size": 444,
    "Risk_Amount": 100.00,
    "Profit_Loss": 1500.72,
    "Profit_Loss_Percent": 1.5,
    "RSI_Entry": 28.5,
    "Outcome": "WIN",
    "Hold_Duration": "2h 15m"
  }
]
```

### 3A.3: Google Sheets Integration

**Setup Steps:**
1. Go to Google Cloud Console (https://console.cloud.google.com/)
2. Create new project: "StockScreener-Export"
3. Enable Google Sheets API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URI: `http://localhost:5000/auth/google/callback`
6. Download credentials JSON

**File**: `backend/src/services/googleSheetsService.js`

```javascript
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

class GoogleSheetsService {
  constructor() {
    this.auth = null;
    this.sheets = null;
  }

  async authenticate(accessToken) {
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI
    );

    oauth2Client.setCredentials({ access_token: accessToken });
    this.sheets = google.sheets({ version: 'v4', auth: oauth2Client });
  }

  async createSpreadsheet(title, data) {
    const resource = {
      properties: { title }
    };

    const spreadsheet = await this.sheets.spreadsheets.create({ resource });
    const spreadsheetId = spreadsheet.data.spreadsheetId;

    // Add data
    await this.appendData(spreadsheetId, 'Sheet1', data);

    return {
      spreadsheetId,
      url: `https://docs.google.com/spreadsheets/d/${spreadsheetId}`
    };
  }

  async appendData(spreadsheetId, sheetName, data) {
    // Convert JSON to 2D array
    const headers = Object.keys(data[0]);
    const values = [headers, ...data.map(row => headers.map(h => row[h]))];

    await this.sheets.spreadsheets.values.append({
      spreadsheetId,
      range: `${sheetName}!A1`,
      valueInputOption: 'RAW',
      resource: { values }
    });
  }
}

module.exports = new GoogleSheetsService();
```

### 3A.4: Required Dependencies

**Update `backend/package.json`:**
```json
{
  "dependencies": {
    "xlsx": "^0.18.5",
    "googleapis": "^128.0.0",
    "json2csv": "^6.0.0"
  }
}
```

**Installation:**
```bash
cd backend
npm install xlsx googleapis json2csv
```

---

## Phase 3B: React Dashboard

### 3B.1: Project Setup

```bash
# Create frontend directory
mkdir frontend
cd frontend
npm create vite@latest . -- --template react
npm install

# Install dependencies
npm install @tanstack/react-query axios recharts lucide-react
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 3B.2: Core Components

#### Dashboard Layout
**File**: `frontend/src/pages/Dashboard.jsx`

```jsx
import { useState } from 'react';
import SignalList from '../components/SignalList';
import StockChart from '../components/StockChart';
import PerformanceMetrics from '../components/PerformanceMetrics';
import ExportButton from '../components/ExportButton';

export default function Dashboard() {
  const [selectedSymbol, setSelectedSymbol] = useState(null);

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <header className="bg-gray-800 p-4 shadow-lg">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">Stock Screener - RSI 2-Period</h1>
          <div className="flex gap-2">
            <ExportButton type="backtest" />
            <ExportButton type="trades" />
          </div>
        </div>
      </header>

      <main className="container mx-auto p-4 grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Left: Signal List */}
        <div className="lg:col-span-1">
          <SignalList onSelectSymbol={setSelectedSymbol} />
        </div>

        {/* Middle: Chart */}
        <div className="lg:col-span-2">
          <StockChart symbol={selectedSymbol} />
          <PerformanceMetrics />
        </div>
      </main>
    </div>
  );
}
```

#### Export Button Component
**File**: `frontend/src/components/ExportButton.jsx`

```jsx
import { useState } from 'react';
import { Download } from 'lucide-react';
import axios from 'axios';

export default function ExportButton({ type }) {
  const [loading, setLoading] = useState(false);
  const [showMenu, setShowMenu] = useState(false);

  const handleExport = async (format) => {
    setLoading(true);
    try {
      const response = await axios.get(
        `http://localhost:5000/api/export/${type}/${format}`,
        { responseType: format === 'excel' ? 'blob' : 'json' }
      );

      if (format === 'excel') {
        // Download Excel file
        const url = window.URL.createObjectURL(new Blob([response.data]));
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', `${type}_${Date.now()}.xlsx`);
        document.body.appendChild(link);
        link.click();
        link.remove();
      } else if (format === 'google-sheets') {
        // Open Google Sheets URL
        window.open(response.data.url, '_blank');
      }

      setShowMenu(false);
    } catch (error) {
      console.error('Export failed:', error);
      alert('Export failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative">
      <button
        onClick={() => setShowMenu(!showMenu)}
        className="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded flex items-center gap-2"
        disabled={loading}
      >
        <Download size={18} />
        Export {type}
      </button>

      {showMenu && (
        <div className="absolute right-0 mt-2 bg-gray-800 rounded shadow-lg p-2 w-48">
          <button
            onClick={() => handleExport('excel')}
            className="w-full text-left px-4 py-2 hover:bg-gray-700 rounded"
          >
            Download Excel
          </button>
          <button
            onClick={() => handleExport('google-sheets')}
            className="w-full text-left px-4 py-2 hover:bg-gray-700 rounded"
          >
            Export to Google Sheets
          </button>
          <button
            onClick={() => handleExport('csv')}
            className="w-full text-left px-4 py-2 hover:bg-gray-700 rounded"
          >
            Download CSV
          </button>
        </div>
      )}
    </div>
  );
}
```

#### Signal List Component
**File**: `frontend/src/components/SignalList.jsx`

```jsx
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';
import { TrendingUp, TrendingDown } from 'lucide-react';

export default function SignalList({ onSelectSymbol }) {
  const { data: signals, isLoading } = useQuery({
    queryKey: ['signals'],
    queryFn: async () => {
      const { data } = await axios.get('http://localhost:5000/api/signals');
      return data;
    },
    refetchInterval: 60000 // Refresh every minute
  });

  if (isLoading) return <div>Loading signals...</div>;

  return (
    <div className="bg-gray-800 rounded-lg p-4">
      <h2 className="text-xl font-bold mb-4">Live Signals</h2>
      <div className="space-y-2">
        {signals?.map((signal) => (
          <div
            key={signal.id}
            onClick={() => onSelectSymbol(signal.symbol)}
            className="bg-gray-700 p-3 rounded cursor-pointer hover:bg-gray-600"
          >
            <div className="flex justify-between items-center">
              <div>
                <span className="font-bold">{signal.symbol}</span>
                <span className={`ml-2 px-2 py-1 rounded text-sm ${
                  signal.signal === 'LONG' ? 'bg-green-600' : 'bg-red-600'
                }`}>
                  {signal.signal === 'LONG' ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
                  {signal.signal}
                </span>
              </div>
              <div className="text-right">
                <div className="text-sm">Entry: ${signal.entryPrice.toFixed(2)}</div>
                <div className="text-xs text-gray-400">RSI: {signal.rsi.toFixed(1)}</div>
              </div>
            </div>
            <div className="mt-2 text-xs text-gray-400">
              <div>Stop: ${signal.stopLoss.toFixed(2)} | Target: ${signal.takeProfit.toFixed(2)}</div>
              <div>Position: {signal.positionSize} shares (${signal.positionValue.toFixed(0)})</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Phase 3C: Additional Dashboard Features

### 3C.1: Stock Chart with RSI Overlay

**File**: `frontend/src/components/StockChart.jsx`

```jsx
import { useQuery } from '@tanstack/react-query';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, ReferenceLine } from 'recharts';
import axios from 'axios';

export default function StockChart({ symbol }) {
  const { data } = useQuery({
    queryKey: ['chartData', symbol],
    queryFn: async () => {
      if (!symbol) return null;
      const { data } = await axios.get(`http://localhost:5000/api/chart/${symbol}`);
      return data;
    },
    enabled: !!symbol
  });

  if (!symbol) {
    return (
      <div className="bg-gray-800 rounded-lg p-8 text-center">
        <p className="text-gray-400">Select a signal to view chart</p>
      </div>
    );
  }

  return (
    <div className="bg-gray-800 rounded-lg p-4">
      <h2 className="text-xl font-bold mb-4">{symbol} - 15min Chart</h2>
      
      {/* Price Chart */}
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data?.candles}>
          <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
          <XAxis dataKey="time" stroke="#9CA3AF" />
          <YAxis stroke="#9CA3AF" domain={['dataMin - 1', 'dataMax + 1']} />
          <Tooltip contentStyle={{ backgroundColor: '#1F2937', border: 'none' }} />
          <Legend />
          <Line type="monotone" dataKey="close" stroke="#3B82F6" name="Price" />
        </LineChart>
      </ResponsiveContainer>

      {/* RSI Chart */}
      <ResponsiveContainer width="100%" height={150}>
        <LineChart data={data?.candles}>
          <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
          <XAxis dataKey="time" stroke="#9CA3AF" />
          <YAxis stroke="#9CA3AF" domain={[0, 100]} />
          <Tooltip contentStyle={{ backgroundColor: '#1F2937', border: 'none' }} />
          <Legend />
          <Line type="monotone" dataKey="rsi" stroke="#10B981" name="RSI" />
          <ReferenceLine y={30} stroke="#EF4444" strokeDasharray="3 3" label="Oversold" />
          <ReferenceLine y={70} stroke="#EF4444" strokeDasharray="3 3" label="Overbought" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

---

## Implementation Roadmap

### Week 1: Data Export (Priority)
- [ ] Day 1-2: Implement Excel export with XLSX library
- [ ] Day 3-4: Build Google Sheets OAuth integration
- [ ] Day 5: Create export API routes
- [ ] Day 6: Test all export formats
- [ ] Day 7: Document export functionality

### Week 2: React Dashboard
- [ ] Day 1-2: Setup React project with Vite + Tailwind
- [ ] Day 3-4: Build SignalList and ExportButton components
- [ ] Day 5-6: Implement StockChart with RSI overlay
- [ ] Day 7: Connect all components to backend APIs

### Week 3: Polish & Testing
- [ ] Day 1-2: Add PerformanceMetrics dashboard
- [ ] Day 3-4: Implement real-time updates with polling/WebSockets
- [ ] Day 5: Add loading states and error handling
- [ ] Day 6: User testing and bug fixes
- [ ] Day 7: Documentation and deployment guide

---

## Dependencies Summary

### Backend New Dependencies
```json
{
  "xlsx": "^0.18.5",
  "googleapis": "^128.0.0",
  "json2csv": "^6.0.0"
}
```

### Frontend Dependencies
```json
{
  "@tanstack/react-query": "^5.0.0",
  "axios": "^1.6.0",
  "recharts": "^2.10.0",
  "lucide-react": "^0.294.0",
  "react": "^18.2.0",
  "react-dom": "^18.2.0"
}
```

---

## Testing Plan

### Export Functionality Tests

1. **Excel Export Test:**
   ```bash
   curl -o backtest.xlsx http://localhost:5000/api/export/backtest/excel?symbol=AAPL
   # Open backtest.xlsx in Excel/LibreOffice
   # Verify all columns are present and data is accurate
   ```

2. **Google Sheets Export Test:**
   ```bash
   curl http://localhost:5000/api/export/trades/google-sheets
   # Should return: { "url": "https://docs.google.com/spreadsheets/d/..." }
   # Open URL and verify data
   ```

3. **CSV Export Test:**
   ```bash
   curl -o trades.csv http://localhost:5000/api/export/trades/csv
   # Open in spreadsheet software
   ```

### Dashboard Tests

1. **Signal Display:** Verify live signals appear with correct RSI values
2. **Chart Rendering:** Ensure 15-minute candles display with RSI overlay
3. **Export Buttons:** Test all 3 export formats (Excel, Google Sheets, CSV)
4. **Real-time Updates:** Confirm signals refresh every 60 seconds
5. **Mobile Responsive:** Test dashboard on mobile devices

---

## Environment Variables

**Add to `backend/.env`:**
```env
# Google Sheets API (for Phase 3A.3)
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
GOOGLE_REDIRECT_URI=http://localhost:5000/auth/google/callback

# Frontend URL
FRONTEND_URL=http://localhost:5173
```

---

## Success Metrics

### Phase 3 Completion Criteria:
- ✅ User can export backtest results to Excel with 1-click
- ✅ User can export trade history to Google Sheets
- ✅ User can view live RSI signals in dashboard
- ✅ User can see stock charts with RSI overlay
- ✅ User can track win rate and P/L metrics
- ✅ Dashboard updates automatically every minute
- ✅ All components are mobile-responsive

### Key Performance Indicators:
- Export functionality works 100% of the time
- Dashboard loads in <2 seconds
- Charts render smoothly with no lag
- User can analyze 30 days of backtest data in Excel
- Data export formats match expected structure

---

## Next Steps After Phase 3

### Phase 4: Questrade Broker Integration (Future)
- OAuth authentication with Questrade API
- Paper trading mode
- Manual order execution from dashboard
- Real-time account balance sync
- Position tracking

### Phase 5: Semi-Automation (Future)
- One-click order execution
- Bracket orders (entry + stop + target)
- SMS/Email alerts for signals
- Daily performance reports
- Auto-export trades to Google Sheets daily

---

## Data Export File Examples

### Backtest Results Excel File Structure:
| Date | Symbol | Signal | Entry Price | Exit Price | Stop Loss | Take Profit | Position Size | Risk Amount | P/L | P/L % | RSI Entry | Outcome | Hold Duration |
|------|--------|--------|-------------|------------|-----------|-------------|---------------|-------------|-----|-------|-----------|---------|---------------|
| 2025-11-09 | AAPL | LONG | 225.50 | 228.88 | 224.38 | 228.88 | 444 | $100.00 | $1,500.72 | 1.5% | 28.5 | WIN | 2h 15m |
| 2025-11-09 | MSFT | SHORT | 415.20 | 408.99 | 417.28 | 408.99 | 241 | $100.00 | $1,496.61 | 1.5% | 72.3 | WIN | 1h 45m |

### Trade History Excel File Structure:
| Trade ID | Date | Symbol | Type | Entry | Exit | Shares | P/L | Status | Notes |
|----------|------|--------|------|-------|------|--------|-----|--------|-------|
| 1001 | 2025-11-09 | AAPL | LONG | 225.50 | 228.88 | 444 | $1,500.72 | CLOSED | Target hit |
| 1002 | 2025-11-09 | TSLA | LONG | 245.00 | 243.78 | 408 | -$497.76 | CLOSED | Stop loss |

---

## Important Notes

### Google Sheets API Limitations:
- **Free Tier**: 60 requests per minute per user
- **Rate Limiting**: Implement exponential backoff
- **OAuth Token**: Expires after 1 hour (implement refresh logic)
- **File Permissions**: Set to "Anyone with link can view"

### Excel Export Considerations:
- **File Size**: Large backtests (1000+ trades) may take 5-10 seconds to generate
- **Memory Usage**: XLSX library loads entire file in memory
- **Browser Compatibility**: File download works in all modern browsers

### CSV Export Benefits:
- **Fastest Export**: Generates in milliseconds
- **Universal Format**: Opens in Excel, Google Sheets, Numbers, etc.
- **Smallest File Size**: Best for large datasets
- **No Dependencies**: Native to Node.js

---

## Priority Recommendation

**Start with Phase 3A (Data Export) because:**
1. Provides immediate value - you can analyze backtest data TODAY
2. Doesn't require frontend setup
3. Excel export is simpler than Google Sheets (no OAuth)
4. You can validate your 91% win rate with real exported data
5. Can be built and tested in 2-3 days

**Implementation Order:**
1. ✅ Excel export (Day 1-2) - HIGHEST PRIORITY
2. ✅ CSV export (Day 3) - Simple fallback
3. ✅ Google Sheets export (Day 4-5) - Advanced feature
4. ✅ React dashboard (Week 2) - Visual interface
5. ✅ Charts & polish (Week 3) - Enhanced UX

---

## Support & Resources

- **XLSX Documentation**: https://docs.sheetjs.com/
- **Google Sheets API**: https://developers.google.com/sheets/api
- **Recharts Examples**: https://recharts.org/en-US/examples
- **TanStack Query**: https://tanstack.com/query/latest

---

## Questions to Consider

1. Do you want automated daily exports to Google Sheets?
2. Should exports include a summary sheet with metrics (win rate, avg P/L, etc.)?
3. Do you want email notifications when export completes?
4. Should dashboard have dark/light mode?
5. Do you need user authentication for the dashboard?

---

**Ready to implement when Phase 1 & 2 errors are fixed and tested!** 🚀
