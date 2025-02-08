import sqlite3

conn = sqlite3.connect('data.db')
c = conn.cursor()
c.execute('''
  CREATE TABLE IF NOT EXISTS links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    url TEXT NOT NULL
  )
''')

conn.commit()
conn.close()
