import { Route, Routes } from "react-router-dom";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Profile from "./pages/Profile";
import RouteGuard from "./guards/RouteGuard";
import UserContext from "./contexts/UserContext";
import React from "react";
import Logout from "./pages/Logout";

function Router() {
    const { user } = React.useContext(UserContext);

    return (
        <>
            <Routes>
                <Route index element={user ? <Home /> : <Login />} />
                <Route path="login" element={user ? <Home /> : <Login />} />
                <Route element={<RouteGuard />}>
                    <Route path="/" element={<Home />} />
                    <Route path="profile" element={<Profile />} />
                    <Route path="logout" element={<Logout />} />
                    <Route
                        path="*"
                        element={<p>There's nothing here: 404!</p>}
                    />
                </Route>
            </Routes>
        </>
    );
}

export default Router;
