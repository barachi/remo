{-# LANGUAGE OverloadedStrings #-}

import Network.Wai (responseLBS, Application, rawPathInfo, Response)
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types (status200, status404)
import Database.Redis
import Control.Monad.IO.Class
import Data.ByteString.Lazy.Char8 (pack)
import Data.ByteString.Internal
import Data.ByteString.Lazy.Internal
import Data.ByteString.Lazy (fromStrict)

index = responseLBS
    status200
    [("Content-Type", "text/plain")]
    "hello world"

getStatus :: Data.ByteString.Internal.ByteString -> Response
getStatus s = responseLBS
    status200
    [("Content-Type", "text/plain")]
    (fromStrict s)

connectRedis :: IO (Either Reply (Maybe Data.ByteString.Internal.ByteString))
connectRedis = do
    conn <- connect defaultConnectInfo
    runRedis conn $ do
        set "a" "apple"
        a <- get "a" 
        return a

notFound = responseLBS
    status404
    [("Content-Type", "text/plain")]
    "not found"

-- Request -> (Response -> IO ResponseReceived) -> IO ResponseReceived
app :: Application
app request respond = do
    a <- getRedis
    respond $ case rawPathInfo request of
        "/" -> index
        "/get/" -> getStatus a
        _ -> notFound



getRedis :: IO Data.ByteString.Internal.ByteString
getRedis = do
    a <- connectRedis
    case a of
        Right (Just s) -> return s
        _ -> return "error"


main :: IO ()
main = do
    let port = 8080
    putStrLn $ "listen port " ++ show port
    run port app
