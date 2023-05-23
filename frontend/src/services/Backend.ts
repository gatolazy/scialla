import axios from "axios";
import API_ROUTES from "../enums/ApiRoutes";
import Credentials from "../models/Credentials";

if (process.env.REACT_APP_BACKEND_API_BASE_URL) {
    console.log(process.env.REACT_APP_BACKEND_API_BASE_URL);
    axios.defaults.baseURL =
        process.env.REACT_APP_BACKEND_API_BASE_URL + "/api";
}

function _setToken(token: string) {
    axios.defaults.headers.common = { Authorization: `Bearer ${token}` };
}

async function _signin(credentials: Credentials) {
    return await axios({
        method: "POST",
        url: API_ROUTES.SIGN_UP,
        data: {
            username: credentials.email,
            password: credentials.password,
        },
    });
}

const Backend = {
    setToken: _setToken,
    signin: _signin,
};

export default Backend;
