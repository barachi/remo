{-# ANGUAGE OverloadedStrings #-}

import Database.Redis
import Control.Monad.IO.Class

main :: IO ()
main = do
    connectRedis

connectRedis = do
    conn <- connect defaultConnectInfo
    runRedis conn $ do
        set "a" "apple"
        set "b" "banana"
        a <- get "a" 
        b <- get "b" 
        pln (a, b)
    

pln (a, b) = do
    liftIO $ print (a, b)
