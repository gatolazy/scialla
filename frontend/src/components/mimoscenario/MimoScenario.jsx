import { Box } from "@mui/system";
import Layout from '../../layout/Layout';
import { useEffect, useState } from "react";
import useActionCable from '../../hooks/useActionCable';
import useChannel from '../../hooks/useChannel';

function MimoScenario() {
    const token = localStorage.getItem("_sciallaToken");
    const wssUrl = process.env.REACT_APP_WSS_API_BASE_URL + '/api/cable?t=' + token;
    const { actionCable } = useActionCable(wssUrl);
    const { subscribe, unsubscribe } = useChannel(actionCable);
    const [data, setData] = useState(null);


    const mimoBL = (mimoMsg) => {
        console.log({ mimoMsg });
        setData(mimoMsg);
    }

    useEffect(() => {
        subscribe({ channel: 'LobbyChannel' }, {
            received: (mimoRoomId) => {
                unsubscribe();
                subscribe({ channel: mimoRoomId }, {
                    received: mimoBL
                })
            }
        });
        return () => {
            unsubscribe()
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [])


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
                {data}
            </Box>
        </Layout>
    );
}

export default MimoScenario;
