{-# LANGUAGE OverloadedStrings #-}

import Network.Wai (responseLBS, Application, rawPathInfo)
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types (status200, status404)
import Database.Redis
import Control.Monad.IO.Class

index = responseLBS
    status200
    [("Content-Type", "text/plain")]
    "hello world"

getStatus test = responseLBS
    status200
    [("Content-Type", "text/plain")]
    "get!"   

connectRedis = do
    conn <- connect defaultConnectInfo
    runRedis conn $ do
        set "a" "apple"
        a <- get "a" 
        liftIO a

notFound = responseLBS
    status404
    [("Content-Type", "text/plain")]
    "not found"

app :: Application
app request respond =
    respond $ case rawPathInfo request of
    "/" -> index
    "/get/" -> getStatus =<< connectRedis
    _ -> notFound

main :: IO ()
main = do
    let port = 8080
    putStrLn $ "listen port " ++ show port
    run port app
