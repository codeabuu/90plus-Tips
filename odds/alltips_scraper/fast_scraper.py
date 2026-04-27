# alltips_scraper/fast_scraper.py
import requests
from bs4 import BeautifulSoup
import cloudscraper
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Optional
import time
from functools import lru_cache


class FastScraper:
    """
    Super fast scraper that:
    1. Uses a single session for all requests
    2. Parallelizes requests across different endpoints
    3. Caches responses to avoid重复 requests
    """
    
    def __init__(self, max_workers: int = 5):
        self.session = cloudscraper.create_scraper()
        self.max_workers = max_workers
        self.cache = {}
        
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Fetch a single page with caching"""
        if url in self.cache:
            return self.cache[url]
        
        try:
            response = self.session.get(url, timeout=10)
            if response:
                soup = BeautifulSoup(response.content, 'html.parser')
                self.cache[url] = soup
                return soup
        except Exception as e:
            print(f"Error fetching {url}: {e}")
        return None
    
    def fetch_all_pages(self, urls: List[str]) -> Dict[str, BeautifulSoup]:
        """Fetch multiple pages in parallel"""
        results = {}
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_url = {executor.submit(self.fetch_page, url): url for url in urls}
            
            for future in as_completed(future_to_url):
                url = future_to_url[future]
                try:
                    soup = future.result()
                    if soup:
                        results[url] = soup
                except Exception as e:
                    print(f"Error processing {url}: {e}")
        
        return results


# Create a singleton instance
_fast_scraper = None

def get_fast_scraper():
    global _fast_scraper
    if _fast_scraper is None:
        _fast_scraper = FastScraper()
    return _fast_scraper