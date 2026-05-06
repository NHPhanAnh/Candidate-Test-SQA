// ~/extensions/MergeTag.ts
import { Node, mergeAttributes } from "@tiptap/core";

export interface MergeTagOptions {
  HTMLAttributes: Record<string, any>;
}

declare module "@tiptap/core" {
  interface Commands<ReturnType> {
    mergeTag: {
      insertMergeTag: (attrs: Record<string, any>) => ReturnType;
    };
  }
}

export const MergeTag = Node.create<MergeTagOptions>({
  name: "mergeTag",
  group: "inline",
  inline: true,
  atom: true,
  draggable: true,

  addAttributes() {
    return {
      id: { default: null },
      code: { default: null },
      label: { default: null },
      meta: { default: null },
    };
  },

  parseHTML() {
    return [{ tag: "span[data-merge-tag]" }];
  },

  renderHTML({ node, HTMLAttributes }) {
    return [
      "span",
      mergeAttributes(this.options.HTMLAttributes, HTMLAttributes, {
        "data-merge-tag": node.attrs.code,
        "data-id": node.attrs.id,
        draggable: "true", // ensure native dragging
        class: "chip",
      }),
      node.attrs.label || node.attrs.code,
    ];
  },

  addCommands() {
    return {
      insertMergeTag:
        (attrs) =>
        ({ chain }) => {
          return chain()
            .insertContent({
              type: this.name,
              attrs,
            })
            .run();
        },
    };
  },
});
