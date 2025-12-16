import { invoke } from '@tauri-apps/api/core';

export interface Link {
  id: number;
  name: string;
  url: string;
}

/**
 * 获取所有电视直播链接
 */
export const getLinks = async (): Promise<Link[]> => {
  return await invoke<Link[]>('get_links');
};

/**
 * 添加新的电视直播链接
 */
export const addLink = async (name: string, url: string): Promise<Link> => {
  return await invoke<Link>('add_link', { name, url });
};

/**
 * 更新现有电视直播链接
 */
export const updateLink = async (id: number, name: string, url: string): Promise<Link> => {
  return await invoke<Link>('update_link', { id, name, url });
};

/**
 * 删除电视直播链接
 */
export const deleteLink = async (id: number): Promise<boolean> => {
  return await invoke<boolean>('delete_link', { id });
};
