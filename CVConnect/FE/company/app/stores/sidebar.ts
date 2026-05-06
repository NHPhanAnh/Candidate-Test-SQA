import { defineStore } from "pinia";
export type TPermission = "VIEW" | "ADD" | "UPDATE" | "DELETE" | "EXPORT";

export type TSidebarItem = {
  id: number;
  menuCode: string;
  menuLabel: string;
  menuIcon?: string;
  children?: TSidebarItem[];
  parentId?: number;
  permissions?: TPermission[];
  menuUrl?: string;
  isExpanded?: boolean;
};

export const useSidebarStore = defineStore("sidebar", () => {
  const sidebarData = ref<TSidebarItem[]>([]);

  const clearStore = () => {
    sidebarData.value = [];
  }

  const expandItem = (
    id: number,
    state: boolean,
    items: TSidebarItem[] = sidebarData.value,
  ): boolean => {
    for (const item of items) {
      if (item.id === id) {
        item.isExpanded = state;
        return true;
      }
      if (item.children && expandItem(id, state, item.children)) {
        return true;
      }
    }
    return false;
  };

  const setDefaultExpand = (items: TSidebarItem[]) => {
    for (const item of items) {
      if (item.children?.length) {
        item.isExpanded = false;
        setDefaultExpand(item.children);
      }
    }
  };

  const setMenus = (menus: TSidebarItem[]) => {
    sidebarData.value = menus;
    setDefaultExpand(sidebarData.value);
  };

  const getMenuItem = (
    url: string,
    items: TSidebarItem[] = sidebarData.value,
  ): TSidebarItem | null => {
    for (const item of items) {
      if (item.menuUrl === url) {
        return item;
      }
      if (item.children?.length) {
        const found = getMenuItem(url, item.children);
        if (found) {
          return found;
        }
      }
    }
    return null;
  };

  return {
    sidebarData,
    expandItem,
    setMenus,
    getMenuItem,
    clearStore,
  };
});
