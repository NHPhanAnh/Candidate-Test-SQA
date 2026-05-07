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
    driver.implicitly_wait(5)
    
    # --- TỰ ĐỘNG ĐĂNG NHẬP TRƯỚC KHI TEST ---
    driver.get("http://localhost:3000/auth/login")
    wait = WebDriverWait(driver, 120)
    try:
        # Chờ trang login load xong
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[type='text'], input[type='email']"))).send_keys("sqapananh2026")
        driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys("Test@12345")
        driver.find_element(By.CSS_SELECTOR, "button[type='submit'], .login-button").click()
        # CHỜ đến khi URL không còn là /auth/login nữa => login thành công
        wait.until(EC.url_changes("http://localhost:3000/auth/login"))
        time.sleep(2)
        print("Auto-login successful! URL:", driver.current_url)
    except Exception as e:
        print(f"Auto-login FAILED: {str(e)[:80]}")
    
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
    import tempfile
    import os
    
    test_email = f"auto_test_{int(time.time())}@gmail.com"
    
    # Sử dụng tempfile để tránh permission error
    with tempfile.NamedTemporaryFile(mode='w', suffix='.pdf', delete=False) as temp_file:
        temp_file.write("Fake PDF Content")
        cv_path = temp_file.name
    
    try:
        # === PRE-CLEANUP: Xóa record cũ từ tất cả bảng liên quan (FK order) ===
        def full_cleanup(cur):
            cur.execute("SELECT id FROM candidate_info_apply WHERE email LIKE 'auto_test_%'")
            old_apply_ids = [r[0] for r in cur.fetchall()]
            if old_apply_ids:
                # Lấy job_ad_candidate.id liên quan
                cur.execute("SELECT id FROM job_ad_candidate WHERE candidate_info_id = ANY(%s)", (old_apply_ids,))
                jac_ids = [r[0] for r in cur.fetchall()]
                if jac_ids:
                    cur.execute("DELETE FROM job_ad_process_candidate WHERE job_ad_candidate_id = ANY(%s)", (jac_ids,))
                cur.execute("DELETE FROM job_ad_candidate WHERE candidate_info_id = ANY(%s)", (old_apply_ids,))
                cur.execute("DELETE FROM candidate_info_apply WHERE id = ANY(%s)", (old_apply_ids,))
                print(f"\n[PRE-CLEANUP] Removed {len(old_apply_ids)} stale auto_test apply chains.")
            else:
                print("[PRE-CLEANUP] No stale records found.")

        try:
            conn_clean = psycopg2.connect(**DB_CONFIG)
            cur_clean = conn_clean.cursor()
            full_cleanup(cur_clean)
            conn_clean.commit()
            cur_clean.close()
            conn_clean.close()
        except Exception as e:
            print(f"[PRE-CLEANUP WARNING] {e}")

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
                # Đảm bảo quay lại đúng trang jobs
                driver.get("http://localhost:3000/jobs")
                # Click lại Ứng tuyển sau khi login
                apply_btns = wait.until(EC.presence_of_all_elements_located((By.XPATH, "//button[contains(., 'Ứng tuyển')]")))
                driver.execute_script("arguments[0].click();", apply_btns[0])

            # Bước đệm 2: Đợi modal mở (Step 1: chọn CV), rồi chọn "Tạo đơn ứng tuyển mới"
            try:
                # Đợi Step 1 của modal hiện ra - phải thấy option "Tạo đơn ứng tuyển mới"
                create_new_option = WebDriverWait(driver, 15).until(EC.presence_of_element_located(
                    (By.XPATH, "//*[contains(text(), 'Tạo đơn ứng tuyển mới')]")
                ))
                driver.execute_script("arguments[0].click();", create_new_option)
                time.sleep(1)  # Đợi Vue/React chuyển sang Step 2
            except Exception as e:
                print(f"[WARN] Could not find 'Tạo đơn ứng tuyển mới': {e}")

            # Bước Step 2: Đợi form hiện ra (input Tên đầy đủ phải visible & clickable)
            name_field = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "input[placeholder='Tên đầy đủ']")))
            time.sleep(1)  # Chờ thêm React render xong
            
            # Dùng JS để điền giá trị và trigger React's onChange event
            def js_fill(element, value):
                driver.execute_script(
                    "var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;"
                    "nativeInputValueSetter.call(arguments[0], arguments[1]);"
                    "arguments[0].dispatchEvent(new Event('input', { bubbles: true }));"
                    "arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
                    element, value
                )

            js_fill(name_field, "Auto Tester")
            email_field = driver.find_element(By.CSS_SELECTOR, "input[placeholder='Email']")
            js_fill(email_field, test_email)
            phone_field = driver.find_element(By.CSS_SELECTOR, "input[placeholder='SĐT']")
            js_fill(phone_field, "0987654321")
            
            # Upload file (Tìm input file ẩn)
            file_input = driver.find_element(By.CSS_SELECTOR, "input[type='file']")
            file_input.send_keys(cv_path)
            
            # Submit (Nút Xác nhận)
            submit_btn = wait.until(EC.element_to_be_clickable(
                (By.XPATH, "//button[contains(., 'Xác nhận')]")
            ))
            driver.execute_script("arguments[0].click();", submit_btn)
            
            print(f"\n[STEP] Applied for {test_email}. Waiting for DB...")
            time.sleep(10)  # Tăng thời gian chờ DB update

            # Kiểm tra console errors sau submit
            logs = driver.get_log('browser')
            for log in logs:
                if log['level'] == 'SEVERE':
                    print(f"[BROWSER ERROR] {log['message']}")

            # Database Check & Full Rollback (xóa đúng thứ tự FK)
            conn = psycopg2.connect(**DB_CONFIG)
            cur = conn.cursor()
            cur.execute("SELECT id FROM candidate_info_apply WHERE email = %s", (test_email,))
            record = cur.fetchone()
            
            if record:
                apply_id = record[0]
                print(f"[PASSED] DB Check: Found record ID={apply_id}")
                # Lấy job_ad_candidate.id liên quan
                cur.execute("SELECT id FROM job_ad_candidate WHERE candidate_info_id = %s", (apply_id,))
                jac_rows = cur.fetchall()
                jac_ids = [r[0] for r in jac_rows]
                if jac_ids:
                    cur.execute("DELETE FROM job_ad_process_candidate WHERE job_ad_candidate_id = ANY(%s)", (jac_ids,))
                cur.execute("DELETE FROM job_ad_candidate WHERE candidate_info_id = %s", (apply_id,))
                cur.execute("DELETE FROM candidate_info_apply WHERE id = %s", (apply_id,))
                conn.commit()
                print(f"[ROLLBACK SUCCESS] Full chain deleted for apply_id={apply_id}.")
            else:
                # Debug thêm: kiểm tra xem có record nào được tạo không
                cur.execute("SELECT COUNT(*) FROM candidate_info_apply WHERE email LIKE 'auto_test_%'")
                count = cur.fetchone()[0]
                print(f"[DEBUG] Total auto_test records in DB: {count}")
                
                # Kiểm tra network requests để xem API call có thành công không
                network_logs = driver.execute_script("""
                    var performance = window.performance || {};
                    var network = performance.getEntriesByType ? performance.getEntriesByType('resource') : [];
                    return network.filter(function(entry) {
                        return entry.name.includes('/apply') && entry.responseEnd > 0;
                    }).map(function(entry) {
                        return {url: entry.name, status: entry.responseEnd ? 'completed' : 'pending'};
                    });
                """)
                print(f"[DEBUG] Network requests to /apply: {network_logs}")
                
                pytest.fail(f"TC_SYS_002 FAIL: Record not found for {test_email}")
                
            cur.close()
            conn.close()
        except Exception as e:
            pytest.fail(f"TC_SYS_002 FAIL: {str(e)}")
    finally:
        # Đảm bảo file được xóa ngay cả khi lỗi
        try:
            os.unlink(cv_path)
        except:
            pass

def test_TC_SYS_003_PrivateLinkAccess(driver):
    """
    ID: TC_SYS_003 | Title: UI Private Link Access with Secret Key
    Steps: 1. Access private link with keyCodeInternal | 2. Check access granted
    Expected: Private job detail accessed successfully.
    """
    driver.get("http://localhost:3000/job-ad/detail/999?keyCodeInternal=SECRET123")
    wait = WebDriverWait(driver, 180)
    try:
        wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        assert "keyCodeInternal=SECRET123" in driver.current_url
        print("\n[PASSED] TC_SYS_003: Private link accessed.")
    except Exception as e:
        pytest.fail(f"TC_SYS_003 FAIL: {str(e)}")

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
