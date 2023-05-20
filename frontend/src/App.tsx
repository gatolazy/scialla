import React from 'react';
import logo from './logo.svg';
import './App.css';
import Router from './Router';


function App() {
  const [user, setUser] = React.useState(null);

  return (
    <>
      <Router></Router>
    </>
  );
}

export default App;
