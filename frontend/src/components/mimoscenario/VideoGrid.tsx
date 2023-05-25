import { Box } from "@mui/material";
import { useEffect, useRef } from "react";




function VideoGrid({ idToken }) {

    var localVideo = useRef(null);
    var localStream;
    var remoteVideo = useRef(null);
    var peerConnection;
    var uuid;
    var serverConnection;
    const werRTCUrl = process.env.REACT_APP_WEBRTC_WS_URL;

    var peerConnectionConfig = {
        'iceServers': [
            { 'urls': 'stun:stun.stunprotocol.org:3478' },
            { 'urls': 'stun:stun.l.google.com:19302' },
        ]
    };

    function pageReady(idToken) {
        uuid = createUUID();

        localVideo.current = document.getElementById('localVideo');
        remoteVideo.current = document.getElementById('remoteVideo');

        serverConnection = new WebSocket(
            `${werRTCUrl}/webrtcdemo?t=${idToken}`
        );
        serverConnection.onmessage = gotMessageFromServer;

        var constraints = {
            video: true,
            audio: true,
        };

        if (navigator.mediaDevices.getUserMedia) {
            navigator.mediaDevices.getUserMedia(constraints).then(getUserMediaSuccess).catch(errorHandler);
        } else {
            alert('Your browser does not support getUserMedia API');
        }
    }

    function getUserMediaSuccess(stream) {
        localStream = stream;
        localVideo.current.srcObject = stream;
    }

    function start(isCaller) {
        peerConnection = new RTCPeerConnection(peerConnectionConfig);
        peerConnection.onicecandidate = gotIceCandidate;
        peerConnection.ontrack = gotRemoteStream;
        peerConnection.addStream(localStream);

        if (isCaller) {
            peerConnection.createOffer().then(createdDescription).catch(errorHandler);
        }
    }

    function gotMessageFromServer(message) {
        if (!peerConnection) start(false);

        var signal = JSON.parse(message.data);

        // Ignore messages from ourself
        if (signal.uuid === uuid) return;

        if (signal.sdp) {
            peerConnection.setRemoteDescription(new RTCSessionDescription(signal.sdp)).then(function () {
                // Only create answers in response to offers
                if (signal.sdp.type === 'offer') {
                    peerConnection.createAnswer().then(createdDescription).catch(errorHandler);
                }
            }).catch(errorHandler);
        } else if (signal.ice) {
            peerConnection.addIceCandidate(new RTCIceCandidate(signal.ice)).catch(errorHandler);
        }
    }

    function gotIceCandidate(event) {
        if (event.candidate != null) {
            serverConnection.send(JSON.stringify({ 'ice': event.candidate, 'uuid': uuid }));
        }
    }

    function createdDescription(description) {
        console.log('got description');

        peerConnection.setLocalDescription(description).then(function () {
            serverConnection.send(JSON.stringify({ 'sdp': peerConnection.localDescription, 'uuid': uuid }));
        }).catch(errorHandler);
    }

    function gotRemoteStream(event) {
        console.log('got remote stream');
        remoteVideo.current.srcObject = event.streams[0];
    }

    function errorHandler(error) {
        console.log(error);
    }

    // Taken from http://stackoverflow.com/a/105074/515584
    // Strictly speaking, it's not a real UUID, but it gets the job done here
    function createUUID() {
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
        }

        return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
    }

    useEffect(() => {
        pageReady(idToken);
    }, []);


    return (
        <Box>
            <video ref={localVideo}  id="localVideo" autoPlay={true} muted></video>
            <video ref={remoteVideo} id="remoteVideo" autoPlay></video>

            <br />

            <input type="button" id="start" onClick={() => start(true)} value="Start Video"></input>
        </Box>
    )
}




export default VideoGrid;