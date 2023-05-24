import { Box } from "@mui/system";
import Layout from '../../layout/Layout';
import { getConsumer } from "../../services/WS";

function MimoScenario() {

    const consumer = getConsumer();
    consumer.subscriptions.create(
        {channel: 'LobbyChannel'},
        {
            connected: ()=> {console.log('connected')},
            disconnected: ()=> {console.log('disconnected')},
            received: (data)=> { console.log(data);}

        }
    );

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
                <h1>Mimo</h1>
            </Box>
        </Layout>
    );
}

export default MimoScenario;
