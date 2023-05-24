import { createConsumer } from '@rails/actioncable';



export function getConsumer() {
    const token = localStorage.getItem("_sciallaToken");
    const wssUrl = process.env.REACT_APP_WSS_API_BASE_URL + '/api/cable?t=' + token;
    return createConsumer(wssUrl);
}