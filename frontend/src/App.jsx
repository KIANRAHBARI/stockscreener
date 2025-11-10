import React, { useState, useEffect } from 'react';

function App() {
  const [signals, setSignals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(null);

  useEffect(() => {
    fetchSignals();
    const interval = setInterval(fetchSignals, 300000);
    return () => clearInterval(interval);
  }, []);

  const fetchSignals = async () => {
    try {
      const response = await fetch('http://localhost:3001/api/signals');
      const data = await response.json();
      setSignals(data);
      setLastUpdate(new Date());
      setLoading(false);
    } catch (error) {
      console.error('Error fetching signals:', error);
      setLoading(false);
    }
  };

  if (loading) {
    return <div style={{padding: '20px', textAlign: 'center'}}>Loading signals...</div>;
  }

  return (
    <div style={{padding: '20px', fontFamily: 'Arial, sans-serif', maxWidth: '1400px', margin: '0 auto'}}>
      <div style={{marginBottom: '30px'}}>
        <h1 style={{marginBottom: '10px'}}>🎯 Stock Screener - RSI 2-Period Strategy</h1>
        <div style={{display: 'flex', gap: '20px', color: '#666'}}>
          <div>💰 Capital: $10,000 CAD</div>
          <div>⚠️ Risk per Trade: 1% ($100)</div>
          <div>📈 Expected Win Rate: 91%</div>
          {lastUpdate && <div>🕐 Last Update: {lastUpdate.toLocaleTimeString()}</div>}
        </div>
      </div>
      
      <table style={{width: '100%', borderCollapse: 'collapse', boxShadow: '0 2px 4px rgba(0,0,0,0.1)'}}>
        <thead>
          <tr style={{backgroundColor: '#2c3e50', color: 'white'}}>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'left'}}>Symbol</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>Signal</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>RSI</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>Entry Price</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>Stop Loss</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>Take Profit</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>Shares</th>
            <th style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>Quality</th>
          </tr>
        </thead>
        <tbody>
          {signals.map((signal, index) => (
            <tr key={index} style={{backgroundColor: index % 2 === 0 ? '#f9f9f9' : 'white'}}>
              <td style={{padding: '12px', border: '1px solid #ddd', fontWeight: 'bold'}}>{signal.symbol}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>
                <span style={{
                  padding: '4px 12px',
                  borderRadius: '4px',
                  fontWeight: 'bold',
                  backgroundColor: signal.signal === 'BUY' ? '#27ae60' : '#e74c3c',
                  color: 'white'
                }}>
                  {signal.signal}
                </span>
              </td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>{signal.rsi.toFixed(2)}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right'}}>${signal.entryPrice.toFixed(2)}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right', color: '#e74c3c'}}>${signal.stopLoss.toFixed(2)}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'right', color: '#27ae60'}}>${signal.takeProfit.toFixed(2)}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>{signal.shares}</td>
              <td style={{padding: '12px', border: '1px solid #ddd', textAlign: 'center'}}>
                <span style={{
                  padding: '4px 8px',
                  borderRadius: '4px',
                  backgroundColor: signal.quality === 'HIGH' ? '#3498db' : '#95a5a6',
                  color: 'white',
                  fontSize: '12px'
                }}>
                  {signal.quality}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      
      {signals.length === 0 && (
        <div style={{textAlign: 'center', padding: '40px', color: '#999'}}>
          No signals available at this time. Market may be closed or no opportunities detected.
        </div>
      )}
    </div>
  );
}

export default App;
