use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Debug, Serialize, Deserialize)]
pub struct Link {
    pub id: i32,
    pub name: String,
    pub url: String,
}

/// 获取数据库连接
fn get_db_connection() -> Result<Connection> {
    let db_path = Path::new("data.db");
    let conn = Connection::open(db_path)?;
    
    // 确保表存在
    conn.execute(
        "CREATE TABLE IF NOT EXISTS links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            url TEXT NOT NULL
        )",
        [],
    )?;
    
    Ok(conn)
}

/// 获取所有电视直播链接
#[tauri::command]
pub fn get_links() -> Result<Vec<Link>, String> {
    let conn = get_db_connection().map_err(|e| e.to_string())?;
    
    let mut stmt = conn.prepare("SELECT id, name, url FROM links")
        .map_err(|e| e.to_string())?;
    
    let links = stmt.query_map([], |row| {
        Ok(Link {
            id: row.get(0)?,
            name: row.get(1)?,
            url: row.get(2)?,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|link| link.ok())
    .collect();
    
    Ok(links)
}

/// 添加新的电视直播链接
#[tauri::command]
pub fn add_link(name: String, url: String) -> Result<Link, String> {
    let conn = get_db_connection().map_err(|e| e.to_string())?;
    
    conn.execute(
        "INSERT INTO links (name, url) VALUES (?1, ?2)",
        (&name, &url),
    )
    .map_err(|e| e.to_string())?;
    
    let id = conn.last_insert_rowid() as i32;
    
    Ok(Link {
        id,
        name,
        url,
    })
}

/// 更新现有电视直播链接
#[tauri::command]
pub fn update_link(id: i32, name: String, url: String) -> Result<Link, String> {
    let conn = get_db_connection().map_err(|e| e.to_string())?;
    
    let result = conn.execute(
        "UPDATE links SET name = ?1, url = ?2 WHERE id = ?3",
        (&name, &url, &id),
    )
    .map_err(|e| e.to_string())?;
    
    if result == 0 {
        return Err("链接不存在或未更新".to_string());
    }
    
    Ok(Link {
        id,
        name,
        url,
    })
}

/// 删除电视直播链接
#[tauri::command]
pub fn delete_link(id: i32) -> Result<bool, String> {
    let conn = get_db_connection().map_err(|e| e.to_string())?;
    
    let result = conn.execute(
        "DELETE FROM links WHERE id = ?1",
        [&id],
    )
    .map_err(|e| e.to_string())?;
    
    Ok(result > 0)
}
