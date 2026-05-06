<template>
  <div class="content">
    <div class="editor">
      <AppInputBasicTextEditor
        ref="editorRef"
        :value="textEditorValue"
        @input="handleInput"
      />
    </div>

    <div class="placeholder-list">
      <div
        v-for="placeholder in placeholders"
        :key="placeholder.id"
        draggable="true"
        class="placeholder"
        @dragstart="onDragStart($event, placeholder)"
      >
        {{ placeholder.label }}
      </div>

      <AppButton
        class="button"
        :text="'lấy danh sách tags'"
        @click="showUsedTags"
      />
      <AppButton class="button" :text="'lấy text'" @click="getHTML" />
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false });

const editorRef = ref<any>(null);
const textEditorValue = ref<string>(
  '<p>awd<span id="0" code="CODE_1" label="Tên ứng viên" description="" data-merge-tag="CODE_1" data-id="0" draggable="true" class="chip">Tên ứng viên</span>awd awda<span id="1" code="CODE_2" label="Tên công ty" description="" data-merge-tag="CODE_2" data-id="1" draggable="true" class="chip">Tên công ty</span>wdaw dawddddddd<span id="2" code="CODE_3" label="Tên tập đoàn" description="" data-merge-tag="CODE_3" data-id="2" draggable="true" class="chip">Tên tập đoàn</span>ddddddd dddddddddddddddddddddd</p>',
);

onBeforeMount(() => {
  const parsed = parseMergeTagsToHtml(
    "<p>Đây là ${CODE_1}đài tiế${CODE_2}ng lói Vi${CODE_3}ệt Nam.</p>",
    placeholders,
  );
  console.log(parsed);
  // textEditorValue.value = parsed;
});

const placeholders = [
  { id: 0, code: "CODE_1", label: "Tên ứng viên", description: "" },
  { id: 1, code: "CODE_2", label: "Tên công ty", description: "" },
  { id: 2, code: "CODE_3", label: "Tên tập đoàn", description: "" },
];

function handleInput(value: string) {
  textEditorValue.value = value;
}

function onDragStart(e: DragEvent, placeholder: any) {
  e.dataTransfer?.setData("application/json", JSON.stringify(placeholder));
}

function showUsedTags() {
  const used = editorRef.value?.getUsedPlaceholders?.() || [];
  console.log("tags:", used);
}

function getHTML() {
  console.log(textEditorValue.value);
}
</script>

<style scoped>
.content {
  min-height: 100vh;
  display: flex;
  flex-direction: row;
  gap: 8px;

  .editor {
    flex: 1;
  }

  .placeholder-list {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .placeholder {
      font-size: 13px;
      padding: 6px 12px;
      border: 1px solid gray;
      border-radius: 4px;
      cursor: grabbing;
    }
  }
}
</style>
