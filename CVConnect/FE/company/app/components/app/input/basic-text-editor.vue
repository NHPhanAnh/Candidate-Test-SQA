<template>
  <div class="basic-text-editor">
    <div v-if="editor" class="editor-toolbar">
      <!-- Basic formatting -->
      <button
        :class="{ active: editor.isActive('bold') }"
        @click="editor.chain().focus().toggleBold().run()"
      >
        <Icon name="material-symbols:format-bold-rounded" />
      </button>
      <button
        :class="{ active: editor.isActive('italic') }"
        @click="editor.chain().focus().toggleItalic().run()"
      >
        <Icon name="material-symbols:format-italic-rounded" />
      </button>
      <button
        :class="{ active: editor.isActive('underline') }"
        @click="editor.chain().focus().toggleUnderline().run()"
      >
        <Icon name="material-symbols:format-underlined-rounded" />
      </button>
      <button
        :class="{ active: editor.isActive('strike') }"
        @click="editor.chain().focus().toggleStrike().run()"
      >
        <Icon name="material-symbols:format-strikethrough" />
      </button>

      <button
        :class="{ active: editor.isActive('bulletList') }"
        @click="editor.chain().focus().toggleBulletList().run()"
      >
        <Icon name="material-symbols:format-list-bulleted-rounded" />
      </button>

      <button
        :class="{ active: editor.isActive('orderedList') }"
        @click="editor.chain().focus().toggleOrderedList().run()"
      >
        <Icon name="material-symbols:format-list-numbered-rounded" />
      </button>
      <button
        :class="{ active: editor.isActive({ textAlign: 'left' }) }"
        @click="editor.chain().focus().toggleTextAlign('left').run()"
      >
        <Icon name="material-symbols:format-align-left-rounded" />
      </button>

      <button
        :class="{ active: editor.isActive({ textAlign: 'center' }) }"
        @click="editor.chain().focus().toggleTextAlign('center').run()"
      >
        <Icon name="material-symbols:format-align-center-rounded" />
      </button>

      <button
        :class="{ active: editor.isActive({ textAlign: 'right' }) }"
        @click="editor.chain().focus().toggleTextAlign('right').run()"
      >
        <Icon name="material-symbols:format-align-right-rounded" />
      </button>

      <button
        :class="{ active: editor.isActive({ textAlign: 'justify' }) }"
        @click="editor.chain().focus().toggleTextAlign('justify').run()"
      >
        <Icon name="material-symbols:format-align-justify-rounded" />
      </button>

      <button @click="editor.chain().focus().setHorizontalRule().run()">
        <Icon name="material-symbols:horizontal-rule-rounded" />
      </button>

      <button @click="editor.chain().focus().undo().run()">
        <Icon name="material-symbols:undo-rounded" />
      </button>
      <button @click="editor.chain().focus().redo().run()">
        <Icon name="material-symbols:redo-rounded" />
      </button>
    </div>

    <!-- The editor area -->
    <div
      class="editor-wrapper"
      @click="editor?.chain().focus().run()"
      @dragover.prevent
      @drop="onDrop"
    >
      <EditorContent :editor="editor" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useEditor, EditorContent } from "@tiptap/vue-3";
import StarterKit from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";
import TextAlign from "@tiptap/extension-text-align";
import BulletList from "@tiptap/extension-bullet-list";
import OrderedList from "@tiptap/extension-ordered-list";
import ListItem from "@tiptap/extension-list-item";
import { MergeTag } from "~/extensions/tiptap/MergeTag";

const props = defineProps<{
  value: string;
}>();

const emits = defineEmits<{
  (e: "input", value: string): void;
}>();

const editor = useEditor({
  content: props.value || "",
  extensions: [
    StarterKit,
    BulletList.configure({
      HTMLAttributes: { class: "list-disc ml-4" },
    }),
    OrderedList.configure({
      HTMLAttributes: { class: "list-decimal ml-4" },
    }),
    Underline,
    ListItem,
    TextAlign.configure({
      types: ["heading", "paragraph"],
    }),
    MergeTag,
  ],
  onUpdate: ({ editor }) => {
    const html = editor.isEmpty ? "" : editor.getHTML();
    emits("input", html);
  },
});

let draggedTagData: any = null;

onMounted(() => {
  try {
    const dom = editor.value?.view.dom;
    if (!dom) return;

    // when user starts dragging a merge tag inside the editor
    dom.addEventListener("dragstart", (e: DragEvent) => {
      const target = e.target as HTMLElement;
      const tag = target?.closest("[data-merge-tag]");
      if (tag) {
        const attrs = {
          id: tag.getAttribute("data-id"),
          code: tag.getAttribute("data-merge-tag"),
          label: tag.textContent,
          description: tag.getAttribute("data-description"),
        };
        draggedTagData = attrs;
        e.dataTransfer?.setData("application/json", JSON.stringify(attrs));
        // small delay to refocus
        requestAnimationFrame(() => editor.value?.commands.focus());
      }
    });

    dom.addEventListener("dragend", () => {
      draggedTagData = null;
    });
  } catch (err) {
    console.log("loi nay", err);
  }
});

function onDrop(e: DragEvent) {
  e.preventDefault();
  if (!editor.value?.view) return;

  const data = e.dataTransfer?.getData("application/json");
  if (!data) return;

  const placeholder = JSON.parse(data);
  const coords = { left: e.clientX, top: e.clientY };
  const pos = editor.value.view.posAtCoords(coords)?.pos;
  if (pos == null) return;

  // remove original tag if this was an internal drag
  if (draggedTagData) {
    const { state, dispatch } = editor.value.view;
    const tr = state.tr;
    state.doc.descendants((node, offset) => {
      if (
        node.type.name === "mergeTag" &&
        node.attrs.code === draggedTagData.code
      ) {
        tr.delete(offset, offset + node.nodeSize);
      }
    });
    dispatch(tr);
  }

  // insert tag at drop position
  editor.value
    ?.chain()
    .focus()
    .insertContentAt(pos, { type: "mergeTag", attrs: placeholder })
    .run();

  draggedTagData = null;
}

function getUsedPlaceholders() {
  const json = editor.value?.getJSON();
  if (!json) return [];

  const tags: any[] = [];

  function walk(node: any) {
    if (!node) return;
    if (node.type === "mergeTag") {
      tags.push(node.attrs);
    }
    if (node.content) node.content.forEach(walk);
  }

  walk(json);
  return tags;
}

defineExpose({ getUsedPlaceholders });
</script>

<style scoped lang="scss">
.basic-text-editor {
  overflow: hidden;
  display: flex;
  flex-direction: column;
  border: 1px solid rgba($color-primary-800, 0.1);
  border-radius: 10px;
  transition: border 200ms;

  &:focus-within {
    border: 1px solid rgba($color-primary-400, 1);
  }

  .editor-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    padding: 8px;
    border-bottom: 1px solid rgba($color-primary-800, 0.1);
    background-color: $color-gray-50;

    button {
      height: 28px;
      width: 28px;
      cursor: pointer;
      border-radius: 8px;
      font-size: 20px;
      display: flex;
      align-items: center;
      justify-content: center;

      &.active {
        background-color: rgba($color-primary-300, 0.1);
        color: $color-primary-500;
      }

      &:hover {
        background-color: rgba($color-primary-300, 0.1);
      }
    }
  }

  .editor-wrapper {
    cursor: text;
    padding: 8px;
    min-height: 150px;
    background: #fff;
    font-weight: 500;
    color: $color-gray-600;
    font-size: 14px;
    line-height: 20px;

    :deep(.ProseMirror) {
      outline: none;
    }
  }

  :deep(.chip) {
    border: 1px solid $color-gray-300;
    background-color: #ffffff;
    padding: 1px 3px;
    border-radius: 4px;
    font-size: 13px;

    // display: inline-flex;
    // align-items: center;
    // gap: 4px;
    // background-color: #ffffff;
    // border: 1px solid $color-gray-300;
    // border-radius: 9999px;
    // padding: 1px 6px;
    cursor: grab;
    user-select: none;
  }

  :deep(.chip:active) {
    cursor: grabbing;
  }
}
</style>
