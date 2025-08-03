#!/usr/bin/env bb

(import java.time.ZoneId)
(println (-> (ZoneId/systemDefault) (str)))
