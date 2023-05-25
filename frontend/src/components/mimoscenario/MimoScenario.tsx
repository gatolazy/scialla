import { Box } from "@mui/system";
import Layout from '../../layout/Layout';
import { useEffect, useState } from "react";
import useActionCable from '../../hooks/useActionCable';
import useChannel from '../../hooks/useChannel';
import MimoScenarioStatus from '../../models/MimoScenarioStatus';
import LobbyChannel from "./Lobby";
import VideoGrid from "./VideoGrid";



function MimoScenario() {
    const idToken = localStorage.getItem("_sciallaToken");
    const wssUrl = process.env.REACT_APP_WSS_API_BASE_URL + '/api/cable?t=' + idToken;
    const { actionCable } = useActionCable(wssUrl);
    const { subscribe, unsubscribe } = useChannel(actionCable);
    const [data, setData] = useState(null);
    const [scenarioStatus, setScenarioStatus] = useState<MimoScenarioStatus>('lobby');
    const [roomId, setRoomId] = useState(localStorage.getItem("_mimoRoomId"));

    const subOnMimoRoom = (roomId) => {
        //unsubscribe();
        subscribe({ channel: roomId }, {
            received: mimoBL,
            connected: () => {
                setScenarioStatus('room');
                localStorage.setItem("_mimoRoomId", roomId);
                setRoomId(roomId)
            }
        })
    }

    const mimoBL = (mimoMsg) => {
        console.log({ mimoMsg });
        setData(mimoMsg);
    }

    useEffect(() => {
        if (roomId) {
            subOnMimoRoom(roomId);
        } else {
            subscribe({ channel: 'LobbyChannel' }, {
                received: (mimoRoomId) => {
                    unsubscribe();
                    subOnMimoRoom(mimoRoomId);
                },
            });
        }

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
                {scenarioStatus}
                {scenarioStatus === 'lobby' ? <LobbyChannel /> : null}
                {scenarioStatus === 'room' ? <VideoGrid idToken={idToken} /> : null}
            </Box>
        </Layout>
    );
}

export default MimoScenario;
