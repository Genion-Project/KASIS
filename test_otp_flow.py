import unittest
import json
import sqlite3
import os
import time
import datetime
from flask_server import app, DB_NAME

class TestOTPFlow(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        
        # Setup temporary DB
        if os.path.exists(DB_NAME):
            os.remove(DB_NAME)
            
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE,
                nama TEXT,
                no_telp TEXT,
                password TEXT,
                jabatan TEXT,
                registration_status TEXT
            )
        ''')
        c.execute('''
            CREATE TABLE IF NOT EXISTS otp (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT,
                otp_code TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                expired_at DATETIME,
                purpose TEXT,
                is_used INTEGER DEFAULT 0
            )
        ''')
        
        # Seed user for forgot password test
        c.execute("""
            INSERT INTO users (email, nama, no_telp, password, registration_status)
            VALUES ('test@example.com', 'Test User', '08123456789', 'hashedpass', 'active')
        """)
        conn.commit()
        conn.close()

    def tearDown(self):
        if os.path.exists(DB_NAME):
            os.remove(DB_NAME)

    def test_rate_limit_forgot_password(self):
        print("\nTesting Rate Limit: Forgot Password")
        # 1. Request OTP (Success)
        resp1 = self.app.post('/forgot-password/request', json={'email': 'test@example.com'})
        self.assertEqual(resp1.status_code, 200)
        
        # 2. Request again immediately (Fail)
        resp2 = self.app.post('/forgot-password/request', json={'email': 'test@example.com'})
        self.assertEqual(resp2.status_code, 429)
        print("Immedate retry: Passed (Blocked)")

        # To simulate waiting, we'd need to mock datetime or sleep. 
        # For this test, verifying the block is enough.

    def test_process_continuity(self):
        print("\nTesting Process Continuity: Registration")
        email = 'new@example.com'
        data = {'email': email, 'nama': 'New User', 'no_telp': '0812'}
        
        # 1. First Request
        resp1 = self.app.post('/request-otp', json=data)
        self.assertEqual(resp1.status_code, 200)
        
        # 2. Validate DB status
        conn = sqlite3.connect(DB_NAME)
        row = conn.execute("SELECT registration_status FROM users WHERE email=?", (email,)).fetchone()
        self.assertEqual(row[0], 'pending_verification')
        
        # 3. Simulate user drops off and tries again (Fail due to rate limit first)
        resp_limit = self.app.post('/request-otp', json=data)
        self.assertEqual(resp_limit.status_code, 429)
        
        # 4. Hack DB to make last OTP old
        old_time = (datetime.datetime.now() - datetime.timedelta(minutes=2)).strftime("%Y-%m-%d %H:%M:%S")
        conn.execute("UPDATE otp SET created_at=? WHERE email=?", (old_time, email))
        conn.commit()
        
        # 5. Retry Request (Should succeed and NOT error "email already exists")
        resp_retry = self.app.post('/request-otp', json=data)
        self.assertEqual(resp_retry.status_code, 200, f"Retry failed: {resp_retry.json}")
        print("Retry after drop-off: Passed")
        
        conn.close()

if __name__ == '__main__':
    unittest.main()
