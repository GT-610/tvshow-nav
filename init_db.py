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
# 示例数据
c.execute("INSERT INTO links (name, url) VALUES ('电视台1', 'http://example.com/live1')")
c.execute("INSERT INTO links (name, url) VALUES ('电视台2', 'http://example.com/live2')")
conn.commit()
conn.close()
