import sqlite3
from flask import Flask, render_template, g, request, redirect, url_for, flash

DATABASE = 'data.db'
app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route("/")
def index():
    cur = get_db().execute('SELECT * FROM links')
    rows = cur.fetchall()
    cur.close()
    return render_template("index.html", rows=rows)

@app.route("/manage")
def manage():
    cur = get_db().execute('SELECT * FROM links')
    rows = cur.fetchall()
    cur.close()
    return render_template("manage.html", rows=rows)

@app.route("/add", methods=['POST'])
def add():
    name = request.form['name']
    url_val = request.form['url']
    db = get_db()
    db.execute('INSERT INTO links (name, url) VALUES (?, ?)', (name, url_val))
    db.commit()
    flash("新增节目成功！")
    return redirect(url_for('manage'))

@app.route("/delete/<int:id>")
def delete(id):
    db = get_db()
    db.execute('DELETE FROM links WHERE id=?', (id,))
    db.commit()
    flash("删除节目成功！")
    return redirect(url_for('manage'))

@app.route("/edit/", methods=['POST'])
def edit():
    db = get_db()
    if request.method == 'POST':
        id = request.form['id']
        name = request.form['name']
        url_val = request.form['url']
        cursor = db.execute('UPDATE links SET name=?, url=? WHERE id=?', (name, url_val, id))
        db.commit()
        if cursor.rowcount == 0:
            flash("节目不存在或未更新！")
        else:
            flash("更新节目成功！")
    return redirect(url_for('manage'))


if __name__ == "__main__":
    app.run()
