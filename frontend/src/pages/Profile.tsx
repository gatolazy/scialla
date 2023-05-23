import { Box } from "@mui/material";
import Layout from "../layout/Layout";
import UserContext from "../contexts/UserContext";
import React from "react";

function Profile() {
    const { user } = React.useContext(UserContext);

    return (
        <Layout>
            <Box sx={{
                marginTop: 8,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
            }}>
                <h1>Benvenuto {user?.display_name}</h1>
            </Box>

        </Layout>
    );
}

export default Profile;