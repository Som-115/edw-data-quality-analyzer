from db import get_connection

try:
    conn = get_connection()

    print("✅ Successfully connected to Fabric SQL Database!")

    cursor = conn.cursor()
    cursor.execute("SELECT DB_NAME()")

    database_name = cursor.fetchone()[0]

    print("Connected database:", database_name)

    cursor.close()
    conn.close()

except Exception as e:
    print("❌ Connection failed")
    print(e)