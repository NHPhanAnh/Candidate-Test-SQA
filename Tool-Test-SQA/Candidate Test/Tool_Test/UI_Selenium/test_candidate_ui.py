import pytest
import psycopg2
import time
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Cấu hình Database (PostgreSQL)
DB_CONFIG = {
    "host": "localhost",
    "port": "5433",
    "database": "cvconnect_core_service",
    "user": "postgres",
    "password": "123456"
}

@pytest.fixture
def driver():
    options = webdriver.ChromeOptions()
    options.add_argument('--start-maximized')
    driver = webdriver.Chrome(options=options)
    driver.implicitly_wait(10)
    
    # --- TỰ ĐỘNG ĐĂNG NHẬP TRƯỚC KHI TEST (sqapananh2026 / Test@12345) ---
    driver.get("http://localhost:3000/auth/login")
    wait = WebDriverWait(driver, 15)
    try:
        if "login" in driver.current_url:
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[type='text'], input[placeholder='Email/Username']"))).send_keys("sqapananh2026")
            driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys("Test@12345")
            login_btn = driver.find_element(By.CSS_SELECTOR, "button[type='submit'], .login-button")
            driver.execute_script("arguments[0].click();", login_btn)
            time.sleep(2)
            print("Auto-login successful!")
        else:
            print("Already logged in or redirected!")
    except Exception as e:
        print(f"Auto-login warning: {str(e)}")
    
    yield driver
    driver.quit()

def test_TC_SYS_001_FilterJobAds(driver):
    """
    ID: TC_SYS_001 | Title: UI Filter Job Ads by Keyword and Location
    Steps: 1. Go to /jobs with params | 2. Wait for jobs-result
    Expected: Page displays job results matching criteria.
    """
    driver.get("http://localhost:3000/jobs?keyword=Java")
    wait = WebDriverWait(driver, 180)
    try:
        # Đợi nút Ứng tuyển hiện ra chứng tỏ dữ liệu đã load
        wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'Ứng tuyển')]")))
        print("\n[PASSED] TC_SYS_001: Jobs loaded successfully.")
    except Exception as e:
        pytest.fail(f"TC_SYS_001 FAIL: {str(e)}")

def test_TC_SYS_002_ApplyCV_Full_Flow_With_Rollback(driver):
    """
    ID: TC_SYS_002 | Title: UI Apply CV with Database Check & Rollback
    Steps: 1. Fill form on UI | 2. Submit | 3. Verify in DB | 4. Delete record
    Expected: Record is created then cleaned up from DB.
    """
    test_email = f"auto_test_{int(time.time())}@gmail.com"
    cv_path = os.path.abspath("test_cv.pdf")
    with open(cv_path, "w") as f: f.write("Fake PDF Content")

    driver.get("http://localhost:3000/jobs")
    wait = WebDriverWait(driver, 60)
    
    try:
        apply_btns = wait.until(EC.presence_of_all_elements_located(
            (By.XPATH, "//button[contains(., 'Ứng tuyển')]")
        ))
        driver.execute_script("arguments[0].click();", apply_btns[0])
        
        # Bước đệm 1: Nếu chưa login, nó có thể chuyển hướng hoặc mở modal đăng nhập
        time.sleep(2)
        if "login" in driver.current_url or len(driver.find_elements(By.CSS_SELECTOR, "input[type='password']")) > 0:
            print("\n[INFO] Login required mid-test. Logging in...")
            driver.find_element(By.CSS_SELECTOR, "input[type='text']").send_keys("sqapananh2026")
            driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys("Test@12345")
            driver.find_element(By.CSS_SELECTOR, ".login-button").click()
            time.sleep(3)
            # Click lại Ứng tuyển sau khi login
            apply_btns = wait.until(EC.presence_of_all_elements_located((By.XPATH, "//button[contains(., 'Ứng tuyển')]")))
            driver.execute_script("arguments[0].click();", apply_btns[0])

        # Bước đệm 2: Chọn "Tạo đơn ứng tuyển mới" nếu có
        try:
            create_new_btn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(
                (By.XPATH, "//*[contains(text(), 'Tạo đơn ứng tuyển mới')]")
            ))
            create_new_btn.click()
        except:
            pass

        # Đợi form hiện ra (dựa vào placeholder)
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[placeholder='Tên đầy đủ']")))

        # Điền form bằng placeholder
        driver.find_element(By.CSS_SELECTOR, "input[placeholder='Tên đầy đủ']").send_keys("Auto Tester")
        driver.find_element(By.CSS_SELECTOR, "input[placeholder='Email']").send_keys(test_email)
        driver.find_element(By.CSS_SELECTOR, "input[placeholder='SĐT']").send_keys("0987654321")
        
        # Upload file (Tìm input file ẩn)
        file_input = driver.find_element(By.CSS_SELECTOR, "input[type='file']")
        file_input.send_keys(cv_path)
        
        # Submit (Nút Xác nhận)
        submit_btn = wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(., 'Xác nhận')]")
        ))
        driver.execute_script("arguments[0].click();", submit_btn)
        
        print(f"\n[STEP] Applied for {test_email}. Waiting for DB...")
        time.sleep(5) 

        # Database Check & Rollback
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("SELECT id FROM candidate_info_apply WHERE email = %s", (test_email,))
        record = cur.fetchone()
        
        if record:
            print(f"[PASSED] DB Check: Found record ID={record[0]}")
            cur.execute("DELETE FROM candidate_info_apply WHERE id = %s", (record[0],))
            conn.commit()
            print(f"[ROLLBACK SUCCESS] Deleted test record {record[0]}.")
        else:
            pytest.fail(f"TC_SYS_002 FAIL: Record not found for {test_email}")
            
        cur.close()
        conn.close()
    finally:
        if os.path.exists(cv_path): os.remove(cv_path)

def test_TC_SYS_003_PrivateJobLink(driver):
    """
    ID: TC_SYS_003 | Title: Access Private Job via Secret Link
    Steps: 1. Access link with keyCodeInternal | 2. Verify page load
    Expected: Page loads and URL contains the secret key.
    --- REPORT TEMPLATE IF FAIL ---
    - Main error point: Security filter blocks the secret key.
    - Specifically: Redirect to 404 or access denied.
    - Location: SecurityConfig.java
    """
    driver.get("http://localhost:3000/job-ad/detail/999?keyCodeInternal=SECRET123")
    wait = WebDriverWait(driver, 180)
    try:
        wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        assert "keyCodeInternal=SECRET123" in driver.current_url
        print("\n[PASSED] TC_SYS_003: Private link accessed.")
    except Exception:
        pytest.fail("TC_SYS_003 FAIL")
    finally:
        try:
            if os.path.exists("test_cv.pdf"): os.remove("test_cv.pdf")
        except:
            pass

def test_TC_SYS_004_ViewJobDetail(driver):
    """
    ID: TC_SYS_004 | Title: UI View Job Detail Panel
    Steps: 1. Click preview/detail button | 2. Check detail panel
    Expected: Detail panel displayed.
    """
    driver.get("http://localhost:3000/jobs")
    wait = WebDriverWait(driver, 180)
    try:
        # Tìm nút Xem nhanh hoặc Chi tiết
        btns = wait.until(EC.presence_of_all_elements_located(
            (By.XPATH, "//button[contains(., 'Xem') or contains(., 'Chi tiết')]")
        ))
        driver.execute_script("arguments[0].click();", btns[0])
        # Đợi panel hiện ra (thường có class chứa 'detail')
        wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(@class, 'detail')]")))
        print("\n[PASSED] TC_SYS_004: Detail panel displayed.")
    except Exception as e:
        pytest.fail(f"TC_SYS_004 FAIL: {str(e)}")
