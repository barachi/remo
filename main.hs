{-# LANGUAGE OverloadedStrings #-}

import Network.Wai (responseLBS, Application, rawPathInfo, Response)
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types (status200, status404)
import Database.Redis
import Control.Monad.IO.Class
import Data.ByteString.Lazy.Char8 (pack)
import Data.ByteString.Internal

index = responseLBS
    status200
    [("Content-Type", "text/plain")]
    "hello world"

getStatus :: String -> Response
getStatus s = responseLBS
    status200
    [("Content-Type", "text/plain")]
    (pack s)

--connectRedis :: IO [Maybe Data.ByteString.Internal.ByteString]
connectRedis :: IO (Either Reply (Maybe ByteString))
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
app :: Application
app request respond =
    respond $ case rawPathInfo request of
    "/" -> index
--    "/get/" -> getStatus =<< connectRedis
    "/get/" -> hoge
    _ -> notFound


hoge :: Response
hoge = do
    a <- connectRedis
    responseLBS status200 [] $
        case a of
            Right Just s -> s
            _ -> "error"

main :: IO ()
main = do
    let port = 8080
    putStrLn $ "listen port " ++ show port
    run port app
