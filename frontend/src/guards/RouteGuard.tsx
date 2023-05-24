import { ReactElement } from "react";
import { Navigate, Outlet } from "react-router-dom";

export type RouteGuardProps = {
    redirectPath?: string,
    children?: ReactElement
 }

function RouteGuard ({ children, redirectPath = '/login' }: RouteGuardProps)  {
    function hasJWT() {
        let flag = false;

        //check user has JWT token
        localStorage.getItem("_sciallaToken") ? (flag = true) : (flag = false);

        return flag;
    }

    if (!hasJWT()) {
        return <Navigate to={redirectPath} replace />;
    }

    return children ? children : <Outlet />;
};

export default RouteGuard;
