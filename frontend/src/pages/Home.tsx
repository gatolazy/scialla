import { Box } from "@mui/system";
import Layout from "../layout/Layout";

function Home() {
    return (
        <Layout>
            <Box
                sx={{
                    marginTop: 8,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                }}
            >
                <h1>Scenari</h1>
            </Box>
        </Layout>
    );
}

export default Home;
