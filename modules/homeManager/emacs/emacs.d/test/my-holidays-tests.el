;;; my-holidays-tests.el --- my-holidays-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-holidays)

(ert-deftest my-holidays-tests-hong-kong-general-holidays-1997 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 1997)
    '(((1 1 1997) "一月一日")
      ((2 6 1997) "農曆年初一的前一日")
      ((2 7 1997) "農曆年初一")
      ((2 8 1997) "農曆年初二")
      ((3 28 1997) "耶穌受難節")
      ((3 29 1997) "耶穌受難節翌日")
      ((3 31 1997) "復活節星期一")
      ((4 5 1997) "清明節")
      ((6 9 1997) "端午節")
      ((6 28 1997) "英女皇壽辰")
      ((6 30 1997) "英女皇壽辰後第一個星期一")
      ((7 1 1997) "香港特別行政區成立紀念日")
      ((7 2 1997) "香港特別行政區成立日翌日")
      ((8 18 1997) "抗日戰爭勝利紀念日")
      ((9 17 1997) "中秋節翌日")
      ((10 1 1997) "國慶日")
      ((10 2 1997) "國慶日翌日")
      ((10 10 1997) "重陽節")
      ((12 25 1997) "聖誕節")
      ((12 26 1997) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/199809/10/0910183.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-1999 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 1999)
    '(((1 1 1999) "一月一日")
      ((2 16 1999) "農曆年初一")
      ((2 17 1999) "農曆年初二")
      ((2 18 1999) "農曆年初三")
      ((4 2 1999) "耶穌受難節")
      ((4 3 1999) "耶穌受難節翌日")
      ;; The page lists this as 復活節星期一,
      ;; because 清明節 and 復活節星期一 fell on the same day.
      ((4 5 1999) "清明節")
      ;; The page lists this as 清明節翌日.
      ;; The 2021 and 2026 pages name the equivalent clash 復活節星期一翌日.
      ((4 6 1999) "復活節星期一翌日")
      ((5 1 1999) "勞動節")
      ((5 22 1999) "佛誕")
      ((6 18 1999) "端午節")
      ((7 1 1999) "香港特別行政區成立紀念日")
      ((9 25 1999) "中秋節翌日")
      ((10 1 1999) "國慶日")
      ((10 18 1999) "重陽節翌日")
      ((12 25 1999) "聖誕節")
      ((12 27 1999) "聖誕節後第一個周日")
      ;; The page lists this simply as 公眾假期.
      ((12 31 1999) "1999年第191號法律公告所定的公眾假期")))))

;; https://www.info.gov.hk/gia/general/200104/20/0420136.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2002 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2002)
    '(((1 1 2002) "一月一日")
      ((2 12 2002) "農曆年初一")
      ((2 13 2002) "農曆年初二")
      ((2 14 2002) "農曆年初三")
      ((3 29 2002) "耶穌受難節")
      ((3 30 2002) "耶穌受難節翌日")
      ((4 1 2002) "復活節星期一")
      ((4 5 2002) "清明節")
      ((5 1 2002) "勞動節")
      ;; The page lists this as 佛誕.
      ;; Its footnote says 佛誕 fell on Sunday, so this is the day after.
      ((5 20 2002) "佛誕翌日")
      ((6 15 2002) "端午節")
      ((7 1 2002) "香港特別行政區成立紀念日")
      ;; The page lists this as 中秋節翌日.
      ;; Its footnote says 中秋節翌日 fell on Sunday, so this is 中秋節.
      ((9 21 2002) "中秋節")
      ((10 1 2002) "國慶日")
      ((10 14 2002) "重陽節")
      ((12 25 2002) "聖誕節")
      ((12 26 2002) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/200204/12/0412101.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2003 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2003)
    '(((1 1 2003) "一月一日")
      ;; The page lists this as 農曆年初二.
      ;; Its footnote says 農曆年初二 fell on Sunday, so this is the day before 農曆年初一.
      ((1 31 2003) "農曆年初一的前一日")
      ((2 1 2003) "農曆年初一")
      ((2 3 2003) "農曆年初三")
      ((4 5 2003) "清明節")
      ((4 18 2003) "耶穌受難節")
      ((4 19 2003) "耶穌受難節翌日")
      ((4 21 2003) "復活節星期一")
      ((5 1 2003) "勞動節")
      ((5 8 2003) "佛誕")
      ((6 4 2003) "端午節")
      ((7 1 2003) "香港特別行政區成立紀念日")
      ((9 12 2003) "中秋節翌日")
      ((10 1 2003) "國慶日")
      ((10 4 2003) "重陽節")
      ((12 25 2003) "聖誕節")
      ((12 26 2003) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/200304/04/0404131.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2004 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2004)
    '(((1 1 2004) "一月一日")
      ((1 22 2004) "農曆年初一")
      ((1 23 2004) "農曆年初二")
      ((1 24 2004) "農曆年初三")
      ;; The page lists this as 清明節.
      ;; Its footnote says 清明節 fell on Sunday, so this is the day after.
      ((4 5 2004) "清明節翌日")
      ((4 9 2004) "耶穌受難節")
      ((4 10 2004) "耶穌受難節翌日")
      ((4 12 2004) "復活節星期一")
      ((5 1 2004) "勞動節")
      ((5 26 2004) "佛誕")
      ((6 22 2004) "端午節")
      ((7 1 2004) "香港特別行政區成立紀念日")
      ((9 29 2004) "中秋節翌日")
      ((10 1 2004) "國慶日")
      ((10 22 2004) "重陽節")
      ((12 25 2004) "聖誕節")
      ((12 27 2004) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/200504/15/04150114.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2006 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2006)
    ;; The page words this as 1月1日翌日.
    '(((1 2 2006) "一月一日翌日")
      ;; The page words this as 農曆年初一之前一日.
      ((1 28 2006) "農曆年初一的前一日")
      ((1 30 2006) "農曆年初二")
      ((1 31 2006) "農曆年初三")
      ((4 5 2006) "清明節")
      ((4 14 2006) "耶穌受難節")
      ((4 15 2006) "耶穌受難節翌日")
      ((4 17 2006) "復活節星期一")
      ((5 1 2006) "勞動節")
      ((5 5 2006) "佛誕")
      ((5 31 2006) "端午節")
      ((7 1 2006) "香港特別行政區成立紀念日")
      ((10 2 2006) "國慶日翌日")
      ((10 7 2006) "中秋節翌日")
      ((10 30 2006) "重陽節")
      ((12 25 2006) "聖誕節")
      ((12 26 2006) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/202005/15/P2020051500288.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2021 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2021)
    '(((1 1 2021) "一月一日")
      ((2 12 2021) "農曆年初一")
      ((2 13 2021) "農曆年初二")
      ((2 15 2021) "農曆年初四")
      ((4 2 2021) "耶穌受難節")
      ((4 3 2021) "耶穌受難節翌日")
      ((4 5 2021) "清明節翌日")
      ((4 6 2021) "復活節星期一翌日")
      ((5 1 2021) "勞動節")
      ((5 19 2021) "佛誕")
      ((6 14 2021) "端午節")
      ((7 1 2021) "香港特別行政區成立紀念日")
      ((9 22 2021) "中秋節翌日")
      ((10 1 2021) "國慶日")
      ((10 14 2021) "重陽節")
      ((12 25 2021) "聖誕節")
      ((12 27 2021) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/202305/25/P2023052500209.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2024 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2024)
    '(((1 1 2024) "一月一日")
      ((2 10 2024) "農曆年初一")
      ((2 12 2024) "農曆年初三")
      ((2 13 2024) "農曆年初四")
      ((3 29 2024) "耶穌受難節")
      ((3 30 2024) "耶穌受難節翌日")
      ((4 1 2024) "復活節星期一")
      ((4 4 2024) "清明節")
      ((5 1 2024) "勞動節")
      ((5 15 2024) "佛誕")
      ((6 10 2024) "端午節")
      ((7 1 2024) "香港特別行政區成立紀念日")
      ((9 18 2024) "中秋節翌日")
      ((10 1 2024) "國慶日")
      ((10 11 2024) "重陽節")
      ((12 25 2024) "聖誕節")
      ((12 26 2024) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/202405/03/P2024043000414.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2025 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2025)
    '(((1 1 2025) "一月一日")
      ((1 29 2025) "農曆年初一")
      ((1 30 2025) "農曆年初二")
      ((1 31 2025) "農曆年初三")
      ((4 4 2025) "清明節")
      ((4 18 2025) "耶穌受難節")
      ((4 19 2025) "耶穌受難節翌日")
      ((4 21 2025) "復活節星期一")
      ((5 1 2025) "勞動節")
      ((5 5 2025) "佛誕")
      ((5 31 2025) "端午節")
      ((7 1 2025) "香港特別行政區成立紀念日")
      ((10 1 2025) "國慶日")
      ((10 7 2025) "中秋節翌日")
      ((10 29 2025) "重陽節")
      ((12 25 2025) "聖誕節")
      ((12 26 2025) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/202505/16/P2025051300354.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2026 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2026)
    '(((1 1 2026) "一月一日")
      ((2 17 2026) "農曆年初一")
      ((2 18 2026) "農曆年初二")
      ((2 19 2026) "農曆年初三")
      ((4 3 2026) "耶穌受難節")
      ((4 4 2026) "耶穌受難節翌日")
      ((4 6 2026) "清明節翌日")
      ((4 7 2026) "復活節星期一翌日")
      ((5 1 2026) "勞動節")
      ((5 25 2026) "佛誕翌日")
      ((6 19 2026) "端午節")
      ((7 1 2026) "香港特別行政區成立紀念日")
      ((9 26 2026) "中秋節翌日")
      ((10 1 2026) "國慶日")
      ((10 19 2026) "重陽節翌日")
      ((12 25 2026) "聖誕節")
      ((12 26 2026) "聖誕節後第一個周日")))))

;; https://www.info.gov.hk/gia/general/202605/15/P2026051400304.htm
(ert-deftest my-holidays-tests-hong-kong-general-holidays-2027 ()
  (should
   (equal
    (my/holiday-bind (my/holiday-hong-kong my/holiday-hong-kong-general-holidays) :year 2027)
    '(((1 1 2027) "一月一日")
      ((2 6 2027) "農曆年初一")
      ((2 8 2027) "農曆年初三")
      ((2 9 2027) "農曆年初四")
      ((3 26 2027) "耶穌受難節")
      ((3 27 2027) "耶穌受難節翌日")
      ((3 29 2027) "復活節星期一")
      ((4 5 2027) "清明節")
      ((5 1 2027) "勞動節")
      ((5 13 2027) "佛誕")
      ((6 9 2027) "端午節")
      ((7 1 2027) "香港特別行政區成立紀念日")
      ((9 16 2027) "中秋節翌日")
      ((10 1 2027) "國慶日")
      ((10 8 2027) "重陽節")
      ((12 25 2027) "聖誕節")
      ((12 27 2027) "聖誕節後第一個周日")))))

;; 庚辰年正月初一
(ert-deftest my-holidays-tests-chinese-birth-and-death-birth-only ()
  ;; No anniversary before the birth.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000)) :year 1999)
    nil))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000)) :year 2000)
    '(((2 5 2000) "某人 農曆出世"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000)) :year 2001)
    '(((1 24 2001) "某人 1歲農曆生日"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000)) :year 2024)
    '(((2 10 2024) "某人 24歲農曆生日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-birth-in-leap-month ()
  ;; 癸卯年閏二月初一
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(3 22 2023)) :year 2023)
    '(((3 22 2023) "某人 農曆出世"))))
  ;; 甲辰年二月初一
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(3 22 2023)) :year 2024)
    '(((3 10 2024) "某人 1歲農曆生日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-birth-on-day-30 ()
  ;; 甲辰年二月三十
  ;; 乙巳年二月 does not have 三十, so 廿九 is used.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(4 8 2024)) :year 2025)
    '(((3 28 2025) "某人 1歲農曆生日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-birth-across-gregorian-years ()
  ;; 癸卯年臘月初一
  ;; 甲辰年臘月初一 is also in 2024, and 乙巳年臘月初一 is in 2026.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 11 2024)) :year 2024)
    '(((1 11 2024) "某人 農曆出世")
      ((12 31 2024) "某人 1歲農曆生日"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 11 2024)) :year 2025)
    nil))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 11 2024)) :year 2026)
    '(((1 19 2026) "某人 2歲農曆生日"))))
  ;; 癸卯年冬月廿一
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 2 2024)) :year 2024)
    '(((1 2 2024) "某人 農曆出世")
      ((12 21 2024) "某人 1歲農曆生日"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 2 2024)) :year 2025)
    nil))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(1 2 2024)) :year 2026)
    '(((1 9 2026) "某人 2歲農曆生日")
      ((12 29 2026) "某人 3歲農曆生日")))))

;; Born on 庚辰年正月初一, and died on 甲辰年二月三十.
(ert-deftest my-holidays-tests-chinese-birth-and-death ()
  ;; The year of the birth.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2000)
    '(((2 5 2000) "某人 農曆出世"))))
  ;; The year before the death.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2023)
    '(((1 22 2023) "某人 23歲農曆生日"))))
  ;; The year of the death.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2024)
    '(((2 10 2024) "某人 24歲農曆生日")
      ((4 8 2024) "某人 農曆逝世")
      ((4 14 2024) "某人 頭七")
      ((4 21 2024) "某人 二七")
      ((4 28 2024) "某人 三七")
      ((5 5 2024) "某人 四七")
      ((5 12 2024) "某人 五七")
      ((5 19 2024) "某人 六七")
      ((5 26 2024) "某人 尾七")
      ((7 16 2024) "某人 百日"))))
  ;; 乙巳年二月 does not have 三十, so 廿九 is used.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2025)
    '(((1 29 2025) "某人 25歲農曆生忌")
      ((3 28 2025) "某人 第1個農曆死忌"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2026)
    '(((2 17 2026) "某人 26歲農曆生忌")
      ((4 16 2026) "某人 第2個農曆死忌")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-visible-months ()
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2024 :month 4)
    '(((4 8 2024) "某人 農曆逝世")
      ((4 14 2024) "某人 頭七")
      ((4 21 2024) "某人 二七")
      ((4 28 2024) "某人 三七")
      ((5 5 2024) "某人 四七")
      ((5 12 2024) "某人 五七")
      ((5 19 2024) "某人 六七")
      ((5 26 2024) "某人 尾七"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024)) :year 2024 :month 7)
    '(((7 16 2024) "某人 百日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-death-before-birthday ()
  ;; Born on 庚辰年四月廿九.
  ;; The birthday in the year of the death is after the death, so it is 生忌.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(6 1 2000) :death '(4 8 2024)) :year 2024)
    '(((4 8 2024) "某人 農曆逝世")
      ((4 14 2024) "某人 頭七")
      ((4 21 2024) "某人 二七")
      ((4 28 2024) "某人 三七")
      ((5 5 2024) "某人 四七")
      ((5 12 2024) "某人 五七")
      ((5 19 2024) "某人 六七")
      ((5 26 2024) "某人 尾七")
      ((6 5 2024) "某人 24歲農曆生忌")
      ((7 16 2024) "某人 百日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-death-on-birthday ()
  ;; The birthday on the date of the death is still 生日.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(2 10 2024)) :year 2024)
    '(((2 10 2024) "某人 24歲農曆生日")
      ((2 10 2024) "某人 農曆逝世")
      ((2 16 2024) "某人 頭七")
      ((2 23 2024) "某人 二七")
      ((3 1 2024) "某人 三七")
      ((3 8 2024) "某人 四七")
      ((3 15 2024) "某人 五七")
      ((3 22 2024) "某人 六七")
      ((3 29 2024) "某人 尾七")
      ((5 19 2024) "某人 百日")))))

(ert-deftest my-holidays-tests-chinese-birth-and-death-death-in-december ()
  ;; 七 and 百日 continue into the next Gregorian year.
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(12 20 2023)) :year 2023)
    '(((1 22 2023) "某人 23歲農曆生日")
      ((12 20 2023) "某人 農曆逝世")
      ((12 26 2023) "某人 頭七"))))
  (should
   (equal
    (my/holiday-bind (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(12 20 2023)) :year 2024)
    '(((1 2 2024) "某人 二七")
      ((1 9 2024) "某人 三七")
      ((1 16 2024) "某人 四七")
      ((1 23 2024) "某人 五七")
      ((1 30 2024) "某人 六七")
      ((2 6 2024) "某人 尾七")
      ((2 10 2024) "某人 24歲農曆生忌")
      ((3 28 2024) "某人 百日")
      ((12 8 2024) "某人 第1個農曆死忌")))))

(ert-deftest my-holidays-tests-my/holiday-diary ()
  (with-no-warnings (defvar date))
  ;; No holiday on the date.
  (should
   (equal
    (let* ((date '(4 9 2024)))
      (my/holiday-diary (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024))))
    nil))
  (should
   (equal
    (let* ((date '(4 14 2024)))
      (my/holiday-diary (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(4 8 2024))))
    "某人 頭七"))
  ;; More than one holiday on the date.
  (should
   (equal
    (let* ((date '(2 10 2024)))
      (my/holiday-diary (my/holiday-chinese-birth-and-death "某人" :birth '(2 5 2000) :death '(2 10 2024))))
    "某人 24歲農曆生日; 某人 農曆逝世"))
  ;; `displayed-year' and `displayed-month' follow the date.
  (should
   (equal
    (let* ((date '(12 31 2024)))
      (my/holiday-diary (my/holiday-chinese-birth-and-death "某人" :birth '(1 11 2024))))
    "某人 1歲農曆生日"))
  (should
   (equal
    (let* ((date '(1 1 2024)))
      (my/holiday-diary (holiday-fixed 1 1 "一月一日")))
    "一月一日")))

(provide 'my-holidays-tests)
;;; my-holidays-tests.el ends here
