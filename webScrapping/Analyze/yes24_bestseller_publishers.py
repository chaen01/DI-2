"""
YES24 베스트셀러 목록을 Selenium으로 수집해서
베스트셀러를 가장 많이 낸 출판사를 집계하는 스크립트

필요 패키지:
    pip install selenium pandas
(Selenium 4.6 이상은 크롬 드라이버를 자동으로 내려받으므로 webdriver-manager가 필요 없습니다.)
"""

import time
from collections import Counter

import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# ── 설정 ────────────────────────────────────────────────
BASE_URL = "https://www.yes24.com/Product/Category/BestSeller"
CATEGORY = "001"     # 001 = 국내도서 전체
PAGE_SIZE = 24       # 한 페이지에 표시할 상품 수 (24, 40, 80 등)
MAX_PAGES = 10       # 몇 페이지까지 수집할지 (24 x 10 = 상위 240권)
DELAY = 1.5          # 페이지 사이 대기 시간(초) — 서버 부담을 줄이기 위해 유지 권장
TOP_N = 20           # 상위 몇 개 출판사를 출력할지


def create_driver(headless: bool = True) -> webdriver.Chrome:
    options = Options()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1920,1080")
    options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
    )
    return webdriver.Chrome(options=options)


def safe_text(parent, selector: str) -> str:
    """요소가 없으면 빈 문자열을 돌려준다."""
    try:
        return parent.find_element(By.CSS_SELECTOR, selector).text.strip()
    except NoSuchElementException:
        return ""


def scrape_page(driver, page: int) -> list[dict]:
    url = (f"{BASE_URL}?categoryNumber={CATEGORY}"
           f"&pageNumber={page}&pageSize={PAGE_SIZE}")
    driver.get(url)

    try:
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "#yesBestList > li"))
        )
    except TimeoutException:
        print(f"[경고] {page}페이지 로딩 실패 또는 목록 없음")
        return []

    items = driver.find_elements(By.CSS_SELECTOR, "#yesBestList > li")
    books = []
    for idx, item in enumerate(items, start=1):
        title = safe_text(item, ".gd_name")
        if not title:            # 광고 등 상품이 아닌 li는 건너뜀
            continue
        books.append({
            "rank": (page - 1) * PAGE_SIZE + idx,
            "title": title,
            "author": safe_text(item, ".info_auth"),
            "publisher": safe_text(item, ".info_pub"),
            "date": safe_text(item, ".info_date"),
        })
    return books


def main():
    driver = create_driver(headless=True)
    all_books = []
    try:
        for page in range(1, MAX_PAGES + 1):
            books = scrape_page(driver, page)
            if not books:
                break
            all_books.extend(books)
            print(f"{page}페이지: {len(books)}권 수집 (누적 {len(all_books)}권)")
            time.sleep(DELAY)
    finally:
        driver.quit()

    if not all_books:
        print("수집된 데이터가 없습니다. CSS 선택자가 바뀌었는지 확인하세요.")
        return

    # ── 원본 데이터 저장 ─────────────────────────────
    df = pd.DataFrame(all_books)
    df.to_csv("yes24_bestsellers.csv", index=False, encoding="utf-8-sig")

    # ── 출판사별 집계 ───────────────────────────────
    counter = Counter(p for p in df["publisher"] if p)
    pub_df = (pd.DataFrame(counter.most_common(), columns=["publisher", "count"]))

    # 순위 가중 점수: 1위 책일수록 높은 점수 (단순 권수 외 보조 지표)
    total = len(df)
    df["score"] = total - df["rank"] + 1
    score = df.groupby("publisher")["score"].sum()
    best_rank = df.groupby("publisher")["rank"].min()
    pub_df["weighted_score"] = pub_df["publisher"].map(score)
    pub_df["best_rank"] = pub_df["publisher"].map(best_rank)

    pub_df.to_csv("yes24_publisher_ranking.csv", index=False, encoding="utf-8-sig")

    print(f"\n=== 베스트셀러 상위 {total}권 중 출판사 TOP {TOP_N} ===")
    print(pub_df.head(TOP_N).to_string(index=False))


if __name__ == "__main__":
    main()
