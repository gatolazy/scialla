import { useNavigate } from "react-router-dom";
import AuthService from "../services/AuthService";
import UserContext from "../contexts/UserContext";
import React, { useEffect } from "react";

function Logout() {
    const { signout } = AuthService();
    const { setUser } = React.useContext(UserContext);
    const navigate = useNavigate();
    useEffect(() => {
        signout();
        setUser(null);
        navigate('/login');
        localStorage.removeItem("_mimoRoomId");
    }, []);
    return (<></>);
}

export default Logout;