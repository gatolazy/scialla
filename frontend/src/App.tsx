import React, { useReducer } from "react";
import logo from "./logo.svg";
import "./App.css";
import Router from "./Router";
import UserContext from "./contexts/UserContext";
import User from "./models/User";

function reducer(currentState: User | null, newState: User) {
    if (!newState?.display_name) {
        return null;
    }
    return { ...newState };
}

function App() {
    const _loggedUser: User | null = localStorage.getItem("user")
        ? JSON.parse(localStorage.getItem("user"))
        : null;
    const [user, setUser] = useReducer(reducer, _loggedUser);

    return (
        <>
            <UserContext.Provider value={{ user, setUser }}>
                <Router />
            </UserContext.Provider>
        </>
    );
}

export default App;
