import { cloneDeep } from "lodash";

export type TBreadcumbItem = {
  name: string;
  icon?: string;
  url?: string;
};

export const useBreadcrumbStore = defineStore("breadcrumb", () => {
  const route = useRoute();
  const sidebarStore = useSidebarStore();
  const { sidebarData } = storeToRefs(sidebarStore);

  const isOverriden = ref<boolean>(false);
  const overridenList = ref<TBreadcumbItem[]>([]);

  const items = computed<TBreadcumbItem[]>(() => {
    if (isOverriden.value) {
      return overridenList.value;
    }
    const menuItems = sidebarData.value;
    const menuMap: Map<number, TSidebarItem> = new Map();
    let currentItem: TSidebarItem | undefined;

    const flatten = (items: TSidebarItem[], map: Map<number, TSidebarItem>) => {
      for (const item of items) {
        if (item.menuUrl && item.menuUrl === route.path) {
          currentItem = item;
        }
        if (!map.has(item.id)) {
          map.set(item.id, item);
        }
        if (item.children) {
          flatten(item.children, map);
        }
      }
    };

    const traverse = (targetId: number, breadcrumbs: TBreadcumbItem[]) => {
      const target = menuMap.get(targetId);
      if (!target) return;

      const newItem: TBreadcumbItem = {
        name: target.menuLabel,
        icon:
          target.menuIcon === "mdi:circle-medium" ? undefined : target.menuIcon,
        url: target.menuUrl,
      };
      breadcrumbs.unshift(newItem);
      if (target.parentId) {
        traverse(target.parentId, breadcrumbs);
      }
    };

    flatten(menuItems, menuMap);

    const breadcrumbItems: TBreadcumbItem[] = [];
    if (currentItem) {
      traverse(currentItem.id, breadcrumbItems);
    }

    breadcrumbItems.unshift({
      name: "",
      icon: "mdi:home",
      url: "",
    });

    return breadcrumbItems;
  });

  function overrideItems(lists: TBreadcumbItem[], prependHome: boolean = true) {
    const itemLists = cloneDeep(lists);
    if (!itemLists) {
      return;
    }
    if (prependHome) {
      itemLists.unshift({
        name: "",
        icon: "mdi:home",
        url: "",
      });
    }

    isOverriden.value = true;
    overridenList.value = itemLists;
  }

  function clearOverrideItems() {
    isOverriden.value = false;
    overridenList.value = [];
  }

  return {
    items,
    overrideItems,
    clearOverrideItems,
  };
});
