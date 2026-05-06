<template>
  <div class="level-block">
    <div class="list">
      <div v-for="(item, index) of props.list" :key="index" class="level-unit">
        <div
          v-if="!props.disabled"
          class="remove-button"
          @click="handleRemove(index)"
        >
          <Icon name="material-symbols:close-rounded" />
        </div>
        <div class="info">
          {{ `${item.levelName}` }}
          <div v-if="!props.disabled" class="add-icon" @click="addSub(index)">
            <Icon name="material-symbols:add-2-rounded"></Icon>
          </div>
        </div>
        <div class="sub">
          <div v-for="(sub, subIndex) of item.sub" :key="subIndex" class="item">
            <AppInputText
              :label="''"
              :required="true"
              :error="''"
              :placeholder="'Mời nhập tên'"
              :value="sub.name"
              :is-disabled="props.disabled"
              :slim-error="true"
              class="text-input"
              @input="handleInput(index, subIndex, $event)"
            />
            <div
              v-if="!props.disabled"
              class="delete-sub"
              @click="removeSub(index, subIndex)"
            >
              <Icon name="material-symbols:delete-outline-rounded" />
            </div>
          </div>
        </div>
      </div>
      <div v-if="!props.disabled" class="select-input">
        <USelectMenu
          :key="resetKey"
          :model-value="undefined"
          :items="levelOption"
          class="selector"
          :variant="'none'"
          autocomplete="autocomplete"
          placeholder="Thêm vị trí"
          :search-input="{
            placeholder: 'Tìm kiếm',
          }"
          :ui="{
            base: 'flex justify-center items-center text-primary-400 font-medium gap-2',
            leadingIcon: 'flex items-center justify-center text-primary-400',
            trailingIcon: 'hidden',
          }"
          @update:model-value="handleAddNew($event)"
        />
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { cloneDeep } from "lodash";

type TProps = {
  list: Record<string, any>[];
  disabled?: boolean;
};

const props = withDefaults(defineProps<TProps>(), {
  disabled: false,
});
const emits = defineEmits<{
  (e: "input", payload: any): void;
}>();
const { getLevels } = useLevelApi();

const levelList = ref<Record<string, any>[]>([]);
const reseter = ref<
  | {
      label: any;
      value: any;
    }
  | undefined
>(undefined);
const resetKey = ref<number>(0);

onBeforeMount(async () => {
  let levelRes = await getLevels({ pageIndex: 0, pageSize: 1 });
  levelRes = await getLevels({
    pageIndex: 0,
    pageSize: levelRes.data.pageInfo.totelElements,
  });
  levelList.value = levelRes.data.data;
});

const levelOption = computed(() => {
  return levelList.value.map((level) => ({
    label: level.name,
    value: level.id,
  }));
});

const removeSub = (index: number, subIndex: number) => {
  const list = cloneDeep(props.list);
  list[index]?.sub.splice(subIndex, 1);
  if (!list[index]?.sub.length) {
    list.splice(index, 1);
  }
  emits("input", list);
};

const addSub = (index: number) => {
  const list = cloneDeep(props.list);
  list[index]?.sub.push({
    name: "",
  });
  emits("input", list);
};

const handleRemove = (index: number) => {
  const list = cloneDeep(props.list);
  list.splice(index, 1);
  emits("input", list);
};

const handleInput = (index: number, subIndex: number, value: string) => {
  const list = cloneDeep(props.list);
  if (!list[index]) {
    return;
  }
  list[index].sub[subIndex] = {
    name: value,
  };
  emits("input", list);
};

const handleAddNew = (newItem: any) => {
  console.log(newItem);
  const list = cloneDeep(props.list);
  reseter.value = undefined;
  resetKey.value += 1;
  const groupIndex = list.findIndex((item) => item.levelName == newItem.label);
  if (groupIndex != -1) {
    list[groupIndex]?.sub.push({
      name: "",
    });
  } else {
    list.push({
      levelName: newItem.label,
      levelId: newItem.value,
      sub: [
        {
          name: "",
        },
      ],
    });
  }

  emits("input", list);
};
</script>
<style lang="scss" scoped>
.level-block {
  margin-top: 28px;
  .list {
    display: flex;
    flex-direction: column;
    gap: 8px;

    .level-unit {
      position: relative;
      display: flex;
      flex-direction: column;
      gap: 4px;
      border: 1px solid $color-gray-300;
      border-radius: 6px;
      padding: 8px;
      max-width: 976px;

      &:hover {
        .info {
          .add-icon {
            display: flex;
          }
        }
      }

      .info {
        font-size: 14px;
        font-weight: 600;

        display: flex;
        flex-direction: row;
        gap: 8px;
        align-items: center;

        .add-icon {
          display: flex;
          height: 20px;
          width: 20px;
          cursor: pointer;
          align-items: center;
          justify-content: center;
          background-color: $color-gray-100;
          color: $color-gray-500;
          &:hover {
            background-color: $color-gray-200;
            color: $color-primary-500;
          }
          transition-duration: 200ms;
          border-radius: 999px;
          .iconify {
            font-size: 16px;
          }
        }
      }

      .sub {
        .label {
          font-size: 14px;
        }
        .item {
          display: flex;
          flex-direction: row;
          gap: 8px;
          align-items: center;

          .text-input {
            flex: 1;
          }

          .delete-sub {
            color: $color-gray-500;
            cursor: pointer;
            transition-duration: 200ms;
            &:hover {
              color: $color-primary-500;
            }
            .iconify {
              display: block;
              font-size: 20px;
            }
          }
        }
      }

      .remove-button {
        position: absolute;
        z-index: 0;
        top: 4px;
        right: 4px;
        font-size: 20px;
        cursor: pointer;

        .iconify {
          display: block;
          color: $color-gray-500;
          transition-duration: 200ms;

          &:hover {
            color: $color-primary-500;
          }
        }
      }
    }

    .select-input {
      :deep(button.selector) {
        border: 1px dashed $color-primary-400;
        background-color: rgba($color-primary-400, 0.05);
        padding: 8px;
        cursor: pointer;
        width: 100%;
        max-width: 100%;

        .text-dimmed {
          color: $color-primary-400;
          font-weight: 500;
        }
      }
    }
  }
}
</style>
