import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Credentials from "../models/Credentials";
import Backend from "./Backend";
import User from "../models/User";


function AuthService() {
    //const [errors, setErrors] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();

    async function signin(credentials: Credentials) {
        try {
            setIsLoading(true);
            const resp = await Backend.signin(credentials);
            const tokenJWT = resp?.data?.data?.token;
            if (!tokenJWT) {
                console.warn("Something went wrong during signing up: ", resp);
                return;
            } else {
                Backend.setToken(tokenJWT);
                const user: User = {
                    display_name: resp?.data?.data?.display_name,
                    department: resp?.data?.data?.department
                };
                localStorage.setItem("_sciallaToken", tokenJWT);
                localStorage.setItem("user", JSON.stringify(user));
                return user;
            }
        } catch (err) {
            console.error("Some error occured during signing up: ", err);
        } finally {
            setIsLoading(false);
        }
    }

    function signout() {
        localStorage.removeItem("_sciallaToken");
        localStorage.removeItem("user");
        navigate('/login');
    }

    return {
        signin,
        signout,
        //errors,
        isLoading,
    };
}

export default AuthService;
