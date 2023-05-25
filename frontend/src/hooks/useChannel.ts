import React, { useState, useEffect, useRef } from 'react'

// Needed for @rails/actioncable
global.addEventListener = () => { };
global.removeEventListener = () => { };



export default function useChannel(actionCable) {
    const [connected, setConnected] = useState(false)
    const [subscribed, setSubscribed] = useState(false)
    const channelRef = useRef();

    const subscribe = (data, callbacks) => {
        console.log(`useChannel - INFO: Connecting to ${data.channel}`)
        const channel = actionCable.subscriptions.create(data, {
            received: (x) => {
                if (callbacks.received) callbacks.received(x)
            },
            initialized: () => {
                console.log('useChannel - INFO: Init ' + data.channel)
                setSubscribed(true)
                if (callbacks.initialized) callbacks.initialized()
            },
            connected: () => {
                console.log('useChannel - INFO: Connected to ' + data.channel)
                setConnected(true)
                if (callbacks.connected) callbacks.connected()
            },
            disconnected: () => {
                console.log('useChannel - INFO: Disconnected')
                setConnected(false)
                if (callbacks.disconnected) callbacks.disconnected()
            }
        })
        channelRef.current = channel
    }

    useEffect(() => {
        return () => {
            unsubscribe()
        }
    }, [])

    const unsubscribe = () => {
        setSubscribed(false)
        if (channelRef.current) {
            console.log('useChannel - INFO: Unsubscribing from :', channelRef?.current)
            actionCable.subscriptions.remove(channelRef.current)
            channelRef.current = null
        }
    }

    const send = (type, payload) => {
        if (subscribed && !connected) throw 'useChannel - ERROR: not connected'
        if (!subscribed) throw 'useChannel - ERROR: not subscribed'

        // try {
        //     channelRef?.current?.perform(type, payload)
        // } catch (e) {
        //     throw 'useChannel - ERROR: ' + e
        // }
    }

    return { subscribe, unsubscribe, send }
}