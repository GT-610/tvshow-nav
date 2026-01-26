use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::path::Path;
use std::process::Command;
use std::rc::Rc;
use slint::{Model, SharedString, VecModel};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Link {
    pub id: i32,
    pub name: String,
    pub url: String,
}

fn get_db_connection() -> Result<Connection> {
    let db_path = Path::new("data.db");
    let conn = Connection::open(db_path)?;

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

pub fn delete_link(id: i32) -> Result<bool, String> {
    let conn = get_db_connection().map_err(|e| e.to_string())?;

    let result = conn.execute(
        "DELETE FROM links WHERE id = ?1",
        [&id],
    )
    .map_err(|e| e.to_string())?;

    Ok(result > 0)
}

fn open_url(url: &str) {
    #[cfg(target_os = "windows")]
    {
        let _ = Command::new("cmd")
            .args(&["/c", "start", url])
            .spawn();
    }
    #[cfg(target_os = "macos")]
    {
        let _ = Command::new("open").arg(url).spawn();
    }
    #[cfg(target_os = "linux")]
    {
        let _ = Command::new("xdg-open").arg(url).spawn();
    }
}

slint::slint!(export { MainWindow } from "ui/main.slint";);

fn main() {
    let main_window = MainWindow::new().unwrap();

    let links_model: Rc<RefCell<VecModel<LinkItem>>> = Rc::new(RefCell::new(VecModel::default()));

    let update_links_model = {
        let links_model = links_model.clone();
        move |window: &MainWindow| {
            let links = get_links().unwrap_or_default();
            let model = links_model.borrow_mut();
            model.clear();
            
            for link in links {
                model.push(LinkItem {
                    id: link.id,
                    name: SharedString::from(link.name.clone()),
                    url: SharedString::from(link.url.clone()),
                });
            }
            
            let model_copy: Vec<LinkItem> = model.iter().collect();
            let model_rc = Rc::new(VecModel::from(model_copy));
            window.set_links(model_rc.into());
        }
    };

    update_links_model(&main_window);

    {
        let weak_window = main_window.as_weak();
        let update_fn = update_links_model.clone();
        main_window.on_add_link(move || {
            let window = weak_window.unwrap();
            let name = window.get_edit_name().to_string();
            let url = window.get_edit_url().to_string();

            if name.trim().is_empty() || url.trim().is_empty() {
                window.set_message_text(SharedString::from("名称和链接不能为空"));
                window.set_message_type(SharedString::from("error"));
                return;
            }

            match add_link(name.clone(), url.clone()) {
                Ok(_) => {
                    update_fn(&window);
                    window.set_show_add_dialog(false);
                    window.set_message_text(SharedString::from("新增节目成功！"));
                    window.set_message_type(SharedString::from("success"));
                }
                Err(e) => {
                    window.set_message_text(SharedString::from(format!("新增节目失败: {}", e)));
                    window.set_message_type(SharedString::from("error"));
                }
            }
        });
    }

    {
        let weak_window = main_window.as_weak();
        let update_fn = update_links_model.clone();
        main_window.on_update_link(move |id, name, url| {
            let window = weak_window.unwrap();
            let name_str = name.to_string();
            let url_str = url.to_string();

            if name_str.trim().is_empty() || url_str.trim().is_empty() {
                window.set_message_text(SharedString::from("名称和链接不能为空"));
                window.set_message_type(SharedString::from("error"));
                return;
            }

            match update_link(id, name_str.clone(), url_str.clone()) {
                Ok(_) => {
                    update_fn(&window);
                    window.set_show_edit_dialog(false);
                    window.set_message_text(SharedString::from("更新节目成功！"));
                    window.set_message_type(SharedString::from("success"));
                }
                Err(e) => {
                    window.set_message_text(SharedString::from(format!("更新节目失败: {}", e)));
                    window.set_message_type(SharedString::from("error"));
                }
            }
        });
    }

    {
        let weak_window = main_window.as_weak();
        let update_fn = update_links_model.clone();
        main_window.on_delete_link(move |id| {
            let window = weak_window.unwrap();

            match delete_link(id) {
                Ok(_) => {
                    update_fn(&window);
                    window.set_show_delete_dialog(false);
                    window.set_message_text(SharedString::from("删除节目成功！"));
                    window.set_message_type(SharedString::from("success"));
                }
                Err(e) => {
                    window.set_message_text(SharedString::from(format!("删除节目失败: {}", e)));
                    window.set_message_type(SharedString::from("error"));
                }
            }
        });
    }

    {
        let weak_window = main_window.as_weak();
        main_window.on_show_message(move |text, type_| {
            let window = weak_window.unwrap();
            window.set_message_text(text);
            window.set_message_type(type_);
        });
    }

    {
        main_window.on_open_link(move |url| {
            let url_str = url.to_string();
            open_url(&url_str);
        });
    }

    {
        let weak_window = main_window.as_weak();
        main_window.on_edit_link(move |id| {
            let window = weak_window.unwrap();
            let links = get_links().unwrap_or_default();
            for link in links {
                if link.id == id {
                    window.set_edit_id(link.id);
                    window.set_edit_name(SharedString::from(link.name));
                    window.set_edit_url(SharedString::from(link.url));
                    window.set_show_edit_dialog(true);
                    break;
                }
            }
        });
    }

    {
        let weak_window = main_window.as_weak();
        main_window.on_remove_link(move |id| {
            let window = weak_window.unwrap();
            let links = get_links().unwrap_or_default();
            for link in links {
                if link.id == id {
                    window.set_edit_id(link.id);
                    window.set_edit_name(SharedString::from(link.name));
                    break;
                }
            }
            window.set_show_delete_dialog(true);
        });
    }

    main_window.run().unwrap();
}
