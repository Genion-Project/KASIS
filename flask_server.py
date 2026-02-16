from flask import Flask, request, jsonify
import sqlite3
import datetime
import bcrypt

app = Flask(__name__)
DB_NAME = "database.db"

def generate_otp():
    import random
    return str(random.randint(100000, 999999))

def send_otp_email(email, otp):
    print(f"Sending OTP {otp} to {email}")

@app.route("/forgot-password/request", methods=["POST"])
def forgot_password_request():
    email = request.json.get("email")

    conn = sqlite3.connect(DB_NAME, timeout=10)
    conn.execute("PRAGMA journal_mode=WAL;")
    c = conn.cursor()

    # cek user, hanya user yang sudah terverifikasi yang bisa reset password
    c.execute("""
        SELECT id FROM users
        WHERE email=? AND registration_status='active'
    """, (email,))
    if not c.fetchone():
        conn.close()
        return jsonify({"error": "Email tidak terdaftar atau belum aktif"}), 404

    # --- Rate Limit Check ---
    c.execute("""
        SELECT created_at FROM otp
        WHERE email=? AND purpose='forgot_password'
        ORDER BY created_at DESC LIMIT 1
    """, (email,))
    last_otp = c.fetchone()
    
    if last_otp:
        # Asumsi created_at disimpan sebagai string ISO atau timestamp default sqlite
        # Kita perlu pastikan table OTP punya kolom created_at DEFAULT CURRENT_TIMESTAMP
        # Jika format string: 
        try:
            last_time = datetime.datetime.fromisoformat(last_otp[0]) if 'T' in last_otp[0] else datetime.datetime.strptime(last_otp[0], "%Y-%m-%d %H:%M:%S")
            if (datetime.datetime.now() - last_time).total_seconds() < 60:
                conn.close()
                return jsonify({"error": "Tunggu 1 menit sebelum meminta OTP lagi"}), 429
        except Exception as e:
            # Fallback jika parsing gagal (misal format beda), anggap boleh kirim
            print(f"Date parse error: {e}")
            pass
    # ------------------------

    # hapus OTP lama forgot_password
    # UPDATE: Jangan hapus semua, cukup insert baru. Cleaner job bisa hapus yg lama.
    # Tapi kalau mau keep logic lama (delete) juga oke, asalkan rate limit di atas sudah jalan.
    # Namun untuk rate limit bekerja efektif dengan query di atas, kita JANGAN delete record terakhir sebelum check waktu.
    # Jadi step DELETE dipindah atau dihapus (biar history ada).
    # KEPUTUSAN: User minta "pencegahan proses tidak berhenti", jadi insert baru saja.
    # Tapi agar tidak nyampah, hapus yg sudah expired/lama kecuali yg paling baru (untuk history rate limit).
    # Simplifikasi: Hapus yang > 5 menit lalu misal. Atau biarkan saja delete, TAPI
    # kalau di delete, kita gak bisa cek last_otp dong? 
    # JADI: Logic DELETE harus diubah. Kita delete yang *selain* yang baru dibuat, tapi nanti ribet.
    # SOLUSI: Jangan delete *semua*. Biarkan insert, nanti verify ambil yg terbaru.
    
    # Hapus OTP yang sudah expired saja untuk bersih-bersih
    c.execute("DELETE FROM otp WHERE email=? AND purpose='forgot_password' AND expired_at < ?", (email, datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))

    # generate OTP baru
    otp = generate_otp()
    now = datetime.datetime.now()
    created_at = now.strftime("%Y-%m-%d %H:%M:%S")
    expired_at = (now + datetime.timedelta(minutes=10)).strftime("%Y-%m-%d %H:%M:%S")

    c.execute("""
        INSERT INTO otp (email, otp_code, created_at, expired_at, purpose)
        VALUES (?, ?, ?, ?, 'forgot_password')
    """, (email, otp, created_at, expired_at))

    conn.commit()
    conn.close()

    send_otp_email(email, otp)

    return jsonify({
        "message": "OTP reset password dikirim",
        "expired_in": "10 menit"
    })


@app.route("/request-otp", methods=["POST"])
def request_otp():
    data = request.json
    email = data["email"]
    nama = data["nama"]
    no_telp = data["no_telp"]

    conn = sqlite3.connect(DB_NAME, timeout=10)
    c = conn.cursor()

    # Cek apakah email sudah ada
    c.execute("""
        SELECT id, registration_status FROM users WHERE email=?
    """, (email,))
    user = c.fetchone()

    if user:
        status = user[1]
        if status == "active":
            conn.close()
            return jsonify({"error": "Email sudah terdaftar & terverifikasi"}), 400
        # jika pending_verification / verified, kita bisa resend OTP (Proses Continuity)
    else:
        # insert user baru dengan status pending_verification
        c.execute("""
            INSERT INTO users (email, nama, no_telp, password, jabatan, registration_status)
            VALUES (?, ?, ?, ?, 'Anggota', 'pending_verification')
        """, (email, nama, no_telp, "__OTP_PENDING__"))

    # --- Rate Limit Check ---
    # Cek OTP terakhir untuk registrasi
    c.execute("""
        SELECT created_at FROM otp
        WHERE email=? AND (purpose IS NULL OR purpose='registration') 
        ORDER BY created_at DESC LIMIT 1
    """, (email,))
    # Catatan: purpose mungkin NULL di data lama, jadi handle itu.
    
    last_otp = c.fetchone()
    if last_otp:
        try:
            last_ts_str = last_otp[0]
            # Handle format ISO atau spasi
            if 'T' in last_ts_str:
                last_time = datetime.datetime.fromisoformat(last_ts_str)
            else:
                last_time = datetime.datetime.strptime(last_ts_str, "%Y-%m-%d %H:%M:%S")
            
            if (datetime.datetime.now() - last_time).total_seconds() < 60:
                conn.close()
                return jsonify({"error": "Tunggu 1 menit sebelum meminta OTP lagi"}), 429
        except Exception:
            pass
    # ------------------------

    # Clean up old OTPs instead of deleting all
    c.execute("DELETE FROM otp WHERE email=? AND expired_at < ?", (email, datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))

    otp = generate_otp()
    now = datetime.datetime.now()
    created_at = now.strftime("%Y-%m-%d %H:%M:%S")
    expired_at = (now + datetime.timedelta(minutes=10)).strftime("%Y-%m-%d %H:%M:%S")

    # Set purpose='registration' biar rapi
    c.execute("""
        INSERT INTO otp (email, otp_code, created_at, expired_at, purpose)
        VALUES (?, ?, ?, ?, 'registration')
    """, (email, otp, created_at, expired_at))

    conn.commit()
    conn.close()

    send_otp_email(email, otp)

    return jsonify({"message": "OTP berhasil dikirim", "expired_in": "10 menit"})


@app.route("/verify-otp", methods=["POST"])
def verify_otp():
    data = request.json
    email = data["email"]
    otp_input = data["otp"]

    conn = sqlite3.connect(DB_NAME, timeout=10)
    conn.execute("PRAGMA journal_mode=WAL;")
    c = conn.cursor()

    try:
        c.execute("""
            SELECT id, otp_code, expired_at
            FROM otp
            WHERE email=? AND is_used=0
            ORDER BY created_at DESC
            LIMIT 1
        """, (email,))
        row = c.fetchone()

        if not row:
            return jsonify({"error": "OTP tidak ditemukan"}), 400

        otp_id, otp_code, expired_at = row

        if otp_input != otp_code:
            return jsonify({"error": "OTP salah"}), 400

        if datetime.datetime.now() > datetime.datetime.fromisoformat(expired_at):
            return jsonify({"error": "OTP kadaluarsa"}), 400

        # Update user status menjadi verified
        c.execute("""
            UPDATE users
            SET registration_status='verified'
            WHERE email=?
        """, (email,))

        # Tandai OTP sudah digunakan
        c.execute("UPDATE otp SET is_used=1 WHERE id=?", (otp_id,))

        conn.commit()
        return jsonify({"message": "Verifikasi berhasil"})
    finally:
        conn.close()


@app.route("/set-password", methods=["POST"])
def set_password():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email dan password wajib diisi"}), 400

    if len(password) < 6:
        return jsonify({"error": "Password minimal 6 karakter"}), 400

    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()

    # cek user
    c.execute("""
        SELECT id, registration_status FROM users WHERE email=?
    """, (email,))
    user = c.fetchone()

    if not user:
        conn.close()
        return jsonify({"error": "User tidak ditemukan"}), 404

    if user[1] != "verified":
        conn.close()
        return jsonify({"error": "User belum verifikasi OTP atau sudah aktif"}), 403

    # hash password
    hashed = bcrypt.generate_password_hash(password).decode("utf-8")

    # set password dan ubah status user menjadi active
    c.execute("""
        UPDATE users
        SET password=?, registration_status='active', jabatan='Anggota'
        WHERE email=?
    """, (hashed, email))

    conn.commit()
    conn.close()

    return jsonify({"message": "Password berhasil disimpan", "jabatan": "Anggota"})
